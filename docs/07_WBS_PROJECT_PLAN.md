# DocuNova 프로젝트 WBS (Work Breakdown Structure)

## 📋 문서 개요

**작성일**: 2025-10-30
**프로젝트명**: DocuNova SaaS 개발
**총 예상 기간**: 4주 (160시간)
**목적**: 효율적인 작업 세분화 및 일정 관리

---

## 🎯 프로젝트 목표

1. **안정적인 RAG 기반 문서 AI 어시스턴트 개발**
2. **UI 오류 제로 달성**
3. **확장 가능하고 유지보수 용이한 구조**
4. **4주 내 프로덕션 배포 준비 완료**

---

## 📊 WBS 구조 개요

```
DocuNova SaaS 프로젝트
├── Phase 1: 프로젝트 초기화 및 환경 설정 (Week 1)
├── Phase 2: 백엔드 개발 (Week 1-2)
├── Phase 3: 프론트엔드 개발 (Week 2-3)
├── Phase 4: 통합 및 테스트 (Week 3-4)
└── Phase 5: 배포 및 문서화 (Week 4)
```

---

## 📅 Phase 1: 프로젝트 초기화 및 환경 설정

**기간**: 3일 (24시간)
**병렬 처리**: 가능 (백엔드/프론트엔드 동시 진행)

### 1.1 프로젝트 구조 생성

**WBS 코드**: 1.1
**작업 시간**: 2시간
**담당**: DevOps
**선행 작업**: 없음
**병렬 처리**: ✅ 가능

#### 작업 내용:
```bash
# 작업 1.1.1: 프로젝트 루트 생성 (15분)
mkdir docunova-saas
cd docunova-saas

# 작업 1.1.2: Git 초기화 (15분)
git init
cp <architecture-docs>/.gitignore .

# 작업 1.1.3: 디렉토리 구조 생성 (30분)
mkdir -p backend/app/{api/v1,core,services,models,utils,db,middleware}
mkdir -p frontend/{app,components,lib,hooks,public}
mkdir -p data/{uploads,processed}
mkdir -p logs/{backend,frontend}
mkdir -p docs scripts

# 작업 1.1.4: README 및 문서 복사 (30분)
cp <architecture-docs>/* docs/
```

**체크리스트**:
- [ ] Git 저장소 초기화
- [ ] 기본 디렉토리 구조 생성
- [ ] .gitignore 설정
- [ ] README.md 생성

---

### 1.2 백엔드 환경 설정

**WBS 코드**: 1.2
**작업 시간**: 4시간
**담당**: Backend Developer
**선행 작업**: 1.1
**병렬 처리**: ✅ 1.3과 동시 진행 가능

#### 작업 1.2.1: Python 가상환경 설정 (30분)

```bash
cd backend
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate
```

**체크리스트**:
- [ ] Python 3.11 설치 확인
- [ ] 가상환경 생성
- [ ] 가상환경 활성화

#### 작업 1.2.2: 의존성 설치 (30분)

```bash
# requirements.txt 생성
pip install fastapi==0.115.0
pip install uvicorn==0.30.6
pip install qdrant-client==1.12.1
pip install fastembed==0.3.2
# ... (전체 목록)

pip freeze > requirements.txt

# 개발 의존성
pip install -r requirements-dev.txt
```

**체크리스트**:
- [ ] requirements.txt 생성
- [ ] requirements-dev.txt 생성
- [ ] 모든 패키지 설치 완료

#### 작업 1.2.3: 개발 환경 설정 (1시간)

```bash
# pyproject.toml 생성 (Black, isort, mypy 설정)
# .pre-commit-config.yaml 생성
pre-commit install
```

**체크리스트**:
- [ ] pyproject.toml 생성
- [ ] .pre-commit-config.yaml 생성
- [ ] pre-commit hooks 설치
- [ ] Black, isort, Ruff, mypy 설정 완료

#### 작업 1.2.4: 환경 변수 설정 (30분)

```bash
# .env.example 생성
cp .env.example .env
# .env 파일 수정
```

**체크리스트**:
- [ ] .env.example 생성
- [ ] .env 생성 및 설정
- [ ] Ollama 연결 정보 설정
- [ ] Qdrant 연결 정보 설정

#### 작업 1.2.5: VS Code 설정 (30분)

```bash
mkdir .vscode
# settings.json 생성
```

**체크리스트**:
- [ ] .vscode/settings.json 생성
- [ ] Python interpreter 설정
- [ ] Linting 설정 확인

#### 작업 1.2.6: Ollama 설치 및 모델 다운로드 (1시간)

```bash
# Ollama 설치 (플랫폼별)
# Windows: 설치 프로그램 실행
# Linux/Mac: curl 명령어

ollama serve  # 백그라운드 실행
ollama pull llama3.1:8b
ollama list  # 모델 확인
```

**체크리스트**:
- [ ] Ollama 설치
- [ ] llama3.1:8b 모델 다운로드
- [ ] Ollama 서버 실행 확인 (port 11434)
- [ ] 모델 테스트

---

### 1.3 프론트엔드 환경 설정

**WBS 코드**: 1.3
**작업 시간**: 4시간
**담당**: Frontend Developer
**선행 작업**: 1.1
**병렬 처리**: ✅ 1.2와 동시 진행 가능

#### 작업 1.3.1: Next.js 프로젝트 생성 (30분)

```bash
cd frontend
npx create-next-app@latest . --typescript --tailwind --app --no-src-dir --import-alias "@/*"
```

**체크리스트**:
- [ ] Next.js 16 설치
- [ ] TypeScript 설정
- [ ] Tailwind CSS 설정
- [ ] App Router 구조 확인

#### 작업 1.3.2: UI 라이브러리 설치 (30분)

```bash
# shadcn/ui 초기화
npx shadcn@latest init

# 필요한 컴포넌트 설치
npx shadcn@latest add button card input dialog
npx shadcn@latest add alert toast tabs
```

**체크리스트**:
- [ ] shadcn/ui 초기화
- [ ] 기본 UI 컴포넌트 설치
- [ ] lucide-react 설치 확인

#### 작업 1.3.3: 개발 도구 설치 (1시간)

```bash
npm install --save-dev \
  @typescript-eslint/eslint-plugin \
  @typescript-eslint/parser \
  prettier \
  prettier-plugin-tailwindcss \
  husky \
  lint-staged
```

**체크리스트**:
- [ ] ESLint 플러그인 설치
- [ ] Prettier 설치
- [ ] Husky 설치
- [ ] lint-staged 설치

#### 작업 1.3.4: 개발 환경 설정 (1.5시간)

