# DocuNova SaaS 시스템 아키텍처 설계서

## 📋 문서 개요

**프로젝트명**: DocuNova - 기업용 AI 문서 어시스턴트
**버전**: 1.0.0
**작성일**: 2025-10-30
**설계 원칙**: 안정성 최우선, 단순성, 유지보수 용이성

---

## 🎯 핵심 설계 목표

### 1. **절대적 안정성** (Zero-Error Tolerance)
- UI에서 절대 오류 발생하지 않음
- 백엔드 장애 시 Graceful Degradation
- 모든 API 호출에 타임아웃 및 재시도 로직
- 에러 바운더리로 전체 앱 크래시 방지

### 2. **단순성** (Keep It Simple)
- 복잡한 상태 관리 없음
- 직관적인 컴포넌트 구조
- 명확한 책임 분리

### 3. **유지보수성** (Maintainability)
- 모듈화된 구조
- 명확한 문서화
- 일관된 코드 스타일
- 테스트 가능한 설계

---

## 🏗️ 전체 시스템 구조

```
┌─────────────────────────────────────────────────────────┐
│                    사용자 (User)                        │
└───────────────────┬─────────────────────────────────────┘
                    │ HTTP/HTTPS
                    ▼
┌─────────────────────────────────────────────────────────┐
│              Next.js Frontend (Port 3000)               │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Pages (App Router)                               │  │
│  │  - Home (/): 랜딩 페이지                          │  │
│  │  - Chat (/chat): 채팅 인터페이스                  │  │
│  │  - Dashboard (/dashboard): 통계 대시보드         │  │
│  │  - Documents (/documents): 문서 관리              │  │
│  │  - Settings (/settings): 설정                     │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  API Client Layer (lib/api.ts)                    │  │
│  │  - HTTP 통신 추상화                               │  │
│  │  - 에러 핸들링                                     │  │
│  │  - 타임아웃 관리                                   │  │
│  │  - 재시도 로직                                     │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────┬───────────────────────────────────┘
                      │ REST API + SSE (Server-Sent Events)
                      ▼
┌─────────────────────────────────────────────────────────┐
│         FastAPI Backend (Port 8000)                     │
│  ┌───────────────────────────────────────────────────┐  │
│  │  API Endpoints                                     │  │
│  │  - POST /api/query_stream: 채팅 질의 (스트리밍)   │  │
│  │  - POST /api/upload: 문서 업로드                  │  │
│  │  - GET /api/vectors: 문서 목록                    │  │
│  │  - DELETE /api/delete: 문서 삭제                  │  │
│  │  - GET /api/health: 헬스체크                      │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Business Logic Layer                              │  │
│  │  - 문서 처리 (PDF, DOCX, TXT, ...)               │  │
│  │  - 임베딩 생성                                     │  │
│  │  - RAG 검색                                        │  │
│  │  - LLM 통신                                        │  │
│  └───────────────────────────────────────────────────┘  │
└─────┬──────────────┬──────────────┬────────────────────┘
      │              │              │
      ▼              ▼              ▼
┌──────────┐  ┌────────────┐  ┌──────────────┐
│  Qdrant  │  │   Ollama   │  │ File Storage │
│ (Vector  │  │   (LLM)    │  │   (Local)    │
│   DB)    │  │            │  │              │
└──────────┘  └────────────┘  └──────────────┘
```

---

## 🔑 핵심 아키텍처 결정사항

### 1. **프론트엔드-백엔드 완전 분리**

**이유**:
- UI 오류와 백엔드 오류 격리
- 독립적인 배포 가능
- 각 레이어 독립 테스트 가능

**구현**:
- Next.js: 포트 3000
- FastAPI: 포트 8000
- CORS 설정으로 통신

### 2. **API 클라이언트 레이어 도입**

**이유**:
- 모든 HTTP 통신 중앙화
- 일관된 에러 핸들링
- 재사용성 및 테스트 용이

**구현**:
```typescript
// lib/api.ts
class APIClient {
  - 자동 재시도 (3회)
  - 타임아웃 (30초)
  - 에러 변환 (백엔드 에러 → 사용자 친화적 메시지)
  - 로딩 상태 관리
}
```

### 3. **에러 바운더리 전략**

**이유**:
- React 컴포넌트 에러 격리
- 전체 앱 크래시 방지
- 사용자에게 친화적인 에러 메시지

**구현**:
```
- 글로벌 에러 바운더리 (app/error.tsx)
- 페이지별 에러 바운더리
- 컴포넌트별 에러 바운더리 (필요 시)
```

