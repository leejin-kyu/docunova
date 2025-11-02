# GitHub Issues 자동 생성 스크립트 (PowerShell)
# DocuNova SaaS 프로젝트 WBS 기반
# 사용법: .\create-github-issues.ps1 -Repo "username/docunova-saas"

param(
    [Parameter(Mandatory=$true)]
    [string]$Repo
)

# 색상 출력 함수
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Prerequisites 체크
Write-Info "필수 요구사항 확인 중..."

# gh CLI 설치 확인
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error-Custom "gh CLI가 설치되어 있지 않습니다."
    Write-Info "설치: winget install GitHub.cli"
    exit 1
}

# gh 인증 확인
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "GitHub 인증이 필요합니다."
    Write-Info "실행: gh auth login"
    exit 1
}

Write-Success "필수 요구사항 확인 완료"

# 날짜 계산
$Today = Get-Date
$M1Date = ($Today.AddDays(3)).ToString("yyyy-MM-dd")
$M2Date = ($Today.AddDays(14)).ToString("yyyy-MM-dd")
$M3Date = ($Today.AddDays(21)).ToString("yyyy-MM-dd")
$M4Date = ($Today.AddDays(25)).ToString("yyyy-MM-dd")
$M5Date = ($Today.AddDays(28)).ToString("yyyy-MM-dd")

# 1. 레이블 생성
Write-Info "GitHub 레이블 생성 중..."

$labels = @(
    # Phase 레이블
    @{name="phase-1"; description="Phase 1: 프로젝트 초기화"; color="0E8A16"},
    @{name="phase-2"; description="Phase 2: 백엔드 개발"; color="1D76DB"},
    @{name="phase-3"; description="Phase 3: 프론트엔드 개발"; color="5319E7"},
    @{name="phase-4"; description="Phase 4: 통합 및 테스트"; color="FBCA04"},
    @{name="phase-5"; description="Phase 5: 배포 및 모니터링"; color="D93F0B"},

    # 역할 레이블
    @{name="backend"; description="백엔드 작업"; color="0052CC"},
    @{name="frontend"; description="프론트엔드 작업"; color="1D76DB"},
    @{name="devops"; description="DevOps/인프라 작업"; color="C5DEF5"},
    @{name="team"; description="팀 전체 작업"; color="FEF2C0"},

    # 우선순위 레이블
    @{name="priority-critical"; description="⭐ 가장 중요"; color="B60205"},
    @{name="priority-high"; description="우선순위: 높음"; color="D93F0B"},
    @{name="priority-medium"; description="우선순위: 중간"; color="FBCA04"},
    @{name="priority-low"; description="우선순위: 낮음"; color="0E8A16"},

    # 작업 유형 레이블
    @{name="setup"; description="환경 설정"; color="C5DEF5"},
    @{name="feature"; description="기능 개발"; color="A2EEEF"},
    @{name="test"; description="테스트"; color="D4C5F9"},
    @{name="documentation"; description="문서화"; color="FEF2C0"},
    @{name="deployment"; description="배포"; color="D93F0B"},

    # 병렬 처리 레이블
    @{name="parallel-ok"; description="✅ 병렬 처리 가능"; color="0E8A16"},
    @{name="sequential"; description="⏳ 순차 처리 필요"; color="D93F0B"}
)

foreach ($label in $labels) {
    try {
        gh label create $label.name --description $label.description --color $label.color --repo $Repo 2>&1 | Out-Null
        Write-Success "레이블 생성: $($label.name)"
    } catch {
        Write-Warning "레이블 이미 존재: $($label.name)"
    }
}

# 2. 마일스톤 생성
Write-Info "GitHub 마일스톤 생성 중..."

$milestones = @(
    @{title="M1: 환경 설정 완료"; due=$M1Date; description="프로젝트 초기화 및 개발 환경 설정 완료"},
    @{title="M2: 백엔드 API 완료"; due=$M2Date; description="백엔드 핵심 기능 및 API 개발 완료"},
    @{title="M3: 프론트엔드 UI 완료"; due=$M3Date; description="프론트엔드 UI 컴포넌트 및 페이지 개발 완료"},
    @{title="M4: 통합 테스트 완료"; due=$M4Date; description="백엔드-프론트엔드 통합 및 E2E 테스트 완료"},
    @{title="M5: 프로덕션 배포"; due=$M5Date; description="프로덕션 환경 배포 및 최종 검증 완료"}
)

