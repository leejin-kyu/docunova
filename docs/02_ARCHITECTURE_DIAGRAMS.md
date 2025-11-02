# DocuNova 아키텍처 다이어그램

## 📋 문서 개요

이 문서는 Mermaid 다이어그램을 사용하여 DocuNova SaaS의 전체 아키텍처를 시각화합니다.

---

## 1. 전체 시스템 아키텍처

```mermaid
graph TB
    subgraph "사용자 레이어"
        USER[👤 사용자<br/>웹 브라우저]
    end

    subgraph "프론트엔드 레이어 (Port 3000)"
        NEXTJS[Next.js 16<br/>React 19]

        subgraph "Pages"
            HOME[Home<br/>랜딩 페이지]
            CHAT[Chat<br/>채팅 인터페이스]
            DASH[Dashboard<br/>통계 대시보드]
            DOCS[Documents<br/>문서 관리]
            SETTINGS[Settings<br/>설정]
        end

        subgraph "API Client Layer"
            APICLIENT[API Client<br/>lib/api.ts]
            ERROR[Error Handler<br/>에러 핸들링]
            RETRY[Retry Logic<br/>재시도 로직]
        end

        subgraph "UI Components"
            UICOMP[shadcn/ui<br/>Button, Card, Input]
        end
    end

    subgraph "백엔드 레이어 (Port 8000)"
        FASTAPI[FastAPI 백엔드<br/>Python]

        subgraph "API Endpoints"
            API1[POST /api/query_stream<br/>채팅 질의]
            API2[POST /api/upload<br/>문서 업로드]
            API3[GET /api/vectors<br/>문서 목록]
            API4[DELETE /api/delete<br/>문서 삭제]
            API5[GET /api/health<br/>헬스체크]
        end

        subgraph "Business Logic"
            DOCPROC[문서 처리<br/>PDF, DOCX, TXT]
            EMBED[임베딩 생성<br/>FastEmbed]
            RAG[RAG 검색<br/>벡터 유사도]
            LLM[LLM 통신<br/>Ollama]
        end
    end

    subgraph "데이터 레이어"
        QDRANT[(Qdrant<br/>벡터 DB)]
        OLLAMA[Ollama<br/>LLM 서버<br/>Port 11434]
        FILES[File Storage<br/>로컬 파일 시스템]
    end

    USER --> |HTTP/HTTPS| NEXTJS
    NEXTJS --> HOME
    NEXTJS --> CHAT
    NEXTJS --> DASH
    NEXTJS --> DOCS
    NEXTJS --> SETTINGS

    HOME --> APICLIENT
    CHAT --> APICLIENT
    DASH --> APICLIENT
    DOCS --> APICLIENT
    SETTINGS --> APICLIENT

    APICLIENT --> ERROR
    APICLIENT --> RETRY

    UICOMP --> HOME
    UICOMP --> CHAT
    UICOMP --> DASH

    APICLIENT --> |REST API<br/>+ SSE| FASTAPI

    FASTAPI --> API1
    FASTAPI --> API2
    FASTAPI --> API3
    FASTAPI --> API4
    FASTAPI --> API5

    API1 --> RAG
    API1 --> LLM
    API2 --> DOCPROC
    API2 --> EMBED
    API3 --> QDRANT
    API4 --> QDRANT
    API4 --> FILES

    DOCPROC --> FILES
    EMBED --> QDRANT
    RAG --> QDRANT
    LLM --> OLLAMA

    style USER fill:#e1f5ff
    style NEXTJS fill:#bbdefb
    style FASTAPI fill:#c8e6c9
    style QDRANT fill:#fff9c4
    style OLLAMA fill:#fff9c4
    style FILES fill:#fff9c4
    style APICLIENT fill:#f8bbd0
    style ERROR fill:#ffccbc
    style RETRY fill:#ffccbc
```

---

## 2. 채팅 질의 플로우 (RAG 모드)

