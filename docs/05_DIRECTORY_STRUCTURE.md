# DocuNova 디렉토리 구조 설계서

## 📋 문서 개요

**작성일**: 2025-10-30
**목적**: 안정적이고 장기적인 운영 효율성을 고려한 프로젝트 디렉토리 구조 설계
**설계 원칙**: 단순성, 명확한 책임 분리, 확장 가능성, 유지보수 용이성

---

## 🎯 디렉토리 구조 설계 원칙

### 1. 관심사의 분리 (Separation of Concerns)
- 프론트엔드와 백엔드 완전 분리
- 각 모듈의 책임 명확화
- 비즈니스 로직과 인프라 코드 분리

### 2. 확장 가능성 (Scalability)
- 새로운 기능 추가 시 기존 코드 영향 최소화
- 모듈별 독립적 개발 가능
- 마이크로서비스 전환 가능한 구조

### 3. 유지보수 용이성 (Maintainability)
- 직관적인 폴더명과 파일명
- 관련 파일들의 응집도 높임
- 문서와 코드의 위치 명확화

### 4. 보안 (Security)
- 민감한 정보 격리 (.env, secrets/)
- 업로드 파일과 소스 코드 분리
- 로그 파일 별도 관리

### 5. 개발 효율성 (Development Efficiency)
- 반복적인 작업 자동화 (scripts/)
- 개발/테스트/프로덕션 환경 분리
- 코드 재사용성 극대화

---

## 📁 전체 디렉토리 구조