foreach ($milestone in $milestones) {
    try {
        $body = @{
            title = $milestone.title
            due_on = "$($milestone.due)T23:59:59Z"
            description = $milestone.description
        } | ConvertTo-Json

        gh api repos/$Repo/milestones -X POST --input - <<< $body 2>&1 | Out-Null
        Write-Success "마일스톤 생성: $($milestone.title)"
    } catch {
        Write-Warning "마일스톤 이미 존재 또는 생성 실패: $($milestone.title)"
    }
}

# 3. Issues 생성 함수
function Create-Issue {
    param(
        [string]$Title,
        [string]$Body,
        [string]$Labels,
        [string]$Milestone
    )

    try {
        gh issue create `
            --repo $Repo `
            --title $Title `
            --body $Body `
            --label $Labels `
            --milestone $Milestone
        Write-Success "Issue 생성: $Title"
    } catch {
        Write-Error-Custom "Issue 생성 실패: $Title"
    }
}

# Phase 1 Issues
Write-Info "Phase 1 Issues 생성 중..."

Create-Issue `
    -Title "[1.1] 프로젝트 구조 생성" `
    -Body @"
## WBS 코드: 1.1
## 예상 시간: 2시간
## 담당: DevOps Engineer
## 선행 작업: 없음
## 병렬 처리: ✅ 가능

### 작업 내용
docunova-saas/ 프로젝트의 기본 디렉토리 구조 생성

### 체크리스트
- [ ] 루트 디렉토리 생성 (docunova-saas/)
- [ ] backend/ 폴더 생성
- [ ] frontend/ 폴더 생성
- [ ] docs/ 폴더 생성
- [ ] .gitignore 파일 생성
- [ ] README.md 초기 작성
- [ ] LICENSE 파일 추가 (선택)

### 참고 문서
- [05_DIRECTORY_STRUCTURE.md](../05_DIRECTORY_STRUCTURE.md)

### 다음 작업
이 작업 완료 후 [1.2], [1.3] 병렬 진행 가능
"@ `
    -Labels "phase-1,setup,devops,priority-high,parallel-ok" `
    -Milestone "M1: 환경 설정 완료"

Create-Issue `
    -Title "[1.2] 백엔드 환경 설정" `
    -Body @"
## WBS 코드: 1.2
## 예상 시간: 4시간
## 담당: Backend Developer
## 선행 작업: [1.1]
## 병렬 처리: ✅ [1.3]과 병렬 가능

### 작업 내용
FastAPI 백엔드 개발 환경 초기화

### 체크리스트
- [ ] Python 3.11+ 설치 확인
- [ ] pyproject.toml 생성
- [ ] requirements.txt 생성
- [ ] Black, isort, Ruff, mypy 설정
- [ ] pre-commit 설정
- [ ] 가상환경 생성 및 활성화
- [ ] 의존성 설치

### 코드 예시
``````toml
# pyproject.toml
[tool.black]
line-length = 88
target-version = ['py311']

[tool.isort]
profile = "black"

[tool.mypy]
python_version = "3.11"
disallow_untyped_defs = true
``````

### 참고 문서
- [06_DEVELOPMENT_ENVIRONMENT_SETUP.md](../06_DEVELOPMENT_ENVIRONMENT_SETUP.md)
- [04_TECHNOLOGY_STACK_REVIEW.md](../04_TECHNOLOGY_STACK_REVIEW.md)
"@ `
    -Labels "phase-1,setup,backend,priority-high,parallel-ok" `
    -Milestone "M1: 환경 설정 완료"

Create-Issue `
    -Title "[1.3] 프론트엔드 환경 설정" `
    -Body @"
## WBS 코드: 1.3
## 예상 시간: 4시간
## 담당: Frontend Developer
## 선행 작업: [1.1]
## 병렬 처리: ✅ [1.2]와 병렬 가능

### 작업 내용
Next.js 16 + React 19 프론트엔드 개발 환경 초기화

### 체크리스트
- [ ] Node.js 20+ 설치 확인
- [ ] Next.js 16 프로젝트 생성
- [ ] TypeScript 5.9+ 설정
- [ ] tsconfig.json 수정 (jsx: "preserve")
- [ ] ESLint 28개 규칙 설정
- [ ] Prettier 설정
- [ ] Husky + lint-staged 설정
- [ ] Tailwind CSS 3.4 설치
- [ ] shadcn/ui 초기화

### 코드 예시
``````json
// tsconfig.json - 중요!
{
  "compilerOptions": {
    "jsx": "preserve",  // ⚠️ Next.js 16 필수
    "strict": true,
    "noUnusedLocals": true,
    "noUncheckedIndexedAccess": true
  }
}
``````

### 참고 문서
- [06_DEVELOPMENT_ENVIRONMENT_SETUP.md](../06_DEVELOPMENT_ENVIRONMENT_SETUP.md)
- [04_TECHNOLOGY_STACK_REVIEW.md](../04_TECHNOLOGY_STACK_REVIEW.md)

### ⚠️ 주의사항
React 19 + Next.js 16 호환성 확인 필수!
"@ `
    -Labels "phase-1,setup,frontend,priority-high,parallel-ok" `
    -Milestone "M1: 환경 설정 완료"

Create-Issue `
    -Title "[1.4] Qdrant 설정" `
    -Body @"
## WBS 코드: 1.4
## 예상 시간: 3시간
## 담당: Backend Developer
## 선행 작업: [1.2]
## 병렬 처리: ⏳ 순차 처리

### 작업 내용
벡터 데이터베이스 Qdrant 설치 및 설정

### 체크리스트
- [ ] Docker 설치 확인
- [ ] Qdrant Docker 이미지 pull
- [ ] Qdrant 컨테이너 실행 (포트: 6333)
- [ ] 연결 테스트
- [ ] 초기 컬렉션 생성
- [ ] FastEmbed 0.3.2 설치

### 코드 예시
``````bash
# Qdrant Docker 실행
docker run -p 6333:6333 -p 6334:6334 \
    -v qdrant_storage:/qdrant/storage \
    qdrant/qdrant
``````

``````python
# 연결 테스트
from qdrant_client import QdrantClient

client = QdrantClient(url="http://localhost:6333")
print(client.get_collections())
``````

### 참고 문서
- [01_SYSTEM_OVERVIEW.md](../01_SYSTEM_OVERVIEW.md)
"@ `
    -Labels "phase-1,setup,backend,priority-high,sequential" `
    -Milestone "M1: 환경 설정 완료"

Create-Issue `
    -Title "[1.5] 초기 테스트 및 검증" `
    -Body @"
## WBS 코드: 1.5
## 예상 시간: 2시간
## 담당: Team (전체)
## 선행 작업: [1.2], [1.3], [1.4]
## 병렬 처리: ⏳ 순차 처리

### 작업 내용
Phase 1 환경 설정 검증

### 체크리스트
- [ ] 백엔드 FastAPI 서버 실행 확인
- [ ] 프론트엔드 Next.js dev 서버 실행 확인
- [ ] Qdrant 연결 확인
- [ ] TypeScript 타입 체크 통과
- [ ] ESLint 검사 통과
- [ ] Python linting 통과
- [ ] pre-commit hooks 작동 확인

### 검증 명령어
``````bash
# 백엔드
cd backend && pytest tests/

# 프론트엔드
cd frontend && npm run type-check && npm run lint
``````

### 참고 문서
- [06_DEVELOPMENT_ENVIRONMENT_SETUP.md](../06_DEVELOPMENT_ENVIRONMENT_SETUP.md)

### 다음 단계
✅ Phase 1 완료 → Phase 2 백엔드 개발 시작
"@ `
    -Labels "phase-1,test,team,priority-high,sequential" `
    -Milestone "M1: 환경 설정 완료"

# Phase 2 Issues (Critical Path)
Write-Info "Phase 2 Issues 생성 중..."

Create-Issue `
    -Title "[2.1] 백엔드 핵심 설정 및 유틸리티" `
    -Body @"
## WBS 코드: 2.1
## 예상 시간: 6시간
## 담당: Backend Developer
## 선행 작업: Phase 1 완료
## 병렬 처리: ✅ 가능

### 작업 내용
백엔드 핵심 설정 파일 및 유틸리티 구현

### 체크리스트
- [ ] app/core/config.py 작성 (환경변수 관리)
- [ ] app/core/logging.py 작성
- [ ] app/middleware/error_handler.py 작성
- [ ] app/middleware/cors.py 작성
- [ ] app/utils/validators.py 작성
- [ ] 단위 테스트 작성

### 코드 예시
``````python
# app/core/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    QDRANT_URL: str = "http://localhost:6333"
    OLLAMA_URL: str = "http://localhost:11434"
    CORS_ORIGINS: list[str] = ["http://localhost:3000"]

    class Config:
        env_file = ".env"

settings = Settings()
``````

### 참고 문서
- [01_SYSTEM_OVERVIEW.md](../01_SYSTEM_OVERVIEW.md)
- [05_DIRECTORY_STRUCTURE.md](../05_DIRECTORY_STRUCTURE.md)
"@ `
    -Labels "phase-2,backend,feature,priority-high,parallel-ok" `
    -Milestone "M2: 백엔드 API 완료"

Create-Issue `
    -Title "[2.2.1] ⭐ LLM 서비스 구현 (CRITICAL)" `
    -Body @"
## WBS 코드: 2.2.1
## 예상 시간: 6시간
## 담당: Backend Developer
## 선행 작업: [2.1]
## 병렬 처리: ⏳ 순차 처리 (가장 중요한 작업)
## 우선순위: ⭐⭐⭐ CRITICAL PATH

### 작업 내용
Ollama LLM 통신 서비스 with 재시도 로직 및 에러 핸들링

### 체크리스트
- [ ] app/services/llm_service.py 생성
- [ ] Ollama API 연결 구현
- [ ] 재시도 로직 구현 (최대 2회)
- [ ] 타임아웃 처리 (30초)
- [ ] Exponential backoff 구현
- [ ] 에러 핸들링 (504, 500 등)
- [ ] Health check 엔드포인트 구현
- [ ] 통합 테스트 작성

### 코드 예시
``````python
# app/services/llm_service.py
import httpx
import asyncio
from fastapi import HTTPException

class LLMService:
    def __init__(self, base_url: str, model: str = "llama2"):
        self.base_url = base_url
        self.model = model

    async def query_with_retry(
        self,
        prompt: str,
        max_retries: int = 2
    ) -> dict:
        """Ollama LLM 통신 with 타임아웃 및 재시도"""
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
                        detail="LLM 서버 응답 없음 (30초 초과)"
                    )
                await asyncio.sleep(1 * (attempt + 1))  # Exponential backoff
            except httpx.HTTPError as e:
                raise HTTPException(
                    status_code=500,
                    detail=f"LLM 서버 오류: {str(e)}"
                )

    async def health_check(self) -> bool:
        """Ollama 서버 헬스 체크"""
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                response = await client.get(f"{self.base_url}/api/tags")
                return response.status_code == 200
        except:
            return False
``````

### 참고 문서
- [01_SYSTEM_OVERVIEW.md](../01_SYSTEM_OVERVIEW.md) - LLM 재시도 로직 섹션
- [04_TECHNOLOGY_STACK_REVIEW.md](../04_TECHNOLOGY_STACK_REVIEW.md) - Ollama 안정성 강화

### ⚠️ 주의사항
이 서비스는 시스템의 핵심입니다. 반드시 에러 핸들링을 철저히 테스트하세요!

### 다음 작업
[2.2.2] 임베딩 서비스, [2.2.3] RAG 서비스 구현
"@ `
    -Labels "phase-2,backend,feature,priority-critical,sequential" `
    -Milestone "M2: 백엔드 API 완료"

Create-Issue `
    -Title "[2.3.4] ⭐ 채팅 API 구현 (CRITICAL)" `
    -Body @"
## WBS 코드: 2.3.4
## 예상 시간: 5시간
## 담당: Backend Developer
## 선행 작업: [2.2.1], [2.2.2], [2.2.3]
## 병렬 처리: ⏳ 순차 처리
## 우선순위: ⭐⭐⭐ CRITICAL PATH

### 작업 내용
채팅 메시지 처리 API 엔드포인트 구현

### 체크리스트
- [ ] POST /api/v1/chat 엔드포인트 구현
- [ ] 메시지 검증 (Pydantic 모델)
- [ ] RAG 서비스 호출
- [ ] LLM 서비스 호출
- [ ] 응답 스트리밍 구현 (선택)
- [ ] 에러 핸들링
- [ ] API 문서 작성 (OpenAPI)
- [ ] 통합 테스트

### 코드 예시
``````python
# app/api/v1/chat.py
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, Field

router = APIRouter()

class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=2000)
    collection_id: str | None = None

class ChatResponse(BaseModel):
    answer: str
    sources: list[dict] = []
    processing_time: float

@router.post("/chat", response_model=ChatResponse)
async def chat(
    request: ChatRequest,
    llm_service: LLMService = Depends(get_llm_service),
    rag_service: RAGService = Depends(get_rag_service)
):
    """채팅 메시지 처리"""
    try:
        # 1. RAG 검색
        context = await rag_service.search_relevant_docs(
            query=request.message,
            collection_id=request.collection_id
        )

        # 2. LLM 호출
        prompt = f"Context: {context}\n\nQuestion: {request.message}"
        llm_response = await llm_service.query_with_retry(prompt)

        return ChatResponse(
            answer=llm_response["response"],
            sources=context.get("sources", []),
            processing_time=llm_response.get("total_duration", 0)
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
``````

### 참고 문서
- [02_ARCHITECTURE_DIAGRAMS.md](../02_ARCHITECTURE_DIAGRAMS.md) - Chat Flow
- [03_IMPLEMENTATION_GUIDE.md](../03_IMPLEMENTATION_GUIDE.md) - Step 1.3

### 다음 작업
[3.1.1] 프론트엔드 API 클라이언트 구현 (병렬 가능)
"@ `
    -Labels "phase-2,backend,feature,priority-critical,sequential" `
    -Milestone "M2: 백엔드 API 완료"

# Phase 3 Issues (Critical Path)
Write-Info "Phase 3 Issues 생성 중..."

Create-Issue `
    -Title "[3.1.1] ⭐ API 클라이언트 구현 (CRITICAL)" `
    -Body @"
## WBS 코드: 3.1.1
## 예상 시간: 4시간
## 담당: Frontend Developer
## 선행 작업: [2.3.4] 완료
## 병렬 처리: ✅ [2.4], [2.5]와 병렬 가능
## 우선순위: ⭐⭐⭐ CRITICAL PATH

### 작업 내용
프론트엔드 API 통신 클라이언트 구현

### 체크리스트
- [ ] lib/api.ts 생성
- [ ] Axios 설치 및 설정
- [ ] API 클라이언트 클래스 구현
- [ ] 에러 핸들링 (NetworkError, APIError)
- [ ] 재시도 로직 구현
- [ ] TypeScript 타입 정의
- [ ] 단위 테스트 (Jest)

### 코드 예시
``````typescript
// lib/api.ts
import axios, { AxiosInstance, AxiosError } from 'axios';

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

  constructor(baseURL: string = process.env.NEXT_PUBLIC_API_URL || '') {
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
    const message = error.response?.data?.detail || '알 수 없는 오류';

    throw new APIError(message, statusCode, error);
  }

  async sendChatMessage(message: string, collectionId?: string) {
    const response = await this.client.post('/api/v1/chat', {
      message,
      collection_id: collectionId,
    });
    return response.data;
  }

  async uploadDocument(file: File, collectionId?: string) {
    const formData = new FormData();
    formData.append('file', file);
    if (collectionId) formData.append('collection_id', collectionId);

    const response = await this.client.post('/api/v1/documents/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return response.data;
  }
}

export const apiClient = new APIClient();
``````

### 참고 문서
- [01_SYSTEM_OVERVIEW.md](../01_SYSTEM_OVERVIEW.md) - API Client Layer
- [05_DIRECTORY_STRUCTURE.md](../05_DIRECTORY_STRUCTURE.md)

### ⚠️ 주의사항
에러 핸들링은 사용자에게 명확한 메시지를 제공해야 합니다!
"@ `
    -Labels "phase-3,frontend,feature,priority-critical,parallel-ok" `
    -Milestone "M3: 프론트엔드 UI 완료"

Create-Issue `
    -Title "[3.2.3] ⭐ 채팅 페이지 구현 (CRITICAL)" `
    -Body @"
## WBS 코드: 3.2.3
## 예상 시간: 12시간
## 담당: Frontend Developer
## 선행 작업: [3.1.1], [3.2.1], [3.2.2]
## 병렬 처리: ⏳ 순차 처리
## 우선순위: ⭐⭐⭐ CRITICAL PATH

### 작업 내용
메인 채팅 페이지 및 UI 구현

### 체크리스트
- [ ] app/chat/page.tsx 생성
- [ ] 채팅 메시지 컴포넌트 구현
- [ ] 메시지 입력 UI 구현
- [ ] 실시간 메시지 전송
- [ ] 로딩 상태 표시
- [ ] 에러 메시지 표시
- [ ] 응답 스트리밍 (선택)
- [ ] 반응형 디자인
- [ ] 접근성 (a11y) 확인
- [ ] E2E 테스트 (Playwright)

### 코드 예시
``````typescript
// app/chat/page.tsx
'use client';

import { useState } from 'react';
import { apiClient, APIError, NetworkError } from '@/lib/api';
import { MessageList } from '@/components/chat/message-list';
import { MessageInput } from '@/components/chat/message-input';
import { ErrorBoundary } from '@/components/common/error-boundary';

interface Message {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: Date;
}

export default function ChatPage() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSendMessage = async (content: string) => {
    if (!content.trim()) return;

    const userMessage: Message = {
      id: crypto.randomUUID(),
      role: 'user',
      content,
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setIsLoading(true);
    setError(null);

    try {
      const response = await apiClient.sendChatMessage(content);

      const assistantMessage: Message = {
        id: crypto.randomUUID(),
        role: 'assistant',
        content: response.answer,
        timestamp: new Date(),
      };

      setMessages((prev) => [...prev, assistantMessage]);
    } catch (err) {
      if (err instanceof NetworkError) {
        setError('네트워크 연결을 확인해주세요');
      } else if (err instanceof APIError) {
        setError(err.message);
      } else {
        setError('알 수 없는 오류가 발생했습니다');
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <ErrorBoundary>
      <div className="flex flex-col h-screen">
        <MessageList messages={messages} isLoading={isLoading} />
        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3">
            {error}
          </div>
        )}
        <MessageInput onSend={handleSendMessage} disabled={isLoading} />
      </div>
    </ErrorBoundary>
  );
}
``````

### 참고 문서
- [DocuNova_NextJS_UI_Reference](../../DocuNova_NextJS_UI_Reference/) - UI 디자인 참고
- [02_ARCHITECTURE_DIAGRAMS.md](../02_ARCHITECTURE_DIAGRAMS.md) - Chat Flow
- [03_IMPLEMENTATION_GUIDE.md](../03_IMPLEMENTATION_GUIDE.md)

### ⚠️ 주의사항
- React 19 async/await 패턴 준수
- 에러 바운더리 필수 적용
- 로딩 상태 명확히 표시

### 다음 작업
[4.1] 백엔드-프론트엔드 통합 테스트
"@ `
    -Labels "phase-3,frontend,feature,priority-critical,sequential" `
    -Milestone "M3: 프론트엔드 UI 완료"

# Phase 4 Issue
Write-Info "Phase 4 Issue 생성 중..."

Create-Issue `
    -Title "[4.1] 백엔드-프론트엔드 통합" `
    -Body @"
## WBS 코드: 4.1
## 예상 시간: 12시간
## 담당: Team (전체)
## 선행 작업: Phase 2, Phase 3 완료
## 병렬 처리: ⏳ 순차 처리

### 작업 내용
백엔드와 프론트엔드 통합 및 E2E 테스트

### 체크리스트
- [ ] CORS 설정 확인
- [ ] API 엔드포인트 연결 테스트
- [ ] 채팅 플로우 E2E 테스트
- [ ] 문서 업로드 플로우 E2E 테스트
- [ ] 에러 핸들링 시나리오 테스트
- [ ] 성능 테스트 (응답 시간)
- [ ] 동시 접속 테스트
- [ ] 버그 수정 및 리팩토링

### 테스트 시나리오
``````typescript
// tests/e2e/chat-flow.spec.ts (Playwright)
import { test, expect } from '@playwright/test';

test('채팅 메시지 전송 및 응답', async ({ page }) => {
  await page.goto('http://localhost:3000/chat');

  // 메시지 입력
  await page.fill('[data-testid="message-input"]', '안녕하세요');
  await page.click('[data-testid="send-button"]');

  // 로딩 상태 확인
  await expect(page.locator('[data-testid="loading"]')).toBeVisible();

  // 응답 확인
  await expect(page.locator('[data-testid="assistant-message"]')).toBeVisible({
    timeout: 30000,
  });
});
``````

### 참고 문서
- [02_ARCHITECTURE_DIAGRAMS.md](../02_ARCHITECTURE_DIAGRAMS.md)
- [03_IMPLEMENTATION_GUIDE.md](../03_IMPLEMENTATION_GUIDE.md)

### 다음 작업
[5.4] 최종 검증 및 프로덕션 배포
"@ `
    -Labels "phase-4,test,team,priority-high,sequential" `
    -Milestone "M4: 통합 테스트 완료"

# Phase 5 Issue
Write-Info "Phase 5 Issue 생성 중..."

Create-Issue `
    -Title "[5.4] 최종 검증 및 프로덕션 배포" `
    -Body @"
## WBS 코드: 5.4
## 예상 시간: 6시간
## 담당: DevOps Engineer + Team
## 선행 작업: Phase 1-4 완료
## 병렬 처리: ⏳ 순차 처리

### 작업 내용
프로덕션 환경 배포 및 최종 검증

### 체크리스트
- [ ] 프로덕션 환경변수 설정
- [ ] 프론트엔드 빌드 (npm run build)
- [ ] 백엔드 Docker 이미지 빌드
- [ ] 배포 스크립트 실행
- [ ] 헬스 체크 확인
- [ ] 프로덕션 E2E 테스트
- [ ] 성능 모니터링 설정
- [ ] 에러 로깅 확인
- [ ] 백업 시스템 확인
- [ ] 문서 최종 업데이트

### 배포 명령어
``````bash
# 프론트엔드 빌드
cd frontend
npm run build
npm run start

# 백엔드 배포
cd backend
docker build -t docunova-backend .
docker run -d -p 8000:8000 docunova-backend
``````

### 참고 문서
- [07_WBS_PROJECT_PLAN.md](../07_WBS_PROJECT_PLAN.md)
- [03_IMPLEMENTATION_GUIDE.md](../03_IMPLEMENTATION_GUIDE.md)

### 🎉 프로젝트 완료!
모든 마일스톤 달성 축하합니다!
"@ `
    -Labels "phase-5,deployment,devops,team,priority-high,sequential" `
    -Milestone "M5: 프로덕션 배포"

Write-Success "`n✅ GitHub Issues 생성 완료!"
Write-Info "총 13개의 주요 Issue가 생성되었습니다."
Write-Info ""
Write-Info "다음 단계:"
Write-Info "1. GitHub 저장소에서 Issues 탭 확인"
Write-Info "2. Projects 보드 생성하여 칸반 뷰로 관리"
Write-Info "3. 팀원에게 작업 할당"
Write-Info "4. 마일스톤별로 진행 상황 추적"
Write-Info ""
Write-Info "📊 생성된 마일스톤:"
Write-Info "  - M1: 환경 설정 완료 ($M1Date)"
Write-Info "  - M2: 백엔드 API 완료 ($M2Date)"
Write-Info "  - M3: 프론트엔드 UI 완료 ($M3Date)"
Write-Info "  - M4: 통합 테스트 완료 ($M4Date)"
Write-Info "  - M5: 프로덕션 배포 ($M5Date)"
