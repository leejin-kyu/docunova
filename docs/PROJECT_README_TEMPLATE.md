<div align="center">

# 📚 DocuNova

### AI-Powered Document Analysis & Q&A SaaS Platform

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)
[![Next.js](https://img.shields.io/badge/next.js-16.0-black.svg)](https://nextjs.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688.svg)](https://fastapi.tiangolo.com/)
[![TypeScript](https://img.shields.io/badge/typescript-5.9-blue.svg)](https://www.typescriptlang.org/)

[🌐 Live Demo](https://docunova.example.com) | [📖 Documentation](https://docs.docunova.example.com) | [🐛 Report Bug](https://github.com/username/docunova-saas/issues) | [✨ Request Feature](https://github.com/username/docunova-saas/issues)

</div>

---

## 📋 목차

- [프로젝트 개요](#-프로젝트-개요)
- [주요 기능](#-주요-기능)
- [시스템 아키텍처](#-시스템-아키텍처)
- [기술 스택](#-기술-스택)
- [시작하기](#-시작하기)
  - [사전 요구사항](#사전-요구사항)
  - [설치 가이드](#설치-가이드)
  - [환경 변수 설정](#환경-변수-설정)
- [사용 방법](#-사용-방법)
- [API 문서](#-api-문서)
- [프로젝트 구조](#-프로젝트-구조)
- [개발 가이드](#-개발-가이드)
- [테스트](#-테스트)
- [배포](#-배포)
- [기여하기](#-기여하기)
- [라이선스](#-라이선스)
- [팀](#-팀)

---

## 🎯 프로젝트 개요

**DocuNova**는 대규모 문서를 업로드하고 AI를 활용하여 질문-응답(Q&A)을 수행할 수 있는 차세대 SaaS 플랫폼입니다.

### 핵심 가치

- **🚀 빠른 분석**: 수천 페이지의 문서를 몇 초 만에 분석
- **🎯 정확한 답변**: RAG(Retrieval-Augmented Generation) 기술로 정확한 답변 제공
- **💡 직관적 UI**: 복잡한 기술을 단순하고 직관적인 인터페이스로 제공
- **🔒 보안 우선**: 엔터프라이즈급 보안으로 데이터 보호
- **⚡ 높은 성능**: 최적화된 벡터 검색으로 빠른 응답 속도

### 사용 사례

- 📚 **학술 연구**: 논문, 보고서 분석 및 요약
- 💼 **비즈니스**: 계약서, 제안서 검토 및 Q&A
- ⚖️ **법률**: 법률 문서 분석 및 정보 추출
- 🏥 **의료**: 의학 문헌 검색 및 정보 조회
- 🎓 **교육**: 교재, 강의 자료 학습 지원

---

## ✨ 주요 기능

### 1. 📄 문서 관리
- **다양한 형식 지원**: PDF, DOCX, TXT, Markdown
- **대용량 처리**: 최대 100MB 파일 업로드
- **일괄 업로드**: 여러 문서 동시 업로드
- **버전 관리**: 문서 히스토리 추적

### 2. 🤖 AI 기반 Q&A
- **자연어 질문**: 일상적인 언어로 질문
- **컨텍스트 이해**: 이전 대화 맥락 파악
- **소스 인용**: 답변의 출처 문서 및 페이지 표시
- **다국어 지원**: 한국어, 영어, 일본어, 중국어

### 3. 🔍 고급 검색
- **의미 기반 검색**: 키워드가 아닌 의미로 검색
- **필터링**: 날짜, 문서 유형, 태그로 필터링
- **하이라이트**: 검색어 및 관련 내용 강조
- **검색 히스토리**: 이전 검색 기록 저장

### 4. 📊 분석 대시보드
- **사용 통계**: 업로드 문서 수, 질문 수, 응답 시간
- **성능 모니터링**: API 응답 시간, 에러율 추적
- **사용자 분석**: 활성 사용자, 세션 시간 분석
- **비용 관리**: LLM 토큰 사용량 및 비용 추적

### 5. 🔐 보안 기능
- **사용자 인증**: JWT 기반 인증
- **권한 관리**: Role-based Access Control (RBAC)
- **데이터 암호화**: 저장 및 전송 중 암호화
- **감사 로그**: 모든 활동 로깅

---

## 🏗️ 시스템 아키텍처

```mermaid
graph TB
    subgraph "클라이언트"
        A[웹 브라우저]
    end

    subgraph "프론트엔드 (Port 3000)"
        B[Next.js 16<br/>React 19]
        C[API Client Layer]
        D[Error Boundary]
    end

    subgraph "백엔드 (Port 8000)"
        E[FastAPI Server]
        F[RAG Service]
        G[LLM Service]
        H[Document Processor]
    end

    subgraph "데이터 레이어"
        I[(Qdrant<br/>Vector DB)]
        J[(PostgreSQL<br/>Metadata)]
    end

    subgraph "AI 서비스 (Port 11434)"
        K[Ollama<br/>LLM Engine]
    end

    A -->|HTTPS| B
    B --> C
    C -->|REST API| E
    E --> F
    E --> H
    F --> G
    G -->|Query| K
    F -->|Vector Search| I
    E -->|Store Metadata| J
    H -->|Embed & Store| I

    style B fill:#61dafb
    style E fill:#009688
    style I fill:#dc477d
    style K fill:#000000
```

### 핵심 컴포넌트

| 컴포넌트 | 역할 | 포트 |
|---------|------|------|
| **Next.js Frontend** | 사용자 인터페이스 제공 | 3000 |
| **FastAPI Backend** | RESTful API, 비즈니스 로직 | 8000 |
| **Qdrant** | 벡터 데이터베이스 (임베딩 저장) | 6333 |
| **PostgreSQL** | 메타데이터 및 사용자 정보 저장 | 5432 |
| **Ollama** | 로컬 LLM 추론 엔진 | 11434 |

---

## 🛠️ 기술 스택

### Frontend

| 기술 | 버전 | 용도 |
|-----|------|------|
| **Next.js** | 16.0.0 | React 프레임워크 (App Router) |
| **React** | 19.2.0 | UI 라이브러리 |
| **TypeScript** | 5.9.3 | 정적 타입 검사 |
| **Tailwind CSS** | 3.4.1 | 유틸리티 CSS 프레임워크 |
| **shadcn/ui** | latest | UI 컴포넌트 라이브러리 |
| **Axios** | 1.6.0 | HTTP 클라이언트 |
| **React Query** | 5.0.0 | 서버 상태 관리 |
| **Zustand** | 4.4.0 | 클라이언트 상태 관리 (선택) |

### Backend

| 기술 | 버전 | 용도 |
|-----|------|------|
| **FastAPI** | 0.115.0 | 웹 프레임워크 |
| **Python** | 3.11+ | 프로그래밍 언어 |
| **Pydantic** | 2.9.2 | 데이터 검증 |
| **Qdrant** | 1.12.1 | 벡터 데이터베이스 |
| **FastEmbed** | 0.3.2 | 임베딩 생성 |
| **Ollama** | latest | LLM 추론 엔진 |
| **SQLAlchemy** | 2.0+ | ORM (선택) |
| **Alembic** | 1.13+ | 데이터베이스 마이그레이션 |

### DevOps & Tools

| 기술 | 용도 |
|-----|------|
| **Docker** | 컨테이너화 |
| **Docker Compose** | 로컬 개발 환경 |
| **GitHub Actions** | CI/CD |
| **Nginx** | 리버스 프록시 |
| **Poetry** | Python 패키지 관리 |
| **ESLint** | JavaScript/TypeScript 린팅 |
| **Prettier** | 코드 포맷팅 |
| **Black** | Python 코드 포맷팅 |
| **pytest** | Python 테스트 |
| **Playwright** | E2E 테스트 |

---

## 🚀 시작하기

### 사전 요구사항

시스템에 다음이 설치되어 있어야 합니다:

| 소프트웨어 | 최소 버전 | 권장 버전 | 설치 링크 |
|-----------|----------|----------|----------|
| **Node.js** | 20.0.0 | 20.11.0+ | [nodejs.org](https://nodejs.org/) |
| **Python** | 3.11.0 | 3.11.7+ | [python.org](https://www.python.org/) |
| **Docker** | 24.0.0 | 26.0.0+ | [docker.com](https://www.docker.com/) |
| **Git** | 2.40.0 | latest | [git-scm.com](https://git-scm.com/) |
| **Ollama** | 0.1.0 | latest | [ollama.ai](https://ollama.ai/) |

#### 하드웨어 권장사양

- **CPU**: 4코어 이상
- **RAM**: 16GB 이상 (LLM 모델 로딩 포함)
- **Storage**: 20GB 이상 여유 공간
- **GPU**: NVIDIA GPU (선택, LLM 가속용)

---

### 설치 가이드

#### 1. 저장소 클론

```bash
git clone https://github.com/username/docunova-saas.git
cd docunova-saas
```

#### 2. 백엔드 설정

```bash
# 백엔드 디렉토리 이동
cd backend

# Python 가상환경 생성 (선택 1: venv)
python -m venv venv
source venv/bin/activate  # Linux/macOS
# 또는
venv\Scripts\activate  # Windows

# 또는 Poetry 사용 (선택 2: Poetry)
poetry install
poetry shell

# 의존성 설치
pip install -r requirements.txt

# 환경변수 파일 생성
cp .env.example .env

# 환경변수 편집 (아래 섹션 참고)
nano .env  # 또는 code .env
```

#### 3. 프론트엔드 설정

```bash
# 프론트엔드 디렉토리 이동
cd ../frontend

# 의존성 설치
npm install

# 환경변수 파일 생성
cp .env.example .env.local

# 환경변수 편집
nano .env.local  # 또는 code .env.local
```

#### 4. 데이터베이스 설정

**Qdrant 실행 (Docker)**

```bash
docker run -d \
  --name qdrant \
  -p 6333:6333 \
  -p 6334:6334 \
  -v qdrant_storage:/qdrant/storage \
  qdrant/qdrant:latest
```

**PostgreSQL 실행 (Docker, 선택)**

```bash
docker run -d \
  --name postgres \
  -e POSTGRES_USER=docunova \
  -e POSTGRES_PASSWORD=yourpassword \
  -e POSTGRES_DB=docunova \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  postgres:16
```

#### 5. Ollama 설정

```bash
# Ollama 설치 (이미 설치되지 않은 경우)
curl -fsSL https://ollama.ai/install.sh | sh

# LLM 모델 다운로드
ollama pull llama3.1:8b

# Ollama 서버 실행 확인
ollama serve
```

#### 6. 개발 서버 실행

**터미널 1: 백엔드**

```bash
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**터미널 2: 프론트엔드**

```bash
cd frontend
npm run dev
```

#### 7. 접속 확인

- **프론트엔드**: http://localhost:3000
- **백엔드 API**: http://localhost:8000
- **API 문서**: http://localhost:8000/docs
- **Qdrant 대시보드**: http://localhost:6333/dashboard

---

### 환경 변수 설정

#### Backend (.env)

```bash
# ===== 서버 설정 =====
APP_NAME="DocuNova"
APP_VERSION="1.0.0"
DEBUG=true
ENVIRONMENT="development"  # development, staging, production

# ===== 데이터베이스 =====
# Qdrant (벡터 DB)
QDRANT_URL="http://localhost:6333"
QDRANT_API_KEY=""  # 프로덕션에서 설정
QDRANT_COLLECTION_NAME="docunova_documents"

# PostgreSQL (메타데이터, 선택)
DATABASE_URL="postgresql://docunova:yourpassword@localhost:5432/docunova"
DATABASE_POOL_SIZE=20
DATABASE_MAX_OVERFLOW=10

# ===== LLM 설정 =====
OLLAMA_URL="http://localhost:11434"
OLLAMA_MODEL="llama3.1:8b"
LLM_TIMEOUT=30
LLM_MAX_RETRIES=2

# ===== 임베딩 설정 =====
EMBEDDING_MODEL="BAAI/bge-small-en-v1.5"
EMBEDDING_DIMENSION=384
CHUNK_SIZE=500
CHUNK_OVERLAP=50

# ===== 파일 업로드 =====
MAX_FILE_SIZE=104857600  # 100MB in bytes
ALLOWED_EXTENSIONS=".pdf,.docx,.txt,.md"
UPLOAD_DIR="./uploads"

# ===== 보안 =====
SECRET_KEY="your-secret-key-change-in-production"
ALGORITHM="HS256"
ACCESS_TOKEN_EXPIRE_MINUTES=30

# ===== CORS =====
CORS_ORIGINS="http://localhost:3000,http://localhost:3001"
CORS_ALLOW_CREDENTIALS=true

# ===== 로깅 =====
LOG_LEVEL="INFO"  # DEBUG, INFO, WARNING, ERROR, CRITICAL
LOG_FILE="logs/app.log"
LOG_ROTATION="10 MB"
LOG_RETENTION="30 days"

# ===== 모니터링 (선택) =====
SENTRY_DSN=""
ENABLE_METRICS=true

# ===== Redis (캐싱, 선택) =====
REDIS_URL="redis://localhost:6379/0"
CACHE_TTL=3600
```

#### Frontend (.env.local)

```bash
# ===== API 엔드포인트 =====
NEXT_PUBLIC_API_URL="http://localhost:8000"
NEXT_PUBLIC_API_TIMEOUT=30000

# ===== 애플리케이션 설정 =====
NEXT_PUBLIC_APP_NAME="DocuNova"
NEXT_PUBLIC_APP_VERSION="1.0.0"
NEXT_PUBLIC_APP_URL="http://localhost:3000"

# ===== 기능 플래그 =====
NEXT_PUBLIC_ENABLE_ANALYTICS=false
NEXT_PUBLIC_ENABLE_CHAT_HISTORY=true
NEXT_PUBLIC_ENABLE_DOCUMENT_SHARING=false

# ===== 파일 업로드 =====
NEXT_PUBLIC_MAX_FILE_SIZE=104857600  # 100MB
NEXT_PUBLIC_ALLOWED_FILE_TYPES=".pdf,.docx,.txt,.md"

# ===== 인증 (선택) =====
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="your-nextauth-secret"

# ===== 외부 서비스 (선택) =====
NEXT_PUBLIC_GOOGLE_ANALYTICS_ID=""
NEXT_PUBLIC_SENTRY_DSN=""

# ===== 개발 전용 =====
NODE_ENV="development"
NEXT_TELEMETRY_DISABLED=1
```

#### Docker Compose 사용 (권장)

모든 서비스를 한 번에 실행:

```yaml
# docker-compose.yml (프로젝트 루트)
version: '3.8'

services:
  # Qdrant 벡터 DB
  qdrant:
    image: qdrant/qdrant:latest
    ports:
      - "6333:6333"
      - "6334:6334"
    volumes:
      - qdrant_storage:/qdrant/storage
    restart: unless-stopped

  # PostgreSQL (선택)
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: docunova
      POSTGRES_PASSWORD: yourpassword
      POSTGRES_DB: docunova
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  # Backend
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    env_file:
      - ./backend/.env
    depends_on:
      - qdrant
      - postgres
    volumes:
      - ./backend:/app
      - backend_uploads:/app/uploads
    restart: unless-stopped

  # Frontend
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    env_file:
      - ./frontend/.env.local
    depends_on:
      - backend
    restart: unless-stopped

volumes:
  qdrant_storage:
  postgres_data:
  backend_uploads:
```

**실행**:

```bash
# 모든 서비스 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f

# 서비스 중지
docker-compose down

# 볼륨까지 삭제
docker-compose down -v
```

---

## 💻 사용 방법

### 1. 문서 업로드

#### 웹 UI

1. 로그인 후 대시보드 접속
2. "문서 업로드" 버튼 클릭
3. 파일 선택 (PDF, DOCX, TXT, MD)
4. 업로드 진행 상황 확인

#### API 사용

```bash
curl -X POST "http://localhost:8000/api/v1/documents/upload" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@document.pdf" \
  -F "collection_id=default"
```

### 2. 문서 검색

#### 웹 UI

1. 검색창에 질문 입력
2. 검색 버튼 클릭
3. 결과 확인 (답변 + 소스 문서)

#### API 사용

```bash
curl -X POST "http://localhost:8000/api/v1/chat" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "message": "문서에서 중요한 내용을 요약해주세요",
    "collection_id": "default"
  }'
```

### 3. 대화 모드

채팅 인터페이스에서:
- 이전 대화 맥락이 유지됩니다
- 추가 질문을 자연스럽게 할 수 있습니다
- 각 답변의 출처를 확인할 수 있습니다

---

## 📚 API 문서

### 자동 생성 문서

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/openapi.json

### 주요 엔드포인트

#### 인증

```http
POST /api/v1/auth/login
POST /api/v1/auth/register
POST /api/v1/auth/refresh
GET  /api/v1/auth/me
```

#### 문서 관리

```http
POST   /api/v1/documents/upload
GET    /api/v1/documents
GET    /api/v1/documents/{id}
DELETE /api/v1/documents/{id}
PUT    /api/v1/documents/{id}/metadata
```

#### 채팅 & 검색

```http
POST /api/v1/chat
GET  /api/v1/chat/history
POST /api/v1/search
```

#### 컬렉션 관리

```http
POST   /api/v1/collections
GET    /api/v1/collections
GET    /api/v1/collections/{id}
DELETE /api/v1/collections/{id}
```

### API 사용 예시

#### Python

```python
import requests

# 로그인
response = requests.post(
    "http://localhost:8000/api/v1/auth/login",
    json={"email": "user@example.com", "password": "password"}
)
token = response.json()["access_token"]

# 문서 업로드
with open("document.pdf", "rb") as f:
    response = requests.post(
        "http://localhost:8000/api/v1/documents/upload",
        headers={"Authorization": f"Bearer {token}"},
        files={"file": f}
    )

# 채팅
response = requests.post(
    "http://localhost:8000/api/v1/chat",
    headers={"Authorization": f"Bearer {token}"},
    json={"message": "문서 요약해줘", "collection_id": "default"}
)
print(response.json()["answer"])
```

#### JavaScript/TypeScript

```typescript
// API Client
const apiClient = axios.create({
  baseURL: 'http://localhost:8000/api/v1',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 문서 업로드
const uploadDocument = async (file: File) => {
  const formData = new FormData();
  formData.append('file', file);

  const response = await apiClient.post('/documents/upload', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });

  return response.data;
};

// 채팅
const sendMessage = async (message: string) => {
  const response = await apiClient.post('/chat', {
    message,
    collection_id: 'default',
  });

  return response.data;
};
```

---

## 📁 프로젝트 구조

```
docunova-saas/
├── backend/                    # FastAPI 백엔드
│   ├── app/
│   │   ├── api/
│   │   │   └── v1/            # API v1 엔드포인트
│   │   │       ├── auth.py
│   │   │       ├── chat.py
│   │   │       └── documents.py
│   │   ├── core/              # 핵심 설정
│   │   │   ├── config.py
│   │   │   ├── security.py
│   │   │   └── logging.py
│   │   ├── services/          # 비즈니스 로직
│   │   │   ├── llm_service.py
│   │   │   ├── rag_service.py
│   │   │   ├── embedding_service.py
│   │   │   └── document_processor.py
│   │   ├── models/            # Pydantic 모델
│   │   │   ├── user.py
│   │   │   ├── document.py
│   │   │   └── chat.py
│   │   ├── middleware/        # 미들웨어
│   │   │   ├── error_handler.py
│   │   │   └── cors.py
│   │   └── utils/             # 유틸리티
│   │       ├── validators.py
│   │       └── helpers.py
│   ├── tests/                 # 테스트
│   │   ├── unit/
│   │   ├── integration/
│   │   └── e2e/
│   ├── main.py                # 진입점
│   ├── requirements.txt
│   ├── pyproject.toml
│   └── .env.example
│
├── frontend/                  # Next.js 프론트엔드
│   ├── app/                   # App Router
│   │   ├── (auth)/
│   │   │   ├── login/
│   │   │   └── register/
│   │   ├── (dashboard)/
│   │   │   ├── chat/
│   │   │   ├── documents/
│   │   │   ├── settings/
│   │   │   └── analytics/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── error.tsx
│   ├── components/            # 재사용 컴포넌트
│   │   ├── ui/               # shadcn/ui 컴포넌트
│   │   ├── chat/
│   │   │   ├── message-list.tsx
│   │   │   ├── message-input.tsx
│   │   │   └── chat-container.tsx
│   │   ├── documents/
│   │   │   ├── document-uploader.tsx
│   │   │   └── document-list.tsx
│   │   └── common/
│   │       ├── error-boundary.tsx
│   │       ├── loading.tsx
│   │       └── header.tsx
│   ├── lib/                   # 유틸리티 & API
│   │   ├── api.ts            # API 클라이언트 ⭐
│   │   ├── utils.ts
│   │   └── constants.ts
│   ├── hooks/                 # 커스텀 Hooks
│   │   ├── use-chat.ts
│   │   ├── use-documents.ts
│   │   └── use-auth.ts
│   ├── types/                 # TypeScript 타입
│   │   ├── api.ts
│   │   ├── chat.ts
│   │   └── document.ts
│   ├── public/                # 정적 파일
│   ├── next.config.js
│   ├── tailwind.config.js
│   ├── tsconfig.json
│   └── .env.local.example
│
├── docs/                      # 프로젝트 문서
│   ├── architecture/
│   ├── api/
│   └── guides/
│
├── scripts/                   # 유틸리티 스크립트
│   ├── setup.sh
│   ├── deploy.sh
│   └── backup.sh
│
├── docker-compose.yml
├── .gitignore
├── README.md
└── LICENSE
```

---

## 🔧 개발 가이드

### 코드 스타일

이 프로젝트는 엄격한 코드 스타일 가이드를 따릅니다.

#### TypeScript/JavaScript

```bash
# ESLint 검사
npm run lint

# ESLint 자동 수정
npm run lint:fix

# Prettier 포맷팅
npm run format

# 타입 체크
npm run type-check
```

**ESLint 규칙** (.eslintrc.json):
```json
{
  "extends": ["next/core-web-vitals", "prettier"],
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unused-vars": "error",
    "react-hooks/rules-of-hooks": "error",
    "react-hooks/exhaustive-deps": "warn"
  }
}
```

#### Python

```bash
# Black 포맷팅
black .

# isort import 정렬
isort .

# Ruff 린팅
ruff check .

# mypy 타입 체크
mypy .
```

**pyproject.toml**:
```toml
[tool.black]
line-length = 88
target-version = ['py311']

[tool.isort]
profile = "black"

[tool.mypy]
python_version = "3.11"
disallow_untyped_defs = true
```

### Pre-commit Hooks

코드 품질을 자동으로 검사:

```bash
# Frontend (Husky)
npm run prepare

# Backend (pre-commit)
pre-commit install
pre-commit run --all-files
```

### 브랜치 전략

**Git Flow** 사용:

- `main`: 프로덕션 배포 브랜치
- `develop`: 개발 통합 브랜치
- `feature/*`: 기능 개발 브랜치
- `bugfix/*`: 버그 수정 브랜치
- `hotfix/*`: 긴급 수정 브랜치
- `release/*`: 릴리스 준비 브랜치

```bash
# 기능 개발
git checkout -b feature/user-authentication develop

# 작업 완료 후
git checkout develop
git merge --no-ff feature/user-authentication
git branch -d feature/user-authentication
```

### 커밋 메시지 규칙

**Conventional Commits** 형식 사용:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**타입**:
- `feat`: 새로운 기능
- `fix`: 버그 수정
- `docs`: 문서 변경
- `style`: 코드 포맷팅 (기능 변경 없음)
- `refactor`: 리팩토링
- `test`: 테스트 추가/수정
- `chore`: 빌드/설정 변경

**예시**:
```bash
git commit -m "feat(chat): add message streaming support"
git commit -m "fix(auth): resolve JWT token expiration issue"
git commit -m "docs(api): update API documentation"
```

---

## 🧪 테스트

### 백엔드 테스트

```bash
cd backend

# 모든 테스트 실행
pytest

# 커버리지 포함
pytest --cov=app --cov-report=html

# 특정 테스트 실행
pytest tests/unit/test_llm_service.py

# 마커로 필터링
pytest -m "unit"  # 단위 테스트만
pytest -m "integration"  # 통합 테스트만
```

**테스트 구조**:
```python
# tests/unit/test_llm_service.py
import pytest
from app.services.llm_service import LLMService

@pytest.fixture
def llm_service():
    return LLMService(base_url="http://localhost:11434")

def test_query_success(llm_service):
    response = await llm_service.query("테스트 질문")
    assert response is not None
    assert "answer" in response

@pytest.mark.integration
def test_ollama_connection(llm_service):
    health = await llm_service.health_check()
    assert health is True
```

### 프론트엔드 테스트

```bash
cd frontend

# 단위 테스트 (Jest)
npm run test

# Watch 모드
npm run test:watch

# 커버리지
npm run test:coverage

# E2E 테스트 (Playwright)
npm run test:e2e

# E2E UI 모드
npm run test:e2e:ui
```

**테스트 예시**:
```typescript
// __tests__/components/chat/message-list.test.tsx
import { render, screen } from '@testing-library/react';
import { MessageList } from '@/components/chat/message-list';

describe('MessageList', () => {
  it('renders messages correctly', () => {
    const messages = [
      { id: '1', role: 'user', content: 'Hello' },
      { id: '2', role: 'assistant', content: 'Hi there!' },
    ];

    render(<MessageList messages={messages} />);

    expect(screen.getByText('Hello')).toBeInTheDocument();
    expect(screen.getByText('Hi there!')).toBeInTheDocument();
  });
});
```

```typescript
// e2e/chat.spec.ts
import { test, expect } from '@playwright/test';

test('chat flow', async ({ page }) => {
  await page.goto('http://localhost:3000/chat');

  // 메시지 입력
  await page.fill('[data-testid="message-input"]', '안녕하세요');
  await page.click('[data-testid="send-button"]');

  // 응답 확인
  await expect(page.locator('[data-testid="assistant-message"]')).toBeVisible({
    timeout: 30000,
  });
});
```

---

## 🚀 배포

### Docker로 배포

```bash
# 이미지 빌드
docker-compose -f docker-compose.prod.yml build

# 컨테이너 실행
docker-compose -f docker-compose.prod.yml up -d

# 로그 확인
docker-compose logs -f
```

### 프로덕션 체크리스트

- [ ] 환경 변수 프로덕션 값으로 변경
- [ ] `DEBUG=false` 설정
- [ ] 비밀키 변경 (`SECRET_KEY`)
- [ ] CORS 설정 프로덕션 도메인으로 변경
- [ ] 데이터베이스 백업 설정
- [ ] HTTPS 설정 (Let's Encrypt)
- [ ] 로그 로테이션 설정
- [ ] 모니터링 설정 (Sentry, Prometheus 등)
- [ ] 성능 테스트 수행
- [ ] 보안 취약점 스캔

### CI/CD (GitHub Actions)

`.github/workflows/deploy.yml`:
```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run tests
        run: |
          cd backend && pytest
          cd ../frontend && npm test

      - name: Build Docker images
        run: docker-compose build

      - name: Deploy to server
        run: |
          # 배포 스크립트 실행
          ./scripts/deploy.sh
```

---

## 🤝 기여하기

DocuNova 프로젝트에 기여해주셔서 감사합니다! 🎉

### 기여 방법

1. **Fork** 저장소를 Fork합니다
2. **Branch** 기능 브랜치를 생성합니다 (`git checkout -b feature/AmazingFeature`)
3. **Commit** 변경사항을 커밋합니다 (`git commit -m 'feat: add some AmazingFeature'`)
4. **Push** 브랜치에 푸시합니다 (`git push origin feature/AmazingFeature`)
5. **Pull Request** PR을 생성합니다

### 기여 가이드라인

#### 코드 기여

- **코드 스타일**: ESLint, Prettier, Black 규칙을 따라주세요
- **테스트**: 새로운 기능에는 테스트를 포함해주세요
- **문서화**: 코드에 주석과 문서를 추가해주세요
- **커밋 메시지**: Conventional Commits 형식을 사용해주세요

#### PR 체크리스트

PR 생성 전 확인:

- [ ] 코드가 린팅을 통과했나요?
- [ ] 모든 테스트가 통과했나요?
- [ ] 새로운 기능에 테스트를 추가했나요?
- [ ] 문서를 업데이트했나요?
- [ ] Breaking changes가 있다면 명시했나요?
- [ ] 이슈 번호를 PR에 연결했나요?

#### 이슈 리포트

버그를 발견했다면:

1. **검색**: 기존 이슈가 있는지 확인
2. **재현**: 버그 재현 방법 명시
3. **환경**: OS, 브라우저, 버전 정보 제공
4. **로그**: 에러 로그 첨부
5. **스크린샷**: 가능하면 스크린샷 추가

**이슈 템플릿**:
```markdown
### 버그 설명
간단명료한 버그 설명

### 재현 방법
1. '...'로 이동
2. '....' 클릭
3. '....' 스크롤
4. 에러 발생

### 예상 동작
무엇이 일어나야 하는지

### 실제 동작
실제로 무엇이 일어났는지

### 환경
- OS: [e.g. macOS 14.0]
- Browser: [e.g. Chrome 120]
- Version: [e.g. 1.0.0]

### 추가 컨텍스트
스크린샷, 로그 등
```

#### 기능 요청

새로운 기능을 제안하고 싶다면:

```markdown
### 기능 설명
명확하고 간결한 기능 설명

### 문제점
어떤 문제를 해결하나요?

### 제안 솔루션
어떻게 구현하면 좋을까요?

### 대안
다른 해결 방법은?

### 추가 컨텍스트
스크린샷, 디자인 등
```

### 행동 강령

모든 기여자는 다음을 준수해야 합니다:

- 존중과 배려로 소통
- 건설적인 피드백 제공
- 다양성 포용
- 괴롭힘 금지

---

## 📄 라이선스

이 프로젝트는 **MIT License** 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

```
MIT License

Copyright (c) 2025 DocuNova Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

[전체 라이선스 텍스트는 LICENSE 파일 참조]
```

---

## 👥 팀

### 핵심 개발팀

| 이름 | 역할 | GitHub | Email |
|------|------|--------|-------|
| **이진규** | Project Lead & Full-Stack | [@leejin-kyu](https://github.com/leejin-kyu) | leejinkyu@example.com |
| **김개발** | Backend Developer | [@kim-dev](https://github.com/kim-dev) | kimdev@example.com |
| **박프론트** | Frontend Developer | [@park-front](https://github.com/park-front) | parkfront@example.com |
| **최데브옵스** | DevOps Engineer | [@choi-devops](https://github.com/choi-devops) | choiops@example.com |

### 기여자들

이 프로젝트에 기여해주신 모든 분들께 감사드립니다!

<a href="https://github.com/username/docunova-saas/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=username/docunova-saas" />
</a>

---

## 📞 지원 & 연락처

### 문의

- **이메일**: support@docunova.example.com
- **Discord**: [DocuNova Community](https://discord.gg/docunova)
- **Twitter**: [@DocuNova](https://twitter.com/docunova)
- **블로그**: [blog.docunova.example.com](https://blog.docunova.example.com)

### 유용한 링크

- [공식 문서](https://docs.docunova.example.com)
- [API 레퍼런스](https://api.docunova.example.com)
- [튜토리얼](https://docs.docunova.example.com/tutorials)
- [FAQ](https://docs.docunova.example.com/faq)
- [로드맵](https://github.com/username/docunova-saas/projects)

---

## 🙏 감사의 글

이 프로젝트는 다음 오픈소스 프로젝트들 덕분에 가능했습니다:

- [FastAPI](https://fastapi.tiangolo.com/) - 고성능 웹 프레임워크
- [Next.js](https://nextjs.org/) - React 프레임워크
- [Qdrant](https://qdrant.tech/) - 벡터 데이터베이스
- [Ollama](https://ollama.ai/) - 로컬 LLM 실행
- [shadcn/ui](https://ui.shadcn.com/) - UI 컴포넌트
- [Tailwind CSS](https://tailwindcss.com/) - CSS 프레임워크

그리고 모든 기여자와 사용자 여러분께 감사드립니다! ❤️

---

## 📊 프로젝트 상태

![GitHub issues](https://img.shields.io/github/issues/username/docunova-saas)
![GitHub pull requests](https://img.shields.io/github/issues-pr/username/docunova-saas)
![GitHub stars](https://img.shields.io/github/stars/username/docunova-saas)
![GitHub forks](https://img.shields.io/github/forks/username/docunova-saas)
![GitHub contributors](https://img.shields.io/github/contributors/username/docunova-saas)
![GitHub last commit](https://img.shields.io/github/last-commit/username/docunova-saas)

---

<div align="center">

**Made with ❤️ by DocuNova Team**

[⬆ Back to Top](#-docunova)

</div>