```bash
# tsconfig.json 수정 (jsx: "preserve")
# .eslintrc.json 생성 (엄격한 규칙)
# .prettierrc.json 생성
# .lintstagedrc.json 생성
# next.config.mjs 수정 (보안 헤더, CORS)

npx husky install
npx husky add .husky/pre-commit "npx lint-staged"
```

**체크리스트**:
- [ ] tsconfig.json 수정 완료
- [ ] .eslintrc.json 생성
- [ ] .prettierrc.json 생성
- [ ] next.config.mjs 보안 설정
- [ ] Husky pre-commit hooks 설정

#### 작업 1.3.5: 환경 변수 설정 (30min)

```bash
# .env.local.example 생성
cp .env.local.example .env.local
# API URL 설정
```

**체크리스트**:
- [ ] .env.local.example 생성
- [ ] .env.local 생성
- [ ] NEXT_PUBLIC_API_URL 설정

---

### 1.4 Qdrant 설정

**WBS 코드**: 1.4
**작업 시간**: 1시간
**담당**: Backend Developer
**선행 작업**: 1.2.2
**병렬 처리**: ✅ 1.3과 동시 진행 가능

#### 작업 내용:

```bash
# Docker로 Qdrant 실행
docker run -p 6333:6333 qdrant/qdrant

# 또는 로컬 모드 (Python 코드에서)
# QdrantClient(path="./qdrant_storage")
```