```
docunova-saas/
│
├── 📂 backend/                          # 백엔드 (FastAPI)
│   ├── 📂 app/                          # 애플리케이션 코드
│   │   ├── 📂 api/                      # API 엔드포인트
│   │   │   ├── 📂 v1/                   # API 버전 1
│   │   │   │   ├── __init__.py
│   │   │   │   ├── chat.py             # 채팅 관련 API
│   │   │   │   ├── documents.py        # 문서 관리 API
│   │   │   │   ├── upload.py           # 파일 업로드 API
│   │   │   │   ├── health.py           # 헬스체크 API
│   │   │   │   └── stats.py            # 통계 API
│   │   │   └── __init__.py
│   │   │
│   │   ├── 📂 core/                     # 핵심 설정 및 유틸리티
│   │   │   ├── __init__.py
│   │   │   ├── config.py                # 환경 설정 (Pydantic Settings)
│   │   │   ├── logging.py               # 로깅 설정
│   │   │   ├── security.py              # 보안 관련
│   │   │   └── exceptions.py            # 커스텀 예외
│   │   │
│   │   ├── 📂 services/                 # 비즈니스 로직
│   │   │   ├── __init__.py
│   │   │   ├── llm_service.py           # Ollama LLM 통신 (⚠️ 에러 핸들링 강화)
│   │   │   ├── embedding_service.py     # FastEmbed 임베딩
│   │   │   ├── vector_service.py        # Qdrant 벡터 DB
│   │   │   ├── document_service.py      # 문서 처리
│   │   │   ├── chat_service.py          # 채팅 로직 (RAG/LLM 모드)
│   │   │   └── export_service.py        # 데이터 내보내기
│   │   │
│   │   ├── 📂 models/                   # 데이터 모델 (Pydantic)
│   │   │   ├── __init__.py
│   │   │   ├── request_models.py        # API 요청 모델
│   │   │   ├── response_models.py       # API 응답 모델
│   │   │   ├── document_models.py       # 문서 관련 모델
│   │   │   └── chat_models.py           # 채팅 관련 모델
│   │   │
│   │   ├── 📂 utils/                    # 유틸리티 함수
│   │   │   ├── __init__.py
│   │   │   ├── file_utils.py            # 파일 처리
│   │   │   ├── text_utils.py            # 텍스트 처리
│   │   │   ├── validators.py            # 입력 검증
│   │   │   └── helpers.py               # 공통 헬퍼 함수
│   │   │
│   │   ├── 📂 db/                       # 데이터베이스 관련
│   │   │   ├── __init__.py
│   │   │   ├── sqlite.py                # SQLite (메타데이터 저장)
│   │   │   └── qdrant_client.py         # Qdrant 클라이언트 래퍼
│   │   │
│   │   ├── 📂 middleware/               # 미들웨어
│   │   │   ├── __init__.py
│   │   │   ├── error_handler.py         # 전역 에러 핸들러
│   │   │   ├── request_logger.py        # 요청 로깅
│   │   │   └── rate_limiter.py          # 속도 제한 (선택사항)
│   │   │
│   │   └── __init__.py
│   │
│   ├── 📂 tests/                        # 테스트 코드
│   │   ├── __init__.py
│   │   ├── 📂 unit/                     # 단위 테스트
│   │   │   ├── test_llm_service.py
│   │   │   ├── test_embedding_service.py
│   │   │   └── test_document_service.py
│   │   ├── 📂 integration/              # 통합 테스트
│   │   │   ├── test_api_chat.py
│   │   │   └── test_api_upload.py
│   │   └── conftest.py                  # Pytest 설정
│   │
│   ├── 📂 scripts/                      # 스크립트
│   │   ├── init_db.py                   # DB 초기화
│   │   ├── migrate.py                   # 마이그레이션
│   │   └── seed_data.py                 # 테스트 데이터 생성
│   │
│   ├── main.py                          # FastAPI 애플리케이션 엔트리포인트
│   ├── requirements.txt                 # Python 의존성
│   ├── requirements-dev.txt             # 개발 의존성
│   ├── .env.example                     # 환경 변수 예제
│   ├── .env                             # 환경 변수 (git에서 제외)
│   ├── pytest.ini                       # Pytest 설정
│   └── README.md                        # 백엔드 문서
│
├── 📂 frontend/                         # 프론트엔드 (Next.js)
│   ├── 📂 app/                          # Next.js App Router
│   │   ├── layout.tsx                   # 루트 레이아웃
│   │   ├── page.tsx                     # 홈 페이지
│   │   ├── globals.css                  # 전역 스타일
│   │   ├── error.tsx                    # 에러 바운더리 (⚠️ 필수!)
│   │   ├── loading.tsx                  # 로딩 UI
│   │   │
│   │   ├── 📂 chat/                     # 채팅 페이지
│   │   │   ├── page.tsx
│   │   │   └── loading.tsx
│   │   │
│   │   ├── 📂 dashboard/                # 대시보드 페이지
│   │   │   └── page.tsx
│   │   │
│   │   ├── 📂 documents/                # 문서 관리 페이지
│   │   │   ├── page.tsx
│   │   │   └── [id]/                   # 동적 라우트
│   │   │       └── page.tsx
│   │   │
│   │   └── 📂 settings/                 # 설정 페이지
│   │       └── page.tsx
│   │
│   ├── 📂 components/                   # 재사용 컴포넌트
│   │   ├── 📂 ui/                       # shadcn/ui 컴포넌트
│   │   │   ├── button.tsx
│   │   │   ├── card.tsx
│   │   │   ├── input.tsx
│   │   │   ├── dialog.tsx
│   │   │   └── ... (기타 UI 컴포넌트)
│   │   │
│   │   ├── 📂 chat/                     # 채팅 관련 컴포넌트
│   │   │   ├── ChatInterface.tsx        # 채팅 인터페이스
│   │   │   ├── MessageList.tsx          # 메시지 리스트
│   │   │   ├── MessageInput.tsx         # 메시지 입력
│   │   │   └── MessageBubble.tsx        # 메시지 말풍선
│   │   │
│   │   ├── 📂 document/                 # 문서 관련 컴포넌트
│   │   │   ├── DocumentUpload.tsx       # 문서 업로드
│   │   │   ├── DocumentList.tsx         # 문서 목록
│   │   │   └── DocumentCard.tsx         # 문서 카드
│   │   │
│   │   ├── 📂 common/                   # 공통 컴포넌트
│   │   │   ├── Header.tsx               # 헤더
│   │   │   ├── Sidebar.tsx              # 사이드바
│   │   │   ├── Footer.tsx               # 푸터
│   │   │   ├── LoadingSpinner.tsx       # 로딩 스피너
│   │   │   └── ErrorMessage.tsx         # 에러 메시지
│   │   │
│   │   └── 📂 layout/                   # 레이아웃 컴포넌트
│   │       ├── MainLayout.tsx
│   │       └── AuthLayout.tsx
│   │
│   ├── 📂 lib/                          # 라이브러리 및 유틸리티
│   │   ├── api.ts                       # ⭐ API 클라이언트 (핵심!)
│   │   ├── utils.ts                     # 유틸리티 함수
│   │   ├── constants.ts                 # 상수
│   │   ├── validators.ts                # 클라이언트 검증
│   │   └── types.ts                     # TypeScript 타입 정의
│   │
│   ├── 📂 hooks/                        # 커스텀 React Hook
│   │   ├── useChat.ts                   # 채팅 Hook
│   │   ├── useDocuments.ts              # 문서 관리 Hook
│   │   ├── useUpload.ts                 # 업로드 Hook
│   │   └── useDebounce.ts               # 디바운스 Hook
│   │
│   ├── 📂 styles/                       # 스타일 (필요시)
│   │   └── custom.css
│   │
│   ├── 📂 public/                       # 정적 파일
│   │   ├── favicon.ico
│   │   ├── logo.png
│   │   └── images/
│   │
│   ├── package.json                     # Node 의존성
│   ├── package-lock.json
│   ├── next.config.mjs                  # Next.js 설정
│   ├── tailwind.config.ts               # Tailwind CSS 설정
│   ├── tsconfig.json                    # TypeScript 설정
│   ├── postcss.config.mjs               # PostCSS 설정
│   ├── .env.local.example               # 환경 변수 예제
│   ├── .env.local                       # 환경 변수 (git에서 제외)
│   └── README.md                        # 프론트엔드 문서
│
├── 📂 data/                             # 업로드된 문서 저장
│   ├── uploads/                         # 원본 파일
│   └── processed/                       # 처리된 파일
│
├── 📂 qdrant_storage/                   # Qdrant 벡터 DB 데이터
│   └── (Qdrant 자동 생성)
│
├── 📂 exports/                          # 내보내기 파일
│   ├── excel/
│   └── json/
│
├── 📂 chat_history/                     # 채팅 히스토리 (SQLite)
│   └── chat.db
│
├── 📂 logs/                             # 로그 파일
│   ├── backend/
│   │   ├── app.log
│   │   └── error.log
│   └── frontend/
│       └── next.log
│
├── 📂 docs/                             # 프로젝트 문서
│   ├── 01_SYSTEM_OVERVIEW.md
│   ├── 02_ARCHITECTURE_DIAGRAMS.md
│   ├── 03_IMPLEMENTATION_GUIDE.md
│   ├── 04_TECHNOLOGY_STACK_REVIEW.md
│   ├── 05_DIRECTORY_STRUCTURE.md        # 이 문서
│   ├── API_DOCUMENTATION.md
│   ├── USER_GUIDE.md
│   └── DEPLOYMENT_GUIDE.md
│
├── 📂 scripts/                          # 프로젝트 스크립트
│   ├── setup.sh                         # 초기 설정 (Linux/Mac)
│   ├── setup.bat                        # 초기 설정 (Windows)
│   ├── start-dev.sh                     # 개발 서버 실행
│   ├── start-dev.bat
│   ├── start-prod.sh                    # 프로덕션 서버 실행
│   ├── start-prod.bat
│   ├── backup.sh                        # 백업 스크립트
│   └── deploy.sh                        # 배포 스크립트
│
├── 📂 docker/                           # Docker 설정 (선택사항)
│   ├── backend.Dockerfile
│   ├── frontend.Dockerfile
│   └── docker-compose.yml
│
├── 📂 .vscode/                          # VS Code 설정
│   ├── settings.json
│   ├── launch.json
│   └── extensions.json
│
├── .gitignore                           # Git 제외 파일
├── README.md                            # 프로젝트 README
├── LICENSE                              # 라이선스
└── CHANGELOG.md                         # 변경 이력
```