### 4. **Optimistic UI 업데이트 금지**

**이유**:
- 데이터 불일치 위험
- 롤백 로직 복잡도 증가
- 안정성 최우선

**구현**:
- 모든 작업 완료 후 UI 업데이트
- 로딩 상태 명확히 표시
- 성공/실패 피드백 즉시 제공

### 5. **상태 관리 최소화**

**이유**:
- 복잡한 상태 관리 라이브러리 불필요
- 버그 가능성 감소
- 학습 곡선 감소

**구현**:
- React useState/useEffect만 사용
- 서버 상태는 refetch로 관리
- 로컬 스토리지 최소 사용

---

## 📊 데이터 흐름

### 1. 채팅 질의 플로우

```
사용자 입력
    ↓
[Frontend] 입력 검증
    ↓
[API Client] POST /api/query_stream
    ↓
[Backend] RAG/LLM 모드 확인
    ↓
[Backend] 문서 검색 (RAG 모드인 경우)
    ↓
[Backend] LLM 질의
    ↓
[Backend] 스트리밍 응답 (SSE)
    ↓
[Frontend] 실시간 UI 업데이트
    ↓
사용자에게 표시
```

### 2. 문서 업로드 플로우

```
사용자 파일 선택
    ↓
[Frontend] 파일 검증 (크기, 형식)
    ↓
[API Client] POST /api/upload (multipart/form-data)
    ↓
[Backend] 파일 저장
    ↓
[Backend] 문서 파싱
    ↓
[Backend] 청킹
    ↓
[Backend] 임베딩 생성
    ↓
[Backend] Qdrant 저장
    ↓
[Frontend] 성공 메시지
    ↓
[Frontend] 문서 목록 갱신
```

---

## 🛡️ 안정성 보장 메커니즘

### 1. 프론트엔드 안정성

```typescript
// ✅ 모든 API 호출에 try-catch
try {
  const result = await apiClient.query(question);
  // 성공 처리
} catch (error) {
  // 사용자 친화적 에러 메시지
  setError("죄송합니다. 요청 처리 중 오류가 발생했습니다.");
}

// ✅ 로딩 상태 명확히 표시
{isLoading && <Loader2 className="animate-spin" />}
{!isLoading && <Send />}

// ✅ Null/Undefined 체크
{messages?.length > 0 && messages.map(...)}

// ✅ 기본값 제공
const stats = data?.stats || { totalDocuments: 0, totalQueries: 0 };
```

### 2. 백엔드 안정성

```python
# ✅ 모든 엔드포인트에 try-except
@app.post("/api/query_stream")
async def query_stream(...):
    try:
        # 비즈니스 로직
    except Exception as e:
        log.error(f"Error: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

# ✅ 입력 검증 (Pydantic)
class QueryRequest(BaseModel):
    question: str = Field(..., min_length=1, max_length=10000)
    mode: str = Field(..., pattern="^(rag|llm)$")

# ✅ 리소스 정리 (lifespan)
@asynccontextmanager
async def lifespan(app: FastAPI):
    # 초기화
    yield
    # 정리

# ✅ LLM 통신 안정성 (중요!)
async def query_llm_with_retry(question: str, max_retries: int = 2):
    """Ollama LLM 통신 with 타임아웃 및 재시도"""
    for attempt in range(max_retries):
        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    "http://localhost:11434/api/generate",
                    json={"model": "llama3.1:8b", "prompt": question}
                )
                return response.json()
        except httpx.TimeoutException:
            log.warning(f"Ollama 타임아웃 (시도 {attempt + 1}/{max_retries})")
            if attempt == max_retries - 1:
                raise HTTPException(status_code=504, detail="LLM 서버 응답 없음")
            await asyncio.sleep(1 * (attempt + 1))
        except httpx.ConnectError:
            log.error("Ollama 연결 실패")
            raise HTTPException(status_code=503, detail="LLM 서버 연결 불가")
        except Exception as e:
            log.error(f"LLM 에러: {e}")
            raise HTTPException(status_code=500, detail="LLM 처리 실패")
```

### 3. 통신 안정성

```typescript
// ✅ API 클라이언트 설정
const API_CONFIG = {
  timeout: 30000,  // 30초
  retries: 3,      // 3회 재시도
  retryDelay: 1000 // 1초 대기
};

// ✅ 타임아웃 처리
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 30000);

try {
  const response = await fetch(url, { signal: controller.signal });
} catch (error) {
  if (error.name === 'AbortError') {
    // 타임아웃 처리
  }
}
```