```mermaid
sequenceDiagram
    autonumber
    actor User as 👤 사용자
    participant UI as Chat UI
    participant API as API Client
    participant Backend as FastAPI
    participant Qdrant as Qdrant DB
    participant LLM as Ollama LLM

    User->>UI: 질문 입력 및 전송
    UI->>UI: 입력 검증 (빈 값, 길이)
    UI->>API: query({ question, mode: "rag" })

    Note over API: 타임아웃 30초 설정

    API->>Backend: POST /api/query_stream

    Backend->>Backend: 요청 검증 (Pydantic)
    Backend->>Qdrant: 문서 벡터 검색 (Top 5)
    Qdrant-->>Backend: 유사 문서 반환

    Backend->>Backend: 컨텍스트 구성
    Backend->>LLM: 프롬프트 + 컨텍스트

    Note over LLM: 스트리밍 응답 생성

    loop 토큰 단위 스트리밍
        LLM-->>Backend: 토큰 생성
        Backend-->>API: SSE: { event: "token", text: "..." }
        API-->>UI: 실시간 UI 업데이트
        UI-->>User: 답변 표시 (애니메이션)
    end

    Backend-->>API: SSE: { event: "sources", items: [...] }
    API-->>UI: 참고 문서 표시

    Backend-->>API: SSE: { event: "done" }
    API-->>UI: 로딩 상태 종료
    UI-->>User: 최종 답변 + 참고 문서
```

---

## 3. 문서 업로드 플로우

```mermaid
sequenceDiagram
    autonumber
    actor User as 👤 사용자
    participant UI as Documents UI
    participant API as API Client
    participant Backend as FastAPI
    participant FS as File Storage
    participant Embed as FastEmbed
    participant Qdrant as Qdrant DB

    User->>UI: 파일 선택 (드래그 앤 드롭 또는 클릭)
    UI->>UI: 파일 검증<br/>(크기, 확장자, MIME)

    alt 검증 실패
        UI-->>User: 에러 메시지 표시
    else 검증 성공
        UI->>UI: 로딩 상태 시작
        UI->>API: uploadFiles(files)

        API->>Backend: POST /api/upload<br/>(multipart/form-data)

        Backend->>Backend: 파일 수신 및 검증
        Backend->>FS: 파일 저장 (data/)
        FS-->>Backend: 파일 경로 반환

        Backend->>Backend: 문서 파싱<br/>(PDF, DOCX, TXT, ...)
        Backend->>Backend: 텍스트 청킹<br/>(600자, 250자 오버랩)

        loop 각 청크
            Backend->>Embed: 임베딩 생성
            Embed-->>Backend: 벡터 반환
        end

        Backend->>Qdrant: 벡터 저장 (배치)
        Qdrant-->>Backend: 저장 완료

        Backend-->>API: 성공 응답<br/>{ status: "success", ... }
        API-->>UI: 로딩 상태 종료
        UI-->>User: 성공 메시지 표시

        UI->>API: getDocuments()<br/>(문서 목록 갱신)
        API->>Backend: GET /api/vectors
        Backend->>Qdrant: 문서 목록 조회
        Qdrant-->>Backend: 문서 목록 반환
        Backend-->>API: 문서 목록
        API-->>UI: 목록 업데이트
        UI-->>User: 업데이트된 문서 목록 표시
    end
```

---

## 4. 에러 핸들링 플로우

```mermaid
flowchart TD
    START([API 호출 시작])

    TRY[Try: API 요청 실행]
    SUCCESS{성공?}

    TIMEOUT{타임아웃?}
    RETRY_CHECK{재시도<br/>횟수 < 3?}
    WAIT[1초 대기]
    RETRY[재시도]

    NETWORK{네트워크<br/>에러?}
    SERVER{서버<br/>에러 5xx?}
    CLIENT{클라이언트<br/>에러 4xx?}

    HANDLE_TIMEOUT[타임아웃 에러 처리<br/>"요청 시간 초과"]
    HANDLE_NETWORK[네트워크 에러 처리<br/>"연결 실패"]
    HANDLE_SERVER[서버 에러 처리<br/>"서버 오류"]
    HANDLE_CLIENT[클라이언트 에러 처리<br/>"잘못된 요청"]
    HANDLE_UNKNOWN[알 수 없는 에러 처리<br/>"오류 발생"]

    SHOW_ERROR[사용자에게<br/>에러 메시지 표시]
    LOG[에러 로그 기록]
    END([종료])

    START --> TRY
    TRY --> SUCCESS

    SUCCESS -->|Yes| END
    SUCCESS -->|No| TIMEOUT

    TIMEOUT -->|Yes| RETRY_CHECK
    RETRY_CHECK -->|Yes| WAIT
    WAIT --> RETRY
    RETRY --> TRY
    RETRY_CHECK -->|No| HANDLE_TIMEOUT

    TIMEOUT -->|No| NETWORK
    NETWORK -->|Yes| HANDLE_NETWORK
    NETWORK -->|No| SERVER
    SERVER -->|Yes| HANDLE_SERVER
    SERVER -->|No| CLIENT
    CLIENT -->|Yes| HANDLE_CLIENT
    CLIENT -->|No| HANDLE_UNKNOWN

    HANDLE_TIMEOUT --> SHOW_ERROR
    HANDLE_NETWORK --> SHOW_ERROR
    HANDLE_SERVER --> SHOW_ERROR
    HANDLE_CLIENT --> SHOW_ERROR
    HANDLE_UNKNOWN --> SHOW_ERROR

    SHOW_ERROR --> LOG
    LOG --> END

    style START fill:#c8e6c9
    style END fill:#c8e6c9
    style SUCCESS fill:#fff9c4
    style TIMEOUT fill:#fff9c4
    style NETWORK fill:#fff9c4
    style SERVER fill:#fff9c4
    style CLIENT fill:#fff9c4
    style RETRY_CHECK fill:#fff9c4
    style SHOW_ERROR fill:#ffccbc
    style HANDLE_TIMEOUT fill:#ffccbc
    style HANDLE_NETWORK fill:#ffccbc
    style HANDLE_SERVER fill:#ffccbc
    style HANDLE_CLIENT fill:#ffccbc
    style HANDLE_UNKNOWN fill:#ffccbc
```