**체크리스트**:
- [ ] Qdrant 서버 실행 (Docker 또는 로컬)
- [ ] 포트 6333 확인
- [ ] 웹 UI 접속 테스트 (http://localhost:6333/dashboard)
- [ ] 컬렉션 생성 테스트

---

### 1.5 초기 테스트 및 검증

**WBS 코드**: 1.5
**작업 시간**: 2시간
**담당**: 전체 팀
**선행 작업**: 1.2, 1.3, 1.4
**병렬 처리**: ❌ 순차 진행 필요

#### 작업 1.5.1: 백엔드 헬스체크 (30분)

```bash
cd backend
python -c "import fastapi; print('FastAPI OK')"
python -c "import qdrant_client; print('Qdrant OK')"
python -c "import fastembed; print('FastEmbed OK')"

# Ollama 테스트
curl http://localhost:11434/api/tags
```

**체크리스트**:
- [ ] 모든 패키지 import 성공
- [ ] Ollama 연결 확인
- [ ] Qdrant 연결 확인

#### 작업 1.5.2: 프론트엔드 빌드 테스트 (30분)

```bash
cd frontend
npm run type-check  # TypeScript 체크
npm run lint        # ESLint 체크
npm run build       # 빌드 테스트
```

**체크리스트**:
- [ ] TypeScript 에러 0개
- [ ] ESLint 에러 0개
- [ ] 빌드 성공

#### 작업 1.5.3: Git 커밋 테스트 (30분)

```bash
git add .
git commit -m "chore: initial project setup"
# pre-commit hooks 자동 실행 확인
```

**체크리스트**:
- [ ] Pre-commit hooks 정상 작동
- [ ] 코드 자동 포맷팅 확인
- [ ] 커밋 성공

#### 작업 1.5.4: 문서 정리 (30분)

**체크리스트**:
- [ ] 환경 설정 문서 업데이트
- [ ] 팀원에게 설정 공유
- [ ] 문제 해결 가이드 작성

---

## 📅 Phase 2: 백엔드 개발

**기간**: 1.5주 (60시간)
**병렬 처리**: 부분적으로 가능

### 2.1 핵심 설정 및 유틸리티

**WBS 코드**: 2.1
**작업 시간**: 8시간
**담당**: Backend Developer
**선행 작업**: 1.5
**병렬 처리**: ❌ 순차 진행 (기반 작업)

#### 작업 2.1.1: 설정 모듈 (2시간)

**파일**: `backend/app/core/config.py`

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

    # 파일 업로드
    MAX_FILE_SIZE: int = 100 * 1024 * 1024
    ALLOWED_EXTENSIONS: set = {".pdf", ".docx", ".txt", ".md"}

    class Config:
        env_file = ".env"

settings = Settings()
```

**체크리스트**:
- [ ] Pydantic Settings 구현
- [ ] 환경 변수 매핑
- [ ] 타입 힌트 추가
- [ ] 단위 테스트 작성

#### 작업 2.1.2: 로깅 설정 (1시간)

**파일**: `backend/app/core/logging.py`

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

**체크리스트**:
- [ ] 로그 디렉토리 자동 생성
- [ ] 파일 및 콘솔 로깅
- [ ] 에러 로그 분리
- [ ] 로그 레벨 설정

#### 작업 2.1.3: 예외 처리 (2시간)

**파일**: `backend/app/core/exceptions.py`

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

**체크리스트**:
- [ ] 커스텀 예외 클래스 정의
- [ ] 예외 메시지 명확화
- [ ] 문서화 (docstring)

#### 작업 2.1.4: 유틸리티 함수 (3시간)

**파일**: `backend/app/utils/file_utils.py`, `text_utils.py`, `validators.py`

```python
# file_utils.py
def validate_file_extension(filename: str) -> bool:
    """파일 확장자 검증"""
    pass

def get_file_size(file_path: Path) -> int:
    """파일 크기 반환"""
    pass

# text_utils.py
def chunk_text(text: str, size: int, overlap: int) -> list[str]:
    """텍스트 청킹"""
    pass

# validators.py
def validate_question(question: str) -> bool:
    """질문 유효성 검사"""
    pass
```

**체크리스트**:
- [ ] 파일 유틸리티 구현
- [ ] 텍스트 처리 유틸리티 구현
- [ ] 검증 함수 구현
- [ ] 단위 테스트 작성

---

### 2.2 서비스 레이어 개발

**WBS 코드**: 2.2
**작업 시간**: 20시간
**담당**: Backend Developer
**선행 작업**: 2.1
**병렬 처리**: ⚠️ 부분적 가능 (2.2.1-2.2.3은 순차, 2.2.4는 병렬)

#### 작업 2.2.1: LLM 서비스 (6시간) ⭐ 가장 중요!

**파일**: `backend/app/services/llm_service.py`

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
                    raise HTTPException(status_code=504, detail="LLM 응답 시간 초과")
                await asyncio.sleep(1 * (attempt + 1))

            except httpx.ConnectError:
                raise HTTPException(status_code=503, detail="LLM 서버 연결 불가")

    async def health_check(self) -> dict:
        """LLM 헬스체크"""
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                response = await client.get(f"{self.base_url}/api/tags")
                return {"status": "healthy", "models": response.json()}
        except Exception as e:
            return {"status": "unhealthy", "error": str(e)}
```

**체크리스트**:
- [ ] LLMService 클래스 구현
- [ ] query_with_retry 메서드 (타임아웃, 재시도)
- [ ] health_check 메서드
- [ ] 에러 핸들링 완벽 구현
- [ ] 통합 테스트 (실제 Ollama와 연동)
- [ ] 타입 힌트 및 docstring

#### 작업 2.2.2: 임베딩 서비스 (4시간)

**파일**: `backend/app/services/embedding_service.py`

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

**체크리스트**:
- [ ] EmbeddingService 클래스 구현
- [ ] initialize 메서드
- [ ] embed_documents 메서드
- [ ] 에러 핸들링
- [ ] 단위 테스트

#### 작업 2.2.3: 벡터 DB 서비스 (4시간)

**파일**: `backend/app/services/vector_service.py`

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

    def upsert_documents(self, collection: str, points: list):
        """문서 업서트"""
        self.client.upsert(collection_name=collection, points=points)

    def search(self, collection: str, query_vector: list[float], limit: int = 5):
        """벡터 검색"""
        return self.client.search(
            collection_name=collection,
            query_vector=query_vector,
            limit=limit
        )
```

**체크리스트**:
- [ ] VectorService 클래스 구현
- [ ] create_collection 메서드
- [ ] upsert_documents 메서드
- [ ] search 메서드
- [ ] 통합 테스트

#### 작업 2.2.4: 문서 처리 서비스 (6시간)

**파일**: `backend/app/services/document_service.py`

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

**체크리스트**:
- [ ] DocumentService 클래스 구현
- [ ] extract_text 메서드 (PDF, DOCX, TXT)
- [ ] chunk_text 메서드
- [ ] 파일 형식별 처리 로직
- [ ] 단위 테스트 (샘플 파일로)

---

### 2.3 API 라우터 개발

**WBS 코드**: 2.3
**작업 시간**: 16시간
**담당**: Backend Developer
**선행 작업**: 2.2
**병렬 처리**: ✅ 각 라우터는 독립적으로 개발 가능

#### 작업 2.3.1: 헬스체크 API (2시간)

**파일**: `backend/app/api/v1/health.py`

```python
from fastapi import APIRouter

router = APIRouter(prefix="/health", tags=["health"])

@router.get("/")
async def health_check():
    """전체 헬스체크"""
    return {"status": "healthy"}

@router.get("/llm")
async def llm_health():
    """LLM 헬스체크"""
    # LLMService.health_check() 호출
    pass

@router.get("/qdrant")
async def qdrant_health():
    """Qdrant 헬스체크"""
    pass
```

**체크리스트**:
- [ ] 라우터 구현
- [ ] 각 서비스 헬스체크
- [ ] 응답 모델 정의
- [ ] API 테스트

#### 작업 2.3.2: 문서 업로드 API (4시간)

**파일**: `backend/app/api/v1/upload.py`

```python
from fastapi import APIRouter, UploadFile, File, HTTPException

router = APIRouter(prefix="/upload", tags=["upload"])

@router.post("/")
async def upload_document(file: UploadFile = File(...)):
    """파일 업로드 및 임베딩 생성"""
    # 1. 파일 검증
    # 2. 파일 저장
    # 3. 텍스트 추출
    # 4. 청킹
    # 5. 임베딩 생성
    # 6. Qdrant 저장
    pass
```

**체크리스트**:
- [ ] 파일 업로드 엔드포인트
- [ ] 파일 검증 (크기, 형식)
- [ ] 문서 처리 파이프라인
- [ ] 에러 핸들링
- [ ] API 테스트 (Postman/Thunder Client)

#### 작업 2.3.3: 문서 관리 API (3시간)

**파일**: `backend/app/api/v1/documents.py`

```python
from fastapi import APIRouter

router = APIRouter(prefix="/documents", tags=["documents"])

@router.get("/")
async def list_documents():
    """문서 목록 조회"""
    pass

@router.delete("/{document_id}")
async def delete_document(document_id: str):
    """문서 삭제"""
    pass
```

**체크리스트**:
- [ ] 문서 목록 조회
- [ ] 문서 삭제
- [ ] 응답 모델 정의
- [ ] API 테스트

#### 작업 2.3.4: 채팅 API (5시간) ⭐ 가장 중요!

**파일**: `backend/app/api/v1/chat.py`

```python
from fastapi import APIRouter
from fastapi.responses import StreamingResponse

router = APIRouter(prefix="/chat", tags=["chat"])

@router.post("/query")
async def query(request: ChatRequest):
    """일반 채팅 (비스트리밍)"""
    # 1. 질문 검증
    # 2. RAG/LLM 모드 확인
    # 3. RAG: 벡터 검색 → 컨텍스트 생성
    # 4. LLM 질의
    # 5. 응답 반환
    pass

@router.post("/query_stream")
async def query_stream(request: ChatRequest):
    """스트리밍 채팅"""
    async def generate():
        # SSE 스트리밍 응답
        pass

    return StreamingResponse(generate(), media_type="text/event-stream")
```

**체크리스트**:
- [ ] 일반 채팅 엔드포인트
- [ ] 스트리밍 채팅 엔드포인트
- [ ] RAG 모드 구현
- [ ] LLM 모드 구현
- [ ] 요청/응답 모델 정의
- [ ] 에러 핸들링
- [ ] API 테스트

#### 작업 2.3.5: 통계 API (2시간)

**파일**: `backend/app/api/v1/stats.py`

```python
from fastapi import APIRouter

router = APIRouter(prefix="/stats", tags=["stats"])

@router.get("/")
async def get_stats():
    """대시보드 통계"""
    return {
        "total_documents": 0,
        "total_queries": 0,
        "storage_used": "0 MB"
    }
```

**체크리스트**:
- [ ] 통계 조회 엔드포인트
- [ ] 응답 모델 정의
- [ ] API 테스트

---

### 2.4 메인 애플리케이션 및 미들웨어

**WBS 코드**: 2.4
**작업 시간**: 8시간
**담당**: Backend Developer
**선행 작업**: 2.3
**병렬 처리**: ❌ 순차 진행

#### 작업 2.4.1: 메인 애플리케이션 (4시간)

**파일**: `backend/main.py`

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 초기화
    log.info("🚀 Starting DocuNova API Server...")
    await embedding_service.initialize()
    await llm_service.health_check()
    yield
    # 정리
    log.info("🛑 Shutting down DocuNova API Server...")

app = FastAPI(
    title="DocuNova API",
    version="1.0.0",
    lifespan=lifespan
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 라우터 등록
app.include_router(health_router, prefix="/api/v1")
app.include_router(upload_router, prefix="/api/v1")
app.include_router(documents_router, prefix="/api/v1")
app.include_router(chat_router, prefix="/api/v1")
app.include_router(stats_router, prefix="/api/v1")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

**체크리스트**:
- [ ] FastAPI 애플리케이션 생성
- [ ] Lifespan 이벤트 구현
- [ ] CORS 설정
- [ ] 모든 라우터 등록
- [ ] 서버 실행 테스트

#### 작업 2.4.2: 미들웨어 (2시간)

**파일**: `backend/app/middleware/error_handler.py`, `request_logger.py`

```python
# error_handler.py
async def global_exception_handler(request, exc):
    log.error(f"Unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"error": "Internal Server Error"}
    )

# request_logger.py
async def log_requests(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    duration = time.time() - start_time
    log.info(f"{request.method} {request.url.path} - {response.status_code} - {duration:.2f}s")
    return response
```

**체크리스트**:
- [ ] 전역 예외 핸들러
- [ ] 요청 로깅 미들웨어
- [ ] 미들웨어 등록
- [ ] 테스트

#### 작업 2.4.3: Pydantic 모델 (2시간)

**파일**: `backend/app/models/*.py`

```python
from pydantic import BaseModel, Field

class ChatRequest(BaseModel):
    question: str = Field(..., min_length=1, max_length=10000)
    mode: str = Field(..., pattern="^(rag|llm)$")

class ChatResponse(BaseModel):
    answer: str
    sources: list[str] = []

class DocumentInfo(BaseModel):
    id: str
    filename: str
    size: int
    upload_date: str
```

**체크리스트**:
- [ ] 요청 모델 정의
- [ ] 응답 모델 정의
- [ ] 검증 규칙 추가
- [ ] 문서화 (description)

---

### 2.5 백엔드 테스트

**WBS 코드**: 2.5
**작업 시간**: 8시간
**담당**: Backend Developer
**선행 작업**: 2.4
**병렬 처리**: ✅ 단위/통합 테스트 병렬 가능

#### 작업 2.5.1: 단위 테스트 (4시간)

**파일**: `backend/tests/unit/*.py`

```python
# tests/unit/test_llm_service.py
async def test_llm_query_success():
    service = LLMService("localhost", 11434, "llama3.1:8b")
    result = await service.query_with_retry("Hello")
    assert result is not None

# tests/unit/test_document_service.py
def test_extract_text_pdf():
    service = DocumentService(Path("./data"))
    text = service.extract_text(Path("test.pdf"))
    assert len(text) > 0
```

**체크리스트**:
- [ ] LLM 서비스 테스트
- [ ] 임베딩 서비스 테스트
- [ ] 벡터 서비스 테스트
- [ ] 문서 서비스 테스트
- [ ] 유틸리티 테스트
- [ ] 커버리지 70% 이상

#### 작업 2.5.2: 통합 테스트 (4시간)

**파일**: `backend/tests/integration/*.py`

```python
# tests/integration/test_api.py
def test_upload_document(client):
    with open("test.pdf", "rb") as f:
        response = client.post(
            "/api/v1/upload",
            files={"file": ("test.pdf", f, "application/pdf")}
        )
    assert response.status_code == 200

def test_chat_query(client):
    response = client.post(
        "/api/v1/chat/query",
        json={"question": "테스트", "mode": "llm"}
    )
    assert response.status_code == 200
```

**체크리스트**:
- [ ] API 엔드포인트 테스트
- [ ] 파일 업로드 테스트
- [ ] 채팅 기능 테스트
- [ ] 에러 케이스 테스트
- [ ] 전체 플로우 테스트

---

## 📅 Phase 3: 프론트엔드 개발

**기간**: 1.5주 (60시간)
**병렬 처리**: ✅ 페이지별 병렬 개발 가능

### 3.1 공통 컴포넌트 및 라이브러리

**WBS 코드**: 3.1
**작업 시간**: 12시간
**담당**: Frontend Developer
**선행 작업**: 1.5
**병렬 처리**: ⚠️ API Client는 우선, 나머지는 병렬

#### 작업 3.1.1: API 클라이언트 (4시간) ⭐ 가장 중요!

**파일**: `frontend/lib/api.ts`

```typescript
class APIClient {
  private baseURL: string;
  private timeout: number = 30000;
  private maxRetries: number = 3;

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

export const apiClient = new APIClient(
  process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api/v1'
);
```

**체크리스트**:
- [ ] APIClient 클래스 구현
- [ ] fetchWithRetry (타임아웃, 재시도)
- [ ] get, post, delete 메서드
- [ ] 에러 핸들링
- [ ] 타입 정의
- [ ] 단위 테스트

#### 작업 3.1.2: 커스텀 Hooks (4시간)

**파일**: `frontend/hooks/*.ts`

```typescript
// useChat.ts
export function useChat() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const sendMessage = async (question: string, mode: 'rag' | 'llm') => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await apiClient.post<ChatResponse>('/chat/query', {
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

// useDocuments.ts
// useUpload.ts
// useDebounce.ts
```

**체크리스트**:
- [ ] useChat Hook
- [ ] useDocuments Hook
- [ ] useUpload Hook
- [ ] useDebounce Hook
- [ ] 타입 정의
- [ ] 테스트

#### 작업 3.1.3: 공통 UI 컴포넌트 (4시간)

**파일**: `frontend/components/common/*.tsx`

```typescript
// Header.tsx
export function Header() {
  return (
    <header className="border-b">
      <nav>
        <Link href="/chat">채팅</Link>
        <Link href="/documents">문서</Link>
        <Link href="/dashboard">대시보드</Link>
      </nav>
    </header>
  );
}

// LoadingSpinner.tsx
// ErrorMessage.tsx
// Footer.tsx
```

**체크리스트**:
- [ ] Header 컴포넌트
- [ ] Footer 컴포넌트
- [ ] LoadingSpinner 컴포넌트
- [ ] ErrorMessage 컴포넌트
- [ ] 반응형 디자인

---

### 3.2 페이지 개발

**WBS 코드**: 3.2
**작업 시간**: 32시간
**담당**: Frontend Developer
**선행 작업**: 3.1
**병렬 처리**: ✅ 각 페이지는 독립적으로 개발 가능

#### 작업 3.2.1: 레이아웃 및 에러 바운더리 (4시간)

**파일**: `frontend/app/layout.tsx`, `error.tsx`

```typescript
// layout.tsx
export default function RootLayout({ children }) {
  return (
    <html lang="ko">
      <body>
        <Header />
        {children}
        <Footer />
      </body>
    </html>
  );
}

// error.tsx ⚠️ 필수!
'use client';

export default function Error({ error, reset }) {
  useEffect(() => {
    console.error('Application error:', error);
  }, [error]);

  return (
    <div>
      <h2>오류가 발생했습니다</h2>
      <Button onClick={reset}>다시 시도</Button>
    </div>
  );
}
```

**체크리스트**:
- [ ] 루트 레이아웃 구현
- [ ] 에러 바운더리 구현 (⚠️ 필수!)
- [ ] loading.tsx 구현
- [ ] 전역 스타일 적용

#### 작업 3.2.2: 홈 페이지 (4시간)

**파일**: `frontend/app/page.tsx`

```typescript
export default function HomePage() {
  return (
    <div className="container mx-auto py-12">
      <h1 className="text-4xl font-bold">DocuNova</h1>
      <p className="text-xl mt-4">AI 기반 문서 어시스턴트</p>
      <div className="mt-8 grid grid-cols-3 gap-4">
        <Card>
          <CardHeader>채팅</CardHeader>
          <CardContent>문서에 대해 질문하세요</CardContent>
        </Card>
        {/* ... */}
      </div>
    </div>
  );
}
```

**체크리스트**:
- [ ] 랜딩 페이지 디자인
- [ ] 주요 기능 소개
- [ ] CTA 버튼
- [ ] 반응형 디자인

#### 작업 3.2.3: 채팅 페이지 (12시간) ⭐ 가장 중요!

**파일**: `frontend/app/chat/page.tsx`, `frontend/components/chat/*.tsx`

```typescript
// app/chat/page.tsx
export default function ChatPage() {
  const { messages, isLoading, error, sendMessage } = useChat();

  return (
    <div className="container mx-auto h-screen flex flex-col">
      <MessageList messages={messages} />
      <MessageInput onSend={sendMessage} isLoading={isLoading} />
      {error && <ErrorMessage message={error} />}
    </div>
  );
}

// components/chat/MessageList.tsx
export function MessageList({ messages }: { messages: Message[] }) {
  return (
    <div className="flex-1 overflow-y-auto">
      {messages.map((msg, i) => (
        <MessageBubble key={i} message={msg} />
      ))}
    </div>
  );
}

// components/chat/MessageInput.tsx
// components/chat/MessageBubble.tsx
```

**체크리스트**:
- [ ] ChatInterface 컴포넌트
- [ ] MessageList 컴포넌트
- [ ] MessageInput 컴포넌트
- [ ] MessageBubble 컴포넌트
- [ ] RAG/LLM 모드 토글
- [ ] 스트리밍 응답 처리
- [ ] 로딩 상태 표시
- [ ] 에러 핸들링
- [ ] 반응형 디자인

#### 작업 3.2.4: 문서 관리 페이지 (8시간)

**파일**: `frontend/app/documents/page.tsx`, `frontend/components/document/*.tsx`

```typescript
// app/documents/page.tsx
export default function DocumentsPage() {
  const { documents, isLoading, error } = useDocuments();
  const { upload, isUploading } = useUpload();

  return (
    <div className="container mx-auto py-8">
      <DocumentUpload onUpload={upload} isLoading={isUploading} />
      <DocumentList documents={documents} isLoading={isLoading} />
      {error && <ErrorMessage message={error} />}
    </div>
  );
}

// components/document/DocumentUpload.tsx
// components/document/DocumentList.tsx
// components/document/DocumentCard.tsx
```

**체크리스트**:
- [ ] DocumentUpload 컴포넌트
- [ ] DocumentList 컴포넌트
- [ ] DocumentCard 컴포넌트
- [ ] 파일 업로드 (드래그 앤 드롭)
- [ ] 업로드 진행률
- [ ] 문서 삭제
- [ ] 문서 정보 표시

#### 작업 3.2.5: 대시보드 페이지 (4시간)

**파일**: `frontend/app/dashboard/page.tsx`

```typescript
export default function DashboardPage() {
  const [stats, setStats] = useState<Stats | null>(null);

  useEffect(() => {
    apiClient.get<Stats>('/stats').then(setStats);
  }, []);

  if (!stats) return <LoadingSpinner />;

  return (
    <div className="container mx-auto py-8">
      <h1 className="text-3xl font-bold mb-8">대시보드</h1>
      <div className="grid grid-cols-3 gap-4">
        <Card>
          <CardHeader>총 문서</CardHeader>
          <CardContent>{stats.total_documents}</CardContent>
        </Card>
        {/* ... */}
      </div>
    </div>
  );
}
```

**체크리스트**:
- [ ] 통계 카드 표시
- [ ] 차트 (선택사항)
- [ ] 최근 활동
- [ ] 반응형 디자인

---

### 3.3 프론트엔드 테스트 및 최적화

**WBS 코드**: 3.3
**작업 시간**: 16시간
**담당**: Frontend Developer
**선행 작업**: 3.2
**병렬 처리**: ✅ 테스트와 최적화 병렬 가능

#### 작업 3.3.1: 컴포넌트 테스트 (8시간)

```typescript
// components/chat/MessageBubble.test.tsx
describe('MessageBubble', () => {
  it('renders user message correctly', () => {
    render(<MessageBubble message={{ role: 'user', content: 'Hello' }} />);
    expect(screen.getByText('Hello')).toBeInTheDocument();
  });
});
```

**체크리스트**:
- [ ] API 클라이언트 테스트
- [ ] Hook 테스트
- [ ] 컴포넌트 테스트
- [ ] 커버리지 70% 이상

#### 작업 3.3.2: E2E 테스트 (4시간)

```typescript
// e2e/chat.spec.ts
test('chat flow', async ({ page }) => {
  await page.goto('/chat');
  await page.fill('input', '테스트 질문');
  await page.click('button[type="submit"]');
  await expect(page.locator('.message-bubble')).toBeVisible();
});
```

**체크리스트**:
- [ ] 채팅 플로우 테스트
- [ ] 문서 업로드 플로우 테스트
- [ ] 에러 케이스 테스트

#### 작업 3.3.3: 성능 최적화 (4시간)

**체크리스트**:
- [ ] 이미지 최적화 (Next.js Image)
- [ ] 코드 스플리팅
- [ ] React.memo 적용
- [ ] useMemo, useCallback 최적화
- [ ] Lighthouse 점수 90+ 달성

---

## 📅 Phase 4: 통합 및 테스트

**기간**: 1주 (40시간)
**병렬 처리**: ❌ 대부분 순차 진행

### 4.1 백엔드-프론트엔드 통합

**WBS 코드**: 4.1
**작업 시간**: 16시간
**담당**: 전체 팀
**선행 작업**: 2.5, 3.3
**병렬 처리**: ❌ 순차 진행

#### 작업 4.1.1: 로컬 통합 테스트 (8시간)

```bash
# 터미널 1: 백엔드
cd backend
python main.py