---

## 🔍 핵심 디렉토리 상세 설명

### 1. 백엔드 구조 (`backend/`)

#### 📂 `app/api/v1/`
**목적**: API 엔드포인트를 버전별로 관리

**구조 이유**:
- API 버전 관리 용이 (v1, v2, ...)
- 기능별 라우터 분리로 코드 응집도 향상
- 새 기능 추가 시 기존 코드 영향 최소화

**파일별 책임**:
```python
# chat.py - 채팅 관련 API
@router.post("/query_stream")  # 스트리밍 채팅
@router.post("/query")          # 일반 채팅

# documents.py - 문서 관리 API
@router.get("/documents")       # 문서 목록
@router.delete("/documents/{id}") # 문서 삭제

# upload.py - 파일 업로드 API
@router.post("/upload")         # 파일 업로드

# health.py - 헬스체크 API
@router.get("/health")          # 전체 헬스체크
@router.get("/health/llm")      # LLM 헬스체크 (⚠️ 필수!)
@router.get("/health/qdrant")   # Qdrant 헬스체크

# stats.py - 통계 API
@router.get("/stats")           # 대시보드 통계
```

#### 📂 `app/core/`
**목적**: 애플리케이션 핵심 설정 및 공통 기능

**config.py** - Pydantic Settings로 환경 변수 관리:
```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Ollama 설정
    OLLAMA_HOST: str = "localhost"
    OLLAMA_PORT: int = 11434
    OLLAMA_MODEL: str = "llama3.1:8b"
    OLLAMA_TIMEOUT: int = 30

    # Qdrant 설정
    QDRANT_HOST: str = "localhost"
    QDRANT_PORT: int = 6333
    COLLECTION_NAME: str = "documents"

    # 파일 업로드 설정
    MAX_FILE_SIZE: int = 100 * 1024 * 1024  # 100MB
    ALLOWED_EXTENSIONS: set = {".pdf", ".docx", ".txt", ".md"}

    class Config:
        env_file = ".env"

settings = Settings()
```