---

## 5. 컴포넌트 의존성 다이어그램

```mermaid
graph LR
    subgraph "app/ (Pages)"
        PAGE_CHAT[chat/page.tsx]
        PAGE_DASH[dashboard/page.tsx]
        PAGE_DOCS[documents/page.tsx]
    end

    subgraph "components/ui/"
        BUTTON[button.tsx]
        CARD[card.tsx]
        INPUT[input.tsx]
    end

    subgraph "lib/"
        API[api.ts<br/>API Client]
        UTILS[utils.ts<br/>유틸리티]
    end

    PAGE_CHAT --> BUTTON
    PAGE_CHAT --> CARD
    PAGE_CHAT --> INPUT
    PAGE_CHAT --> API

    PAGE_DASH --> BUTTON
    PAGE_DASH --> CARD
    PAGE_DASH --> API

    PAGE_DOCS --> BUTTON
    PAGE_DOCS --> CARD
    PAGE_DOCS --> INPUT
    PAGE_DOCS --> API

    BUTTON --> UTILS
    CARD --> UTILS
    INPUT --> UTILS

    API --> UTILS

    style API fill:#f8bbd0
    style UTILS fill:#bbdefb
    style PAGE_CHAT fill:#c8e6c9
    style PAGE_DASH fill:#c8e6c9
    style PAGE_DOCS fill:#c8e6c9
```

---

## 6. 상태 관리 다이어그램

```mermaid
stateDiagram-v2
    [*] --> Idle: 페이지 로드

    Idle --> Loading: API 호출
    Loading --> Success: 응답 성공
    Loading --> Error: 응답 실패
    Loading --> Timeout: 타임아웃

    Success --> Idle: 완료
    Error --> Idle: 에러 확인
    Timeout --> Retrying: 재시도 가능
    Retrying --> Loading: 재시도 중
    Timeout --> Error: 재시도 불가

    state Loading {
        [*] --> RequestSent
        RequestSent --> ResponsePending
        ResponsePending --> StreamingData: 스트리밍 모드
        StreamingData --> [*]
    }

    state Error {
        [*] --> DisplayError
        DisplayError --> LogError
        LogError --> [*]
    }
```

---

## 7. 백엔드 모듈 구조