# 터미널 2: 프론트엔드
cd frontend
npm run dev

# 브라우저: http://localhost:3000
```

**테스트 시나리오**:
1. 문서 업로드
2. RAG 모드 채팅
3. LLM 모드 채팅
4. 문서 삭제
5. 대시보드 확인

**체크리스트**:
- [ ] 문서 업로드 정상 작동
- [ ] 채팅 정상 작동 (RAG/LLM)
- [ ] 문서 삭제 정상 작동
- [ ] 통계 표시 정상 작동
- [ ] 에러 핸들링 확인
- [ ] CORS 이슈 없음

#### 작업 4.1.2: 버그 수정 (8시간)

**발견된 버그 분류 및 수정**

**체크리스트**:
- [ ] 모든 critical 버그 수정
- [ ] UI 오류 0개
- [ ] API 에러 핸들링 완벽
- [ ] 재테스트 완료

---

### 4.2 성능 테스트

**WBS 코드**: 4.2
**작업 시간**: 8시간
**담당**: Backend Developer
**선행 작업**: 4.1
**병렬 처리**: ❌ 순차 진행

#### 작업 4.2.1: 부하 테스트 (4시간)

```python
# 동시 사용자 시뮬레이션
from locust import HttpUser, task

class DocuNovaUser(HttpUser):
    @task
    def chat(self):
        self.client.post("/api/v1/chat/query", json={
            "question": "테스트",
            "mode": "llm"
        })