**logging.py** - 로깅 설정:
```python
import logging
from pathlib import Path

def setup_logging():
    log_dir = Path("../logs/backend")
    log_dir.mkdir(parents=True, exist_ok=True)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler(log_dir / "app.log", encoding="utf-8"),
            logging.FileHandler(log_dir / "error.log", level=logging.ERROR)
        ]
    )
```

**exceptions.py** - 커스텀 예외:
```python
class OllamaConnectionError(Exception):
    """Ollama 연결 실패"""
    pass

class QdrantConnectionError(Exception):
    """Qdrant 연결 실패"""
    pass

class DocumentProcessingError(Exception):
    """문서 처리 실패"""
    pass
```

#### 📂 `app/services/`
**목적**: 비즈니스 로직 캡슐화

**llm_service.py** - ⚠️ 가장 중요! Ollama 통신:
```python
import httpx
import asyncio
from fastapi import HTTPException

class LLMService:
    def __init__(self, host: str, port: int, model: str):
        self.base_url = f"http://{host}:{port}"
        self.model = model

    async def query_with_retry(
        self,
        prompt: str,
        max_retries: int = 2
    ) -> dict:
        """재시도 로직 포함 LLM 질의"""
        for attempt in range(max_retries):
            try:
                async with httpx.AsyncClient(timeout=30.0) as client:
                    response = await client.post(
                        f"{self.base_url}/api/generate",
                        json={"model": self.model, "prompt": prompt}
                    )
                    response.raise_for_status()
                    return response.json()

            except httpx.TimeoutException:
                if attempt == max_retries - 1:
                    raise HTTPException(
                        status_code=504,
                        detail="LLM 응답 시간 초과"
                    )
                await asyncio.sleep(1 * (attempt + 1))

            except httpx.ConnectError:
                raise HTTPException(
                    status_code=503,
                    detail="LLM 서버 연결 불가"
                )

    async def health_check(self) -> dict:
        """LLM 헬스체크"""
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                response = await client.get(f"{self.base_url}/api/tags")
                return {"status": "healthy", "models": response.json()}
        except Exception as e:
            return {"status": "unhealthy", "error": str(e)}
```