---

## 🔐 보안 고려사항

### 1. CORS 설정
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # 프로덕션에서는 실제 도메인
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 2. 파일 업로드 검증
```python
ALLOWED_EXTENSIONS = {".pdf", ".docx", ".txt", ".md", ".csv", ".xlsx"}
MAX_FILE_SIZE = 100 * 1024 * 1024  # 100MB

def validate_file(file: UploadFile):
    # 확장자 검증
    # 파일 크기 검증
    # MIME 타입 검증
```

### 3. 입력 검증
```typescript
// 프론트엔드
const MAX_QUESTION_LENGTH = 10000;
if (question.length > MAX_QUESTION_LENGTH) {
  setError("질문이 너무 깁니다.");
  return;
}

// 백엔드
class QueryRequest(BaseModel):
    question: str = Field(..., max_length=10000)
```

---

## 📈 확장성 고려사항

### 1. 수평 확장 (Scale Out)
- FastAPI: Gunicorn/Uvicorn workers 증가
- Next.js: 여러 인스턴스 + Load Balancer
- Qdrant: 클러스터 모드

### 2. 수직 확장 (Scale Up)
- 서버 리소스 증가 (CPU, RAM)
- SSD 사용 (I/O 성능 향상)
- GPU 사용 (LLM 가속)

### 3. 캐싱 전략
- Redis: 자주 조회되는 문서 목록
- CDN: 정적 파일 (Next.js 빌드 결과)
- Browser Cache: API 응답 (적절한 Cache-Control)

---

## 🧪 테스트 전략

### 1. 프론트엔드
- **단위 테스트**: Jest + React Testing Library
- **E2E 테스트**: Playwright
- **시각적 테스트**: Storybook (선택사항)

### 2. 백엔드
- **단위 테스트**: pytest
- **통합 테스트**: TestClient (FastAPI)
- **API 테스트**: Postman/Thunder Client

### 3. 통합 테스트
- **엔드-투-엔드**: 프론트엔드 → 백엔드 전체 플로우
- **성능 테스트**: 동시 사용자 시뮬레이션

---

## 📦 배포 전략

### 1. 개발 환경
```
Frontend: npm run dev (Port 3000)
Backend: python main.py (Port 8000)
```

### 2. 프로덕션 환경
```
Frontend: npm run build → npm start
Backend: gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app
```

### 3. Docker 배포 (선택사항)
```dockerfile
# frontend/Dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install && npm run build
CMD ["npm", "start"]

# backend/Dockerfile
FROM python:3.11
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## 🔄 업데이트 및 유지보수

### 1. 버전 관리
- Semantic Versioning (Major.Minor.Patch)
- Git 브랜치 전략: main, develop, feature/*

### 2. 로깅 및 모니터링
- 프론트엔드: Console errors → Sentry (선택사항)
- 백엔드: app.log + 중요 이벤트 모니터링
- 헬스체크: GET /api/health (주기적 확인)

### 3. 문서화
- API 문서: FastAPI Swagger (자동 생성)
- 사용자 매뉴얼: Markdown
- 개발자 가이드: 이 문서

---

## 🎯 성공 지표 (KPI)

### 1. 안정성
- ✅ UI 에러율: 0% 목표
- ✅ API 응답 성공률: 99.9% 이상
- ✅ 평균 응답 시간: 2초 이내

### 2. 사용성
- ✅ 직관적인 UI (사용자 테스트 필수)
- ✅ 명확한 피드백 (로딩, 성공, 실패)
- ✅ 접근성 (키보드 네비게이션, ARIA)

### 3. 유지보수성
- ✅ 코드 커버리지: 80% 이상
- ✅ 문서화 완성도: 100%
- ✅ 버그 해결 시간: 평균 24시간 이내

---

## 📌 다음 단계

1. **상세 아키텍처 다이어그램** (Mermaid) → `02_ARCHITECTURE_DIAGRAMS.md`
2. **API 명세서** → `03_API_SPECIFICATION.md`
3. **단계별 구현 가이드** → `04_IMPLEMENTATION_GUIDE.md`
4. **테스트 계획서** → `05_TEST_PLAN.md`

---

**이 설계서는 안정성, 단순성, 유지보수성을 최우선으로 합니다.**
**모든 결정은 "UI 오류 제로"라는 목표를 향합니다.** 🎯