```

**체크리스트**:
- [ ] 10명 동시 사용자 테스트
- [ ] 50명 동시 사용자 테스트
- [ ] 응답 시간 2초 이내
- [ ] 에러율 1% 이하

#### 작업 4.2.2: 성능 최적화 (4시간)

**체크리스트**:
- [ ] 병목 지점 식별
- [ ] 캐싱 전략 적용
- [ ] 데이터베이스 쿼리 최적화
- [ ] 재테스트 및 검증

---

### 4.3 보안 테스트

**WBS 코드**: 4.3
**작업 시간**: 8시간
**담당**: 전체 팀
**선행 작업**: 4.2
**병렬 처리**: ✅ 프론트/백엔드 병렬 가능

#### 작업 4.3.1: 보안 점검 (4시간)

**체크리스트**:
- [ ] SQL Injection 방지 확인
- [ ] XSS 방지 확인
- [ ] CSRF 방지 확인
- [ ] 파일 업로드 보안 확인
- [ ] 환경 변수 노출 확인
- [ ] CORS 설정 확인

#### 작업 4.3.2: 의존성 취약점 점검 (4시간)

```bash
# 프론트엔드
npm audit
npm audit fix

# 백엔드
pip-audit
safety check
```

**체크리스트**:
- [ ] npm audit 통과
- [ ] pip-audit 통과
- [ ] 취약한 패키지 업데이트
- [ ] 재테스트

---

### 4.4 사용자 테스트

**WBS 코드**: 4.4
**작업 시간**: 8시간
**담당**: 전체 팀 + 테스터
**선행 작업**: 4.3
**병렬 처리**: ❌ 순차 진행

#### 작업 4.4.1: 알파 테스트 (4시간)

**테스트 시나리오**:
1. 신규 사용자 플로우
2. 문서 업로드 및 질문
3. 다양한 파일 형식 테스트
4. 에러 케이스 테스트

**체크리스트**:
- [ ] 5명 이상 테스터 참여
- [ ] 피드백 수집
- [ ] 버그 리스트 작성

#### 작업 4.4.2: 버그 수정 및 개선 (4시간)

**체크리스트**:
- [ ] 모든 critical 버그 수정
- [ ] UX 개선 사항 반영
- [ ] 재테스트 완료

---

## 📅 Phase 5: 배포 및 문서화

**기간**: 0.5주 (20시간)
**병렬 처리**: ✅ 배포와 문서화 병렬 가능

### 5.1 프로덕션 빌드

**WBS 코드**: 5.1
**작업 시간**: 4시간
**담당**: DevOps
**선행 작업**: 4.4
**병렬 처리**: ✅ 프론트/백엔드 병렬 가능

#### 작업 5.1.1: 프론트엔드 빌드 (2시간)

```bash
cd frontend
npm run build
npm start  # 프로덕션 서버 테스트
```

**체크리스트**:
- [ ] 빌드 에러 0개
- [ ] 프로덕션 환경 변수 설정
- [ ] 빌드 결과 검증
- [ ] 성능 테스트 (Lighthouse)

#### 작업 5.1.2: 백엔드 빌드 (2시간)

```bash
cd backend
# 프로덕션 의존성만 설치
pip install -r requirements.txt
# Gunicorn으로 실행
gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app
```

**체크리스트**:
- [ ] 프로덕션 설정 적용
- [ ] 로깅 설정 확인
- [ ] 성능 테스트

---

### 5.2 배포 스크립트 작성

**WBS 코드**: 5.2
**작업 시간**: 4시간
**담당**: DevOps
**선행 작업**: 5.1
**병렬 처리**: ✅ 5.3과 병렬 가능

#### 작업 5.2.1: 시작 스크립트 (2시간)

**파일**: `scripts/start-prod.sh`

```bash
#!/bin/bash