**embedding_service.py** - FastEmbed 임베딩:
```python
from fastembed import TextEmbedding
import logging

log = logging.getLogger(__name__)

class EmbeddingService:
    def __init__(self):
        self.model = None

    async def initialize(self):
        """임베딩 모델 초기화"""
        try:
            self.model = TextEmbedding()
            log.info("✅ FastEmbed 초기화 성공")
        except Exception as e:
            log.error(f"❌ FastEmbed 초기화 실패: {e}")
            raise

    def embed_documents(self, texts: list[str]) -> list[list[float]]:
        """문서 임베딩"""
        if not self.model:
            raise RuntimeError("임베딩 모델이 초기화되지 않음")

        try:
            embeddings = list(self.model.embed(texts))
            return embeddings
        except Exception as e:
            log.error(f"임베딩 생성 실패: {e}")
            raise
```

**vector_service.py** - Qdrant 벡터 DB:
```python
from qdrant_client import QdrantClient
from qdrant_client.http.models import Distance, VectorParams

class VectorService:
    def __init__(self, host: str, port: int):
        self.client = QdrantClient(host=host, port=port)

    def create_collection(self, name: str, vector_size: int = 384):
        """컬렉션 생성"""
        self.client.create_collection(
            collection_name=name,
            vectors_config=VectorParams(
                size=vector_size,
                distance=Distance.COSINE
            )
        )

    def search(self, collection: str, query_vector: list[float], limit: int = 5):
        """벡터 검색"""
        return self.client.search(
            collection_name=collection,
            query_vector=query_vector,
            limit=limit
        )
```

**document_service.py** - 문서 처리:
```python
import pypdf
from docx import Document
from pathlib import Path

class DocumentService:
    def __init__(self, data_dir: Path):
        self.data_dir = data_dir

    def extract_text(self, file_path: Path) -> str:
        """파일에서 텍스트 추출"""
        suffix = file_path.suffix.lower()

        if suffix == ".pdf":
            return self._extract_pdf(file_path)
        elif suffix == ".docx":
            return self._extract_docx(file_path)
        elif suffix in [".txt", ".md"]:
            return file_path.read_text(encoding="utf-8")
        else:
            raise ValueError(f"지원하지 않는 파일 형식: {suffix}")

    def _extract_pdf(self, file_path: Path) -> str:
        """PDF 텍스트 추출"""
        with open(file_path, "rb") as f:
            pdf = pypdf.PdfReader(f)
            text = "\n".join([page.extract_text() for page in pdf.pages])
        return text

    def _extract_docx(self, file_path: Path) -> str:
        """DOCX 텍스트 추출"""
        doc = Document(file_path)
        text = "\n".join([para.text for para in doc.paragraphs])
        return text

    def chunk_text(
        self,
        text: str,
        chunk_size: int = 600,
        overlap: int = 250
    ) -> list[str]:
        """텍스트 청킹"""
        chunks = []
        start = 0
        while start < len(text):
            end = start + chunk_size
            chunk = text[start:end]
            chunks.append(chunk)
            start += (chunk_size - overlap)
        return chunks
```

#### 📂 `app/models/`
**목적**: Pydantic 모델로 데이터 검증

