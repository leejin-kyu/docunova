# 🏗️ DocuNova 프로젝트 템플릿 생성 가이드

## 📋 목차

- [개요](#개요)
- [사전 준비](#사전-준비)
- [Phase 1: 프로젝트 구조 생성](#phase-1-프로젝트-구조-생성)
- [Phase 2: 백엔드 설정](#phase-2-백엔드-설정)
- [Phase 3: 프론트엔드 설정](#phase-3-프론트엔드-설정)
- [Phase 4: 핵심 서비스 구현](#phase-4-핵심-서비스-구현)
- [Phase 5: 검증 및 테스트](#phase-5-검증-및-테스트)
- [문제 해결](#문제-해결)

---

## 🎯 개요

이 가이드는 DocuNova 프로젝트를 **처음부터 안정적으로** 생성하는 방법을 단계별로 설명합니다.

### 생성되는 프로젝트 구조

```
docunova-saas/
├── backend/                    # FastAPI 백엔드
│   ├── app/
│   │   ├── api/v1/            # API 엔드포인트
│   │   ├── services/          # 비즈니스 로직
│   │   ├── core/              # 핵심 설정
│   │   └── models/            # 데이터 모델
│   ├── tests/                 # 테스트
│   ├── main.py                # 진입점
│   ├── requirements.txt       # 의존성
│   └── .env                   # 환경 변수
│
├── frontend/                   # Next.js 프론트엔드
│   ├── app/                   # App Router
│   ├── components/            # 컴포넌트
│   ├── lib/                   # 유틸리티
│   ├── package.json
│   └── .env.local
│
├── docs/                       # 문서
├── scripts/                    # 유틸리티 스크립트
└── README.md
```

---

## 🔧 사전 준비

### 필수 소프트웨어

| 소프트웨어 | 최소 버전 | 설치 확인 |
|-----------|----------|----------|
| **Python** | 3.11.0 | `python --version` |
| **Node.js** | 20.0.0 | `node --version` |
| **Docker** | 24.0.0 | `docker --version` |
| **Git** | 2.40.0 | `git --version` |

### 설치 방법

**Windows**:
```powershell
# Python
winget install Python.Python.3.11

# Node.js
winget install OpenJS.NodeJS

# Docker Desktop
winget install Docker.DockerDesktop

# Git
winget install Git.Git
```

**macOS**:
```bash
# Homebrew 설치 (없는 경우)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 소프트웨어 설치
brew install python@3.11 node docker git
```

**Linux (Ubuntu/Debian)**:
```bash
# Python 3.11
sudo apt update
sudo apt install python3.11 python3.11-venv python3-pip

# Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install nodejs

# Docker
curl -fsSL https://get.docker.com | sudo sh

# Git
sudo apt install git
```

---

## Phase 1: 프로젝트 구조 생성

### Step 1.1: 루트 디렉토리 생성

```bash
# 프로젝트 루트 생성
mkdir docunova-saas
cd docunova-saas

# 기본 디렉토리 생성
mkdir -p backend frontend docs scripts

# Git 초기화
git init

# .gitignore 생성
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
*.egg-info/
dist/
build/

# Node
node_modules/
.next/
out/
*.log

# 환경 변수
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# 업로드 파일
uploads/
temp/

# 로그
logs/
*.log

# 데이터베이스
*.db
*.sqlite

# 벡터 DB 데이터
qdrant_storage/
embedding_models/
EOF

echo "✅ Phase 1.1 완료: 프로젝트 구조 생성"
```

### Step 1.2: README.md 생성

```bash
cat > README.md << 'EOF'
# DocuNova SaaS

AI-Powered Document Analysis & Q&A System

## 기능

- 📄 다양한 형식 지원 (PDF, DOCX, TXT, MD)
- 🤖 AI 기반 Q&A (RAG 아키텍처)
- 🔍 고급 검색 (의미 기반)
- 📊 분석 대시보드

## 기술 스택

- **Backend**: FastAPI, Python 3.11, Qdrant, Ollama
- **Frontend**: Next.js 16, React 19, TypeScript, Tailwind CSS

## 시작하기

### 백엔드

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# .env 파일 수정
python main.py
```

### 프론트엔드

```bash
cd frontend
npm install
cp .env.example .env.local
# .env.local 파일 수정
npm run dev
```

## 문서

- [Architecture](docs/)
- [API Documentation](http://localhost:8000/docs)

## 라이선스

MIT
EOF

echo "✅ Phase 1.2 완료: README.md 생성"
```

---

## Phase 2: 백엔드 설정

### Step 2.1: 백엔드 디렉토리 구조

```bash
cd backend

# 디렉토리 구조 생성
mkdir -p app/{api/v1,services,core,models,middleware,utils}
mkdir -p tests/{unit,integration,e2e}
mkdir -p logs uploads embedding_models

echo "✅ Phase 2.1 완료: 백엔드 디렉토리 구조"
```

### Step 2.2: requirements.txt 생성

```bash
cat > requirements.txt << 'EOF'
# FastAPI 및 웹 프레임워크
fastapi==0.115.0
uvicorn[standard]==0.30.6
python-multipart==0.0.9

# Pydantic (데이터 검증)
pydantic==2.9.2
pydantic-settings==2.5.2

# 벡터 DB 및 임베딩
qdrant-client==1.12.1
fastembed==0.3.2

# LLM 통신
httpx==0.27.2

# 문서 처리
pypdf==5.0.1
python-docx==1.1.2
python-magic==0.4.27  # 파일 타입 감지

# 유틸리티
python-dotenv==1.0.1
tqdm==4.66.5

# 테스트
pytest==8.3.3
pytest-asyncio==0.24.0
pytest-cov==5.0.0

# 개발 도구
black==24.8.0
isort==5.13.2
ruff==0.6.8
mypy==1.11.2
EOF

echo "✅ Phase 2.2 완료: requirements.txt 생성"
```

### Step 2.3: .env.example 생성

```bash
cat > .env.example << 'EOF'
# ===== 서버 설정 =====
APP_NAME="DocuNova"
APP_VERSION="1.0.0"
DEBUG=true
ENVIRONMENT="development"
PORT=8000

# ===== 데이터베이스 =====
QDRANT_HOST="localhost"
QDRANT_PORT=6333
COLLECTION_NAME="docunova_documents"

# ===== LLM 설정 =====
OLLAMA_HOST="localhost"
OLLAMA_PORT=11434
OLLAMA_MODEL="llama3.1:8b"
LLM_TIMEOUT=30
LLM_MAX_RETRIES=3

# ===== 임베딩 설정 =====
EMBEDDING_MODEL="BAAI/bge-small-en-v1.5"
EMBEDDING_DIMENSION=384
CHUNK_SIZE=600
CHUNK_OVERLAP=150

# ===== 파일 업로드 =====
MAX_FILE_SIZE=104857600
ALLOWED_EXTENSIONS=".pdf,.docx,.txt,.md"
UPLOAD_DIR="./uploads"

# ===== CORS =====
CORS_ORIGINS="http://localhost:3000"

# ===== RAG 설정 =====
MIN_SIMILARITY=0.7
TOP_K=10
FINAL_K=5
DIVERSITY_LAMBDA=0.5
EOF

# .env 파일 생성
cp .env.example .env

echo "✅ Phase 2.3 완료: 환경 변수 설정"
```

### Step 2.4: 가상환경 생성 및 의존성 설치

```bash
# 가상환경 생성
python -m venv venv

# 가상환경 활성화
# Windows
venv\Scripts\activate

# macOS/Linux
# source venv/bin/activate

# 의존성 설치
pip install --upgrade pip
pip install -r requirements.txt

echo "✅ Phase 2.4 완료: 가상환경 및 의존성 설치"
```

### Step 2.5: main.py 생성 (핵심!)

```bash
cat > main.py << 'EOF'
"""
DocuNova Backend - Main Application
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging
import os

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)

# Global services
embedding_service = None
vector_service = None
llm_service = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    log.info("🚀 DocuNova Backend starting...")

    # TODO: Initialize services here
    # embedding_service = EmbeddingService(...)
    # vector_service = VectorService(...)
    # llm_service = LLMService(...)

    log.info("✅ Services initialized")
    yield
    log.info("🛑 DocuNova Backend shutting down...")

app = FastAPI(
    title="DocuNova API",
    version="1.0.0",
    lifespan=lifespan
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

@app.get("/")
def root():
    return {"message": "DocuNova API", "status": "running"}

@app.get("/health")
def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
EOF

echo "✅ Phase 2.5 완료: main.py 생성"
```

### Step 2.6: 백엔드 테스트

```bash
# 백엔드 실행 테스트
python main.py &
BACKEND_PID=$!

# 5초 대기
sleep 5

# Health check
curl http://localhost:8000/health

# 프로세스 종료
kill $BACKEND_PID

echo "✅ Phase 2.6 완료: 백엔드 실행 확인"
```

---

## Phase 3: 프론트엔드 설정

### Step 3.1: Next.js 프로젝트 생성

```bash
cd ../frontend

# Next.js 프로젝트 생성 (대화형)
npx create-next-app@latest . --typescript --tailwind --app --no-src-dir --import-alias "@/*"

# 또는 자동 설정
# npx create-next-app@latest . --typescript --tailwind --app --no-src-dir --import-alias "@/*" --use-npm

echo "✅ Phase 3.1 완료: Next.js 프로젝트 생성"
```

### Step 3.2: 추가 의존성 설치

```bash
# UI 라이브러리
npm install lucide-react class-variance-authority clsx tailwind-merge

# HTTP 클라이언트
npm install axios

# 폼 처리
npm install react-hook-form zod @hookform/resolvers

# 상태 관리 (선택)
npm install zustand

echo "✅ Phase 3.2 완료: 추가 의존성 설치"
```

### Step 3.3: shadcn/ui 초기화

```bash
# shadcn/ui 초기화
npx shadcn@latest init

# 필수 컴포넌트 설치
npx shadcn@latest add button
npx shadcn@latest add input
npx shadcn@latest add card
npx shadcn@latest add toast
npx shadcn@latest add dialog

echo "✅ Phase 3.3 완료: shadcn/ui 설정"
```

### Step 3.4: .env.local 생성

```bash
cat > .env.local << 'EOF'
# API 엔드포인트
NEXT_PUBLIC_API_URL="http://localhost:8000"
NEXT_PUBLIC_API_TIMEOUT=30000

# 애플리케이션
NEXT_PUBLIC_APP_NAME="DocuNova"
NEXT_PUBLIC_APP_VERSION="1.0.0"

# 기능 플래그
NEXT_PUBLIC_ENABLE_ANALYTICS=false

# 파일 업로드
NEXT_PUBLIC_MAX_FILE_SIZE=104857600
NEXT_PUBLIC_ALLOWED_FILE_TYPES=".pdf,.docx,.txt,.md"
EOF

echo "✅ Phase 3.4 완료: 환경 변수 설정"
```

### Step 3.5: tsconfig.json 수정 (중요!)

```bash
# Next.js 16 호환성을 위해 jsx 설정 확인
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./*"]
    },
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noUncheckedIndexedAccess": true,
    "strictNullChecks": true
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

echo "✅ Phase 3.5 완료: TypeScript 설정"
```

### Step 3.6: API 클라이언트 생성

```bash
mkdir -p lib

cat > lib/api.ts << 'EOF'
/**
 * API Client for DocuNova Backend
 */

import axios, { AxiosError, AxiosInstance } from 'axios';

export class APIError extends Error {
  constructor(
    message: string,
    public statusCode?: number,
    public originalError?: unknown
  ) {
    super(message);
    this.name = 'APIError';
  }
}

export class NetworkError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'NetworkError';
  }
}

class APIClient {
  private client: AxiosInstance;

  constructor() {
    const baseURL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

    this.client = axios.create({
      baseURL,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // 응답 인터셉터
    this.client.interceptors.response.use(
      (response) => response,
      this.handleError
    );
  }

  private handleError(error: AxiosError): never {
    if (error.code === 'ECONNABORTED' || error.code === 'ERR_NETWORK') {
      throw new NetworkError('네트워크 연결을 확인해주세요');
    }

    const statusCode = error.response?.status;
    const message =
      (error.response?.data as any)?.detail || '알 수 없는 오류가 발생했습니다';

    throw new APIError(message, statusCode, error);
  }

  async healthCheck() {
    const response = await this.client.get('/health');
    return response.data;
  }

  // 추가 메서드는 여기에 구현
}

export const apiClient = new APIClient();
EOF

echo "✅ Phase 3.6 완료: API 클라이언트 생성"
```

### Step 3.7: 프론트엔드 테스트

```bash
# 개발 서버 실행 테스트
npm run dev &
FRONTEND_PID=$!

# 5초 대기
sleep 5

# Health check
curl http://localhost:3000

# 프로세스 종료
kill $FRONTEND_PID

echo "✅ Phase 3.7 완료: 프론트엔드 실행 확인"
```

---

## Phase 4: 핵심 서비스 구현

### Step 4.1: Qdrant 설정

```bash
# Qdrant Docker 실행
docker run -d \
  --name qdrant \
  -p 6333:6333 \
  -p 6334:6334 \
  -v qdrant_storage:/qdrant/storage \
  qdrant/qdrant:latest

# 연결 확인
curl http://localhost:6333

echo "✅ Phase 4.1 완료: Qdrant 실행"
```

### Step 4.2: Ollama 설정

```bash
# Ollama 설치 확인
ollama --version

# 모델 다운로드
ollama pull llama3.1:8b

# 서버 실행 (백그라운드)
ollama serve &

# 테스트
curl http://localhost:11434/api/tags

echo "✅ Phase 4.2 완료: Ollama 설정"
```

### Step 4.3: 백엔드 서비스 구현

상세한 서비스 구현은 `03_IMPLEMENTATION_GUIDE.md`와 `09_LARGE_FILE_PROCESSING_ACCURACY.md`를 참조하세요.

**필수 구현 파일**:
1. `app/services/llm_service.py` - LLM 통신 (재시도 로직 포함)
2. `app/services/embedding_service.py` - 임베딩 생성
3. `app/services/vector_service.py` - Qdrant 연동
4. `app/services/semantic_chunker.py` - 의미론적 청킹
5. `app/services/rag_service.py` - RAG 로직
6. `app/api/v1/chat.py` - 채팅 API
7. `app/api/v1/documents.py` - 문서 업로드 API

---

## Phase 5: 검증 및 테스트

### Step 5.1: 통합 테스트

```bash
cd backend

# 모든 서비스 실행 확인
python -c "
from app.services.llm_service import LLMService
import asyncio

async def test():
    service = LLMService('localhost', 11434, 'llama3.1:8b')
    health = await service.health_check()
    print('LLM Health:', health)

asyncio.run(test())
"

echo "✅ Phase 5.1 완료: 통합 테스트"
```

### Step 5.2: E2E 테스트

```bash
# 백엔드 실행
cd backend
python main.py &
BACKEND_PID=$!

# 프론트엔드 실행
cd ../frontend
npm run dev &
FRONTEND_PID=$!

# 대기
sleep 10

# 테스트
echo "백엔드: http://localhost:8000"
echo "프론트엔드: http://localhost:3000"
echo "Swagger UI: http://localhost:8000/docs"

# 수동으로 브라우저에서 확인
echo "브라우저에서 http://localhost:3000 접속하여 확인하세요"
echo "종료하려면 Ctrl+C를 누르세요"

# 프로세스 정리 (Ctrl+C 후 실행)
# kill $BACKEND_PID $FRONTEND_PID

echo "✅ Phase 5.2 완료: E2E 테스트"
```

---

## 🔍 문제 해결

### 문제 1: Python 버전 오류

**증상**:
```
Python 3.11 or higher is required
```

**해결**:
```bash
# Python 3.11 설치
python3.11 --version

# 가상환경 재생성
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 문제 2: Qdrant 연결 실패

**증상**:
```
Failed to connect to Qdrant at localhost:6333
```

**해결**:
```bash
# Qdrant 실행 확인
docker ps | grep qdrant

# 실행되지 않았으면 시작
docker start qdrant

# 또는 새로 실행
docker run -d --name qdrant -p 6333:6333 qdrant/qdrant:latest
```

### 문제 3: Ollama 모델 다운로드 실패

**증상**:
```
Failed to pull model llama3.1:8b
```

**해결**:
```bash
# Ollama 재시작
killall ollama
ollama serve &

# 모델 재다운로드
ollama pull llama3.1:8b

# 모델 목록 확인
ollama list
```

### 문제 4: Next.js 빌드 오류

**증상**:
```
Error: Route / used `cookies()` without `await`
```

**해결**:
```typescript
// ❌ 잘못됨
const cookieStore = cookies();

// ✅ 올바름
const cookieStore = await cookies();

// Server Component를 async로 변경
export default async function Page() {
  const cookieStore = await cookies();
  // ...
}
```

### 문제 5: CORS 에러

**증상**:
```
Access to fetch at 'http://localhost:8000' blocked by CORS
```

**해결**:
```python
# backend/main.py에서 CORS 설정 확인
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # 프론트엔드 URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)
```

---

## ✅ 완료 체크리스트

프로젝트 템플릿이 올바르게 생성되었는지 확인:

### 백엔드
- [ ] `backend/` 디렉토리 구조 생성됨
- [ ] `requirements.txt` 존재
- [ ] `.env` 파일 존재하고 설정됨
- [ ] 가상환경 생성 및 활성화됨
- [ ] `python main.py` 실행 시 오류 없음
- [ ] `http://localhost:8000/health` 응답 확인

### 프론트엔드
- [ ] `frontend/` 디렉토리 구조 생성됨
- [ ] `package.json` 존재
- [ ] `.env.local` 파일 존재하고 설정됨
- [ ] `node_modules/` 설치됨
- [ ] `npm run dev` 실행 시 오류 없음
- [ ] `http://localhost:3000` 접속 가능

### 인프라
- [ ] Qdrant 컨테이너 실행 중
- [ ] `http://localhost:6333` 응답 확인
- [ ] Ollama 서비스 실행 중
- [ ] `ollama list`에 모델 표시됨

### 통합
- [ ] 백엔드 + 프론트엔드 동시 실행 가능
- [ ] API 통신 정상 작동
- [ ] 문서 업로드 테스트 성공
- [ ] 챗 기능 테스트 성공

---

## 📚 다음 단계

프로젝트 템플릿 생성 완료 후:

1. **서비스 구현**: `03_IMPLEMENTATION_GUIDE.md` 참조
2. **대용량 파일 처리**: `09_LARGE_FILE_PROCESSING_ACCURACY.md` 참조
3. **리스크 완화**: `08_RISK_ANALYSIS_AND_MITIGATION.md` 참조
4. **GitHub Issues**: `scripts/create-github-issues.sh` 실행
5. **테스트 작성**: `tests/` 디렉토리에 단위/통합 테스트 추가

---

## 🎉 완료!

프로젝트 템플릿이 성공적으로 생성되었습니다!

이제 다음 명령어로 개발을 시작하세요:

```bash
# 터미널 1: 백엔드
cd backend
source venv/bin/activate
python main.py

# 터미널 2: 프론트엔드
cd frontend
npm run dev

# 터미널 3: Qdrant (이미 실행 중이면 생략)
docker start qdrant

# 브라우저에서 접속
# - Frontend: http://localhost:3000
# - Backend API: http://localhost:8000
# - API Docs: http://localhost:8000/docs
```

**Happy Coding! 🚀**

---

**작성일**: 2025-10-30
**버전**: 1.0
**상태**: ✅ 완전한 단계별 가이드