# 백엔드 시작
cd backend
source venv/bin/activate
gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app &
BACKEND_PID=$!

# 프론트엔드 시작
cd frontend
npm start &
FRONTEND_PID=$!

echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
```

**체크리스트**:
- [ ] start-prod.sh 작성
- [ ] stop-prod.sh 작성
- [ ] restart-prod.sh 작성
- [ ] 스크립트 테스트

#### 작업 5.2.2: 백업 스크립트 (2시간)

**파일**: `scripts/backup.sh`

```bash
#!/bin/bash
BACKUP_DIR="backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

cp -r data/ "$BACKUP_DIR/"
cp -r qdrant_storage/ "$BACKUP_DIR/"
cp -r chat_history/ "$BACKUP_DIR/"

tar -czf "$BACKUP_DIR.tar.gz" "$BACKUP_DIR"
```

**체크리스트**:
- [ ] backup.sh 작성
- [ ] 자동 백업 스케줄 설정 (cron)
- [ ] 백업 테스트

---

### 5.3 사용자 문서 작성

**WBS 코드**: 5.3
**작업 시간**: 8시간
**담당**: 전체 팀
**선행 작업**: 4.4
**병렬 처리**: ✅ 5.2와 병렬 가능

#### 작업 5.3.1: 사용자 가이드 (4시간)

**파일**: `docs/USER_GUIDE.md`

```markdown
# DocuNova 사용자 가이드