```mermaid
graph TB
    MAIN[main.py<br/>FastAPI 앱]

    subgraph "API Endpoints"
        EP1[/api/query_stream]
        EP2[/api/upload]
        EP3[/api/vectors]
        EP4[/api/delete]
        EP5[/api/health]
    end

    subgraph "Business Logic"
        DOC[Document Processor<br/>문서 파싱]
        CHUNK[Text Chunker<br/>텍스트 청킹]
        EMB[Embedding Generator<br/>임베딩 생성]
        SEARCH[Vector Search<br/>유사도 검색]
        LLMCLIENT[LLM Client<br/>Ollama 통신]
    end

    subgraph "Data Access"
        QDRANT_CLIENT[Qdrant Client<br/>벡터 DB 접근]
        FILE_STORAGE[File Storage<br/>파일 시스템]
    end

    subgraph "Utilities"
        LOGGER[Logger<br/>로깅]
        CONFIG[Config<br/>환경 변수]
        VALIDATOR[Validator<br/>입력 검증]
    end

    MAIN --> EP1
    MAIN --> EP2
    MAIN --> EP3
    MAIN --> EP4
    MAIN --> EP5

    EP1 --> SEARCH
    EP1 --> LLMCLIENT
    EP2 --> DOC
    EP2 --> CHUNK
    EP2 --> EMB
    EP3 --> QDRANT_CLIENT
    EP4 --> QDRANT_CLIENT
    EP4 --> FILE_STORAGE

    DOC --> FILE_STORAGE
    EMB --> QDRANT_CLIENT
    SEARCH --> QDRANT_CLIENT

    MAIN --> LOGGER
    MAIN --> CONFIG
    EP1 --> VALIDATOR
    EP2 --> VALIDATOR

    style MAIN fill:#c8e6c9
    style LOGGER fill:#fff9c4
    style CONFIG fill:#fff9c4
    style VALIDATOR fill:#fff9c4
```

---

## 8. 배포 아키텍처

```mermaid
graph TB
    subgraph "Production Environment"
        LB[Load Balancer<br/>Nginx]

        subgraph "Frontend Instances"
            FE1[Next.js Instance 1<br/>Port 3000]
            FE2[Next.js Instance 2<br/>Port 3001]
        end

        subgraph "Backend Instances"
            BE1[FastAPI Instance 1<br/>Port 8000]
            BE2[FastAPI Instance 2<br/>Port 8001]
        end

        subgraph "Data Layer"
            QDRANT_PROD[(Qdrant<br/>Cluster Mode)]
            OLLAMA_PROD[Ollama<br/>GPU Accelerated]
            FS_PROD[Shared File Storage<br/>NFS or S3]
        end
    end

    USERS[👥 사용자들]

    USERS --> LB
    LB --> FE1
    LB --> FE2

    FE1 --> BE1
    FE1 --> BE2
    FE2 --> BE1
    FE2 --> BE2

    BE1 --> QDRANT_PROD
    BE1 --> OLLAMA_PROD
    BE1 --> FS_PROD
    BE2 --> QDRANT_PROD
    BE2 --> OLLAMA_PROD
    BE2 --> FS_PROD

    style LB fill:#f8bbd0
    style FE1 fill:#bbdefb
    style FE2 fill:#bbdefb
    style BE1 fill:#c8e6c9
    style BE2 fill:#c8e6c9
    style QDRANT_PROD fill:#fff9c4
    style OLLAMA_PROD fill:#fff9c4
    style FS_PROD fill:#fff9c4
```

---

## 9. 개발 환경 아키텍처

```mermaid
graph TB
    DEV[개발자 머신]

    subgraph "Development Stack"
        NEXTDEV[Next.js Dev Server<br/>npm run dev<br/>Port 3000]
        FASTDEV[FastAPI Dev Server<br/>python main.py<br/>Port 8000]
        QDRANTDEV[(Qdrant<br/>Embedded Mode)]
        OLLAMADEV[Ollama<br/>로컬 LLM<br/>Port 11434]
        FSDEV[Local Files<br/>./data/]
    end

    DEV --> NEXTDEV
    DEV --> FASTDEV

    NEXTDEV --> |localhost:8000| FASTDEV

    FASTDEV --> QDRANTDEV
    FASTDEV --> OLLAMADEV
    FASTDEV --> FSDEV

    style DEV fill:#e1f5ff
    style NEXTDEV fill:#bbdefb
    style FASTDEV fill:#c8e6c9
    style QDRANTDEV fill:#fff9c4
    style OLLAMADEV fill:#fff9c4
    style FSDEV fill:#fff9c4
```

---

## 📝 다이어그램 사용 가이드

### Mermaid 렌더링 방법

1. **GitHub/GitLab**: 자동 렌더링
2. **VS Code**: Mermaid Preview 확장 설치
3. **온라인**: https://mermaid.live/

### 다이어그램 읽는 법

- **사각형**: 컴포넌트/모듈
- **원통형**: 데이터베이스
- **화살표**: 데이터 흐름/의존성
- **점선**: 비동기/옵션
- **색상**:
  - 파란색: 프론트엔드
  - 초록색: 백엔드
  - 노란색: 데이터/인프라
  - 분홍색: 중요 레이어

---

**이 다이어그램들은 시스템의 모든 측면을 시각화합니다.** 📊
**개발 시 이 다이어그램을 참고하여 구현하세요!** ✅