**request_models.py**:
```python
from pydantic import BaseModel, Field

class ChatRequest(BaseModel):
    question: str = Field(..., min_length=1, max_length=10000)
    mode: str = Field(..., pattern="^(rag|llm)$")
    session_id: str | None = None

class UploadRequest(BaseModel):
    file_name: str
    file_size: int = Field(..., gt=0, le=100*1024*1024)  # 최대 100MB
```

**response_models.py**:
```python
from pydantic import BaseModel
from typing import List

class ChatResponse(BaseModel):
    answer: str
    sources: List[str] = []
    session_id: str

class DocumentInfo(BaseModel):
    id: str
    filename: str
    size: int
    upload_date: str
    chunk_count: int
```

#### 📂 `app/middleware/`
**목적**: 요청/응답 처리 및 로깅

**error_handler.py**:
```python
from fastapi import Request, status
from fastapi.responses import JSONResponse
import logging

log = logging.getLogger(__name__)

async def global_exception_handler(request: Request, exc: Exception):
    """전역 예외 핸들러"""
    log.error(f"Unhandled exception: {exc}", exc_info=True)

    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "error": "Internal Server Error",
            "message": "예상치 못한 오류가 발생했습니다."
        }
    )
```

---

### 2. 프론트엔드 구조 (`frontend/`)

#### 📂 `app/`
**목적**: Next.js App Router 페이지

**layout.tsx** - 루트 레이아웃:
```typescript
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="ko">
      <body className={inter.className}>
        {children}
      </body>
    </html>
  )
}
```

**error.tsx** - ⚠️ 필수! 에러 바운더리:
```typescript
'use client';

import { useEffect } from 'react';
import { Button } from '@/components/ui/button';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error('Application error:', error);
  }, [error]);

  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h2 className="text-2xl font-bold mb-4">오류가 발생했습니다</h2>
      <p className="text-gray-600 mb-4">
        죄송합니다. 예상치 못한 오류가 발생했습니다.
      </p>
      <Button onClick={reset}>다시 시도</Button>
    </div>
  );
}
```

#### 📂 `components/`
**목적**: 재사용 가능한 컴포넌트

**구조 원칙**:
- `ui/`: shadcn/ui 기본 컴포넌트 (버튼, 카드 등)
- `chat/`: 채팅 관련 컴포넌트
- `document/`: 문서 관련 컴포넌트
- `common/`: 공통 컴포넌트 (Header, Footer 등)
- `layout/`: 레이아웃 컴포넌트

#### 📂 `lib/`
**목적**: 유틸리티 및 헬퍼 함수

**api.ts** - ⭐ 가장 중요! API 클라이언트:
```typescript
class APIClient {
  private baseURL: string;
  private timeout: number = 30000;
  private maxRetries: number = 3;

  constructor(baseURL: string) {
    this.baseURL = baseURL;
  }

  private async fetchWithRetry(
    url: string,
    options: RequestInit = {},
    retries: number = 0
  ): Promise<Response> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout);

    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal,
      });
      clearTimeout(timeoutId);

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return response;
    } catch (error: any) {
      clearTimeout(timeoutId);

      if (error.name === 'AbortError') {
        if (retries < this.maxRetries) {
          await this.delay(1000 * (retries + 1));
          return this.fetchWithRetry(url, options, retries + 1);
        }
        throw new Error('요청 시간이 초과되었습니다.');
      }

      if (retries < this.maxRetries) {
        await this.delay(1000 * (retries + 1));
        return this.fetchWithRetry(url, options, retries + 1);
      }

      throw error;
    }
  }

  async post<T>(endpoint: string, data: any): Promise<T> {
    const response = await this.fetchWithRetry(`${this.baseURL}${endpoint}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });

    return response.json();
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

export const apiClient = new APIClient('http://localhost:8000/api/v1');
```

#### 📂 `hooks/`
**목적**: 커스텀 React Hook으로 로직 재사용

**useChat.ts**:
```typescript
import { useState } from 'react';
import { apiClient } from '@/lib/api';