## 시작하기
1. 문서 업로드
2. 채팅으로 질문하기
3. ...
```

**체크리스트**:
- [ ] 시작하기 가이드
- [ ] 주요 기능 설명
- [ ] 스크린샷 추가
- [ ] FAQ

#### 작업 5.3.2: 관리자 가이드 (4시간)

**파일**: `docs/ADMIN_GUIDE.md`

```markdown
# DocuNova 관리자 가이드

## 설치 및 설정
## 백업 및 복구
## 모니터링
## 문제 해결
```

**체크리스트**:
- [ ] 설치 가이드
- [ ] 설정 가이드
- [ ] 백업/복구 가이드
- [ ] 문제 해결 가이드

---

### 5.4 최종 검증 및 배포

**WBS 코드**: 5.4
**작업 시간**: 4시간
**담당**: 전체 팀
**선행 작업**: 5.1, 5.2, 5.3
**병렬 처리**: ❌ 순차 진행

#### 작업 5.4.1: 최종 체크리스트 (2시간)

**기능 체크**:
- [ ] 문서 업로드/삭제 정상 작동
- [ ] RAG 모드 채팅 정상 작동
- [ ] LLM 모드 채팅 정상 작동
- [ ] 대시보드 통계 정상 표시
- [ ] 에러 핸들링 완벽

**품질 체크**:
- [ ] UI 오류 0개
- [ ] TypeScript 에러 0개
- [ ] ESLint 에러 0개
- [ ] 테스트 커버리지 70% 이상
- [ ] 빌드 성공

**문서 체크**:
- [ ] README.md 완성
- [ ] 사용자 가이드 완성
- [ ] 관리자 가이드 완성
- [ ] API 문서 완성

#### 작업 5.4.2: 프로덕션 배포 (2시간)

```bash
# 프로덕션 서버에서
./scripts/start-prod.sh

# 헬스체크
curl http://localhost:8000/api/v1/health
curl http://localhost:3000

# 모니터링 시작
tail -f logs/backend/app.log
```

**체크리스트**:
- [ ] 프로덕션 서버 실행
- [ ] 헬스체크 통과
- [ ] 모니터링 설정
- [ ] 팀에 배포 알림

---

## 📊 WBS 요약 테이블

### 전체 Phase 개요

| Phase | 작업명 | 기간 | 담당 | 병렬처리 | 선행작업 |
|-------|--------|------|------|----------|----------|
| 1 | 프로젝트 초기화 및 환경 설정 | 3일 (24h) | 전체 | ✅ | - |
| 2 | 백엔드 개발 | 1.5주 (60h) | Backend Dev | ⚠️ | Phase 1 |
| 3 | 프론트엔드 개발 | 1.5주 (60h) | Frontend Dev | ✅ | Phase 1 |
| 4 | 통합 및 테스트 | 1주 (40h) | 전체 | ❌ | Phase 2, 3 |
| 5 | 배포 및 문서화 | 0.5주 (20h) | 전체 | ✅ | Phase 4 |

**총 기간**: 4주 (160시간 + 버퍼 40시간 = 200시간)

---

### 세부 작업 분해

| WBS 코드 | 작업명 | 시간 | 병렬 | 선행 | 담당 |
|----------|--------|------|------|------|------|
| **Phase 1** | **프로젝트 초기화** | **24h** | - | - | - |
| 1.1 | 프로젝트 구조 생성 | 2h | ✅ | - | DevOps |
| 1.2 | 백엔드 환경 설정 | 4h | ✅ | 1.1 | Backend |
| 1.3 | 프론트엔드 환경 설정 | 4h | ✅ | 1.1 | Frontend |
| 1.4 | Qdrant 설정 | 1h | ✅ | 1.2 | Backend |
| 1.5 | 초기 테스트 및 검증 | 2h | ❌ | 1.2-1.4 | 전체 |
| **Phase 2** | **백엔드 개발** | **60h** | - | - | - |
| 2.1 | 핵심 설정 및 유틸리티 | 8h | ❌ | 1.5 | Backend |
| 2.2 | 서비스 레이어 개발 | 20h | ⚠️ | 2.1 | Backend |
| 2.2.1 | LLM 서비스 | 6h | ❌ | 2.1 | Backend |
| 2.2.2 | 임베딩 서비스 | 4h | ❌ | 2.2.1 | Backend |
| 2.2.3 | 벡터 DB 서비스 | 4h | ❌ | 2.2.2 | Backend |
| 2.2.4 | 문서 처리 서비스 | 6h | ✅ | 2.2.3 | Backend |
| 2.3 | API 라우터 개발 | 16h | ✅ | 2.2 | Backend |
| 2.3.1 | 헬스체크 API | 2h | ✅ | 2.2 | Backend |
| 2.3.2 | 문서 업로드 API | 4h | ✅ | 2.2 | Backend |
| 2.3.3 | 문서 관리 API | 3h | ✅ | 2.2 | Backend |
| 2.3.4 | 채팅 API | 5h | ✅ | 2.2 | Backend |
| 2.3.5 | 통계 API | 2h | ✅ | 2.2 | Backend |
| 2.4 | 메인 앱 및 미들웨어 | 8h | ❌ | 2.3 | Backend |
| 2.5 | 백엔드 테스트 | 8h | ✅ | 2.4 | Backend |
| **Phase 3** | **프론트엔드 개발** | **60h** | - | - | - |
| 3.1 | 공통 컴포넌트 및 라이브러리 | 12h | ⚠️ | 1.5 | Frontend |
| 3.1.1 | API 클라이언트 | 4h | ❌ | 1.5 | Frontend |
| 3.1.2 | 커스텀 Hooks | 4h | ✅ | 3.1.1 | Frontend |
| 3.1.3 | 공통 UI 컴포넌트 | 4h | ✅ | 3.1.1 | Frontend |
| 3.2 | 페이지 개발 | 32h | ✅ | 3.1 | Frontend |
| 3.2.1 | 레이아웃 및 에러 바운더리 | 4h | ❌ | 3.1 | Frontend |
| 3.2.2 | 홈 페이지 | 4h | ✅ | 3.2.1 | Frontend |
| 3.2.3 | 채팅 페이지 | 12h | ✅ | 3.2.1 | Frontend |
| 3.2.4 | 문서 관리 페이지 | 8h | ✅ | 3.2.1 | Frontend |
| 3.2.5 | 대시보드 페이지 | 4h | ✅ | 3.2.1 | Frontend |
| 3.3 | 테스트 및 최적화 | 16h | ✅ | 3.2 | Frontend |
| **Phase 4** | **통합 및 테스트** | **40h** | - | - | - |
| 4.1 | 백엔드-프론트엔드 통합 | 16h | ❌ | 2.5, 3.3 | 전체 |
| 4.2 | 성능 테스트 | 8h | ❌ | 4.1 | Backend |
| 4.3 | 보안 테스트 | 8h | ✅ | 4.2 | 전체 |
| 4.4 | 사용자 테스트 | 8h | ❌ | 4.3 | 전체 |
| **Phase 5** | **배포 및 문서화** | **20h** | - | - | - |
| 5.1 | 프로덕션 빌드 | 4h | ✅ | 4.4 | DevOps |
| 5.2 | 배포 스크립트 작성 | 4h | ✅ | 5.1 | DevOps |
| 5.3 | 사용자 문서 작성 | 8h | ✅ | 4.4 | 전체 |
| 5.4 | 최종 검증 및 배포 | 4h | ❌ | 5.1-5.3 | 전체 |

---

## 📈 간트 차트 (텍스트 버전)

```
Week 1:
Mon    Tue    Wed    Thu    Fri
[1.1][1.2][1.3][1.4][1.5][2.1][2.1]
      [1.3]                [2.1][2.1]

Week 2:
Mon    Tue    Wed    Thu    Fri
[2.2][2.2][2.2][2.2][2.3][2.3][2.4]
[3.1][3.1][3.2][3.2][3.2][3.2][3.2]

Week 3:
Mon    Tue    Wed    Thu    Fri
[2.5][3.2][3.2][3.2][3.3][3.3][4.1]
     [3.3][3.3][3.3][4.1][4.1][4.1]

Week 4:
Mon    Tue    Wed    Thu    Fri
[4.1][4.2][4.2][4.3][4.4][4.4][5.1]
          [4.3][4.3][5.2][5.3][5.3]
                    [5.3][5.3][5.4]
```

---

## 🎯 병렬 처리 최적화 전략

### 동시 진행 가능한 작업 그룹

#### Week 1 (Phase 1)
```
Group A (병렬): 1.2 백엔드 환경 설정
Group B (병렬): 1.3 프론트엔드 환경 설정
→ 동시 진행으로 4시간 절약
```

#### Week 2 (Phase 2 & 3)
```
Group A: 2.2 백엔드 서비스 개발
Group B: 3.1 프론트엔드 공통 컴포넌트
→ 동시 진행 가능 (독립적)

Group C: 2.3.1-2.3.5 API 라우터들
→ 5개 라우터 병렬 개발 가능
```

#### Week 3
```
Group A: 3.2.2 홈 페이지
Group B: 3.2.3 채팅 페이지
Group C: 3.2.4 문서 페이지
Group D: 3.2.5 대시보드
→ 4개 페이지 동시 개발 가능
```

#### Week 4
```
Group A: 5.1 프론트엔드 빌드
Group B: 5.1 백엔드 빌드
→ 동시 진행

Group A: 5.2 배포 스크립트
Group B: 5.3 문서 작성
→ 동시 진행으로 4시간 절약
```

---

## ⚠️ 리스크 관리

### 주요 리스크 및 대응 전략

| 리스크 | 확률 | 영향 | 대응 전략 |
|--------|------|------|-----------|
| Ollama 연결 불안정 | 높음 | 높음 | 재시도 로직, 타임아웃, 상세 에러 로깅 |
| React 19 호환성 이슈 | 중간 | 중간 | shadcn/ui 사용, 타입 정의 최신 유지 |
| 성능 병목 | 중간 | 높음 | 부하 테스트 조기 실행, 캐싱 전략 |
| 개발 일정 지연 | 중간 | 높음 | 버퍼 시간 40시간 확보 |
| 통합 이슈 | 중간 | 중간 | 조기 통합, 지속적 테스트 |

---

## 📋 일일 체크리스트

### 개발자 일일 루틴

**시작 시**:
- [ ] Git pull (최신 코드 동기화)
- [ ] 의존성 업데이트 확인
- [ ] 개발 서버 실행 (백엔드 + 프론트엔드)
- [ ] 오늘의 WBS 작업 확인

**개발 중**:
- [ ] 코드 작성
- [ ] 단위 테스트 작성
- [ ] Lint 및 Format 적용
- [ ] 타입 체크 통과

**종료 시**:
- [ ] 모든 테스트 통과 확인
- [ ] Git commit (pre-commit hooks 통과)
- [ ] Git push
- [ ] 내일 작업 확인

---

## 🎉 마일스톤

### 주요 완료 지점

| 마일스톤 | 날짜 | 완료 기준 |
|----------|------|-----------|
| M1: 환경 설정 완료 | Day 3 | 백엔드/프론트엔드 개발 서버 실행 |
| M2: 백엔드 API 완료 | Week 2 | 모든 API 엔드포인트 작동 |
| M3: 프론트엔드 UI 완료 | Week 3 | 모든 페이지 렌더링 |
| M4: 통합 테스트 완료 | Week 3.5 | E2E 테스트 통과 |
| M5: 프로덕션 배포 | Week 4 | 배포 완료 및 모니터링 |

---

## 📞 커뮤니케이션 계획

### 정기 회의

**일일 스탠드업 (15분)**:
- 어제 완료한 작업
- 오늘 할 작업
- 블로커 확인

**주간 리뷰 (1시간)**:
- WBS 진행 상황 점검
- 리스크 확인
- 다음 주 계획

**통합 회의 (Week 3)**:
- 백엔드-프론트엔드 통합 이슈
- 버그 우선순위 결정

---

## ✅ 최종 체크리스트

### 프로젝트 완료 조건

**기능**:
- [ ] 문서 업로드/삭제
- [ ] RAG 모드 채팅
- [ ] LLM 모드 채팅
- [ ] 대시보드 통계

**품질**:
- [ ] UI 오류 0개
- [ ] API 성공률 99.9%
- [ ] 응답 시간 < 2초
- [ ] 테스트 커버리지 70%+

**문서**:
- [ ] README.md
- [ ] 사용자 가이드
- [ ] 관리자 가이드
- [ ] API 문서

**배포**:
- [ ] 프로덕션 빌드 성공
- [ ] 헬스체크 통과
- [ ] 모니터링 설정
- [ ] 백업 스크립트 작동

---

**이 WBS를 따라 진행하면 4주 내에 안정적이고 완성도 높은 DocuNova SaaS를 구축할 수 있습니다!** 🚀

**관련 문서**:
- `05_DIRECTORY_STRUCTURE.md` - 디렉토리 구조
- `06_DEVELOPMENT_ENVIRONMENT_SETUP.md` - 개발 환경 설정
- `03_IMPLEMENTATION_GUIDE.md` - 구현 가이드