export function useChat() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const sendMessage = async (question: string, mode: 'rag' | 'llm') => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await apiClient.post<ChatResponse>('/query', {
        question,
        mode,
      });

      setMessages(prev => [...prev, {
        role: 'user',
        content: question,
      }, {
        role: 'assistant',
        content: response.answer,
      }]);
    } catch (err: any) {
      setError(err.message || '메시지 전송 실패');
    } finally {
      setIsLoading(false);
    }
  };

  return { messages, isLoading, error, sendMessage };
}
```

---

## 🔐 보안 고려사항

### 1. 민감한 정보 관리

**`.gitignore`**:
```
# 환경 변수
.env
.env.local
backend/.env

# 업로드된 파일
data/
uploads/

# 로그 파일
logs/
*.log

# 데이터베이스
*.db
*.sqlite
qdrant_storage/

# 내보내기 파일
exports/

# 의존성
node_modules/
venv/
__pycache__/

# 빌드 결과
.next/
dist/
build/
```

### 2. 환경 변수 관리

**backend/.env.example**:
```bash
# Ollama 설정
OLLAMA_HOST=localhost
OLLAMA_PORT=11434
OLLAMA_MODEL=llama3.1:8b
OLLAMA_TIMEOUT=30

# Qdrant 설정
QDRANT_HOST=localhost
QDRANT_PORT=6333
COLLECTION_NAME=documents

# 파일 업로드
MAX_FILE_SIZE=104857600  # 100MB
ALLOWED_EXTENSIONS=.pdf,.docx,.txt,.md

# 보안
SECRET_KEY=your-secret-key-here
```

**frontend/.env.local.example**:
```bash
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
NEXT_PUBLIC_MAX_FILE_SIZE=104857600
```

---

## 📊 파일 크기 및 용량 가이드

### 예상 디렉토리 크기

| 디렉토리 | 예상 크기 | 설명 |
|---------|----------|------|
| `backend/` | ~50MB | 코드 + 의존성 (venv 제외) |
| `frontend/` | ~500MB | node_modules 포함 |
| `data/` | 가변 | 업로드된 문서 (사용자 의존) |
| `qdrant_storage/` | 가변 | 벡터 DB (문서량 의존) |
| `logs/` | ~100MB | 로그 파일 (정기 정리 필요) |
| `exports/` | 가변 | 내보내기 파일 |

### 디스크 공간 관리

**로그 로테이션** (`backend/app/core/logging.py`):
```python
from logging.handlers import RotatingFileHandler

handler = RotatingFileHandler(
    "app.log",
    maxBytes=10*1024*1024,  # 10MB
    backupCount=5  # 최대 5개 백업
)
```

**파일 정리 스크립트** (`scripts/cleanup.sh`):
```bash
#!/bin/bash
# 30일 이상 된 로그 파일 삭제
find logs/ -name "*.log" -mtime +30 -delete

# 90일 이상 된 내보내기 파일 삭제
find exports/ -mtime +90 -delete
```

---

## 🚀 개발 워크플로우

### 1. 초기 설정

```bash
# 1. 프로젝트 클론
git clone <repository-url>
cd docunova-saas

# 2. 백엔드 설정
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# .env 파일 수정

# 3. 프론트엔드 설정
cd ../frontend
npm install
cp .env.local.example .env.local
# .env.local 파일 수정

# 4. Ollama 실행
ollama serve
ollama pull llama3.1:8b
```

### 2. 개발 서버 실행

**옵션 1: 수동 실행**
```bash
# 터미널 1: 백엔드
cd backend
source venv/bin/activate
python main.py

# 터미널 2: 프론트엔드
cd frontend
npm run dev
```

**옵션 2: 스크립트 사용**
```bash
# Linux/Mac
./scripts/start-dev.sh

# Windows
scripts\start-dev.bat
```

### 3. 테스트 실행

```bash
# 백엔드 테스트
cd backend
pytest tests/ -v

# 프론트엔드 테스트
cd frontend
npm test
```

---

## 📈 확장성 고려사항

### 1. 모듈 추가 시

**새 기능 추가 예제: 사용자 인증**

```
backend/app/
├── api/v1/
│   └── auth.py          # 새 라우터 추가
├── services/
│   └── auth_service.py  # 인증 로직
└── models/
    └── user_models.py   # 사용자 모델
```

### 2. 마이크로서비스 전환 시

현재 구조는 마이크로서비스로 쉽게 전환 가능:

```
docunova-microservices/
├── llm-service/      # LLM 통신 전담
├── vector-service/   # 벡터 DB 전담
├── document-service/ # 문서 처리 전담
├── api-gateway/      # API 게이트웨이
└── frontend/         # 프론트엔드
```

---

## 🛠️ 유지보수 가이드

### 1. 정기 점검 항목

**일일**:
- [ ] 로그 파일 확인 (`logs/backend/error.log`)
- [ ] 디스크 공간 확인

**주간**:
- [ ] 의존성 업데이트 확인
- [ ] 백업 실행
- [ ] 성능 메트릭 리뷰

**월간**:
- [ ] 로그 파일 정리
- [ ] 오래된 데이터 아카이빙
- [ ] 보안 패치 적용

### 2. 백업 전략

**백업 스크립트** (`scripts/backup.sh`):
```bash
#!/bin/bash
BACKUP_DIR="backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# 데이터 백업
cp -r data/ "$BACKUP_DIR/"
cp -r chat_history/ "$BACKUP_DIR/"
cp -r qdrant_storage/ "$BACKUP_DIR/"

# 압축
tar -czf "$BACKUP_DIR.tar.gz" "$BACKUP_DIR"
rm -rf "$BACKUP_DIR"

echo "✅ Backup completed: $BACKUP_DIR.tar.gz"
```

### 3. 모니터링

**헬스체크 엔드포인트 활용**:
```bash
# 전체 시스템 헬스체크
curl http://localhost:8000/api/v1/health

# LLM 헬스체크
curl http://localhost:8000/api/v1/health/llm

# Qdrant 헬스체크
curl http://localhost:8000/api/v1/health/qdrant
```

---

## ✅ 디렉토리 구조 체크리스트

### 초기 설정 시
- [ ] 모든 필수 디렉토리 생성됨
- [ ] `.gitignore` 설정됨
- [ ] 환경 변수 파일 설정됨
- [ ] 의존성 설치 완료

### 개발 중
- [ ] 새 파일은 적절한 디렉토리에 위치
- [ ] 관련 파일들이 함께 그룹화됨
- [ ] 테스트 파일이 함께 작성됨
- [ ] 문서가 업데이트됨

### 배포 전
- [ ] 민감한 정보 제거 확인
- [ ] 불필요한 파일 제거
- [ ] 프로덕션 설정 확인
- [ ] 백업 완료

---

## 🎯 핵심 원칙 요약

1. **단순성**: 복잡하지 않고 이해하기 쉬운 구조
2. **명확성**: 각 디렉토리와 파일의 목적이 명확함
3. **안정성**: 에러 핸들링과 로깅이 체계적
4. **확장성**: 새 기능 추가가 용이함
5. **유지보수성**: 코드 수정과 관리가 쉬움

---

**이 디렉토리 구조는 React 19 + Next.js 16, FastAPI + Pydantic 2, Ollama 통합 등 모든 기술 스택 호환성을 고려하여 설계되었습니다.**

**관련 문서**:
- `01_SYSTEM_OVERVIEW.md` - 시스템 전체 아키텍처
- `03_IMPLEMENTATION_GUIDE.md` - 단계별 구현 가이드
- `04_TECHNOLOGY_STACK_REVIEW.md` - 기술 스택 호환성 검토

**안정적이고 장기적인 운영을 위해 이 구조를 따라주세요!** 🚀
