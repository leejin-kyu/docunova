#!/bin/bash

###############################################################################
# DocuNova GitHub Issues 자동 생성 스크립트
# WBS 기반으로 모든 작업을 GitHub Issues로 생성합니다.
#
# 사용법:
#   ./create-github-issues.sh [repository]
#
# 예시:
#   ./create-github-issues.sh username/docunova-saas
#
# 사전 요구사항:
#   - gh CLI 설치 (https://cli.github.com/)
#   - gh auth login 완료
###############################################################################

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로깅 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# GitHub CLI 확인
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        log_error "gh CLI가 설치되어 있지 않습니다."
        log_info "설치: https://cli.github.com/"
        exit 1
    fi
    log_success "gh CLI 확인 완료"
}

# 인증 확인
check_gh_auth() {
    if ! gh auth status &> /dev/null; then
        log_error "GitHub 인증이 필요합니다."
        log_info "실행: gh auth login"
        exit 1
    fi
    log_success "GitHub 인증 확인 완료"
}

# 저장소 확인
REPO="${1}"
if [ -z "$REPO" ]; then
    log_error "저장소를 지정해주세요."
    echo "사용법: $0 username/repository"
    exit 1
fi

log_info "GitHub Issues 생성 시작..."
log_info "저장소: $REPO"

# 사전 확인
check_gh_cli
check_gh_auth

# 레이블 생성 함수
create_labels() {
    log_info "레이블 생성 중..."

    # Phase 레이블
    gh label create "phase-1" --description "Phase 1: 프로젝트 초기화" --color "0E8A16" --repo "$REPO" 2>/dev/null || true
    gh label create "phase-2" --description "Phase 2: 백엔드 개발" --color "1D76DB" --repo "$REPO" 2>/dev/null || true
    gh label create "phase-3" --description "Phase 3: 프론트엔드 개발" --color "5319E7" --repo "$REPO" 2>/dev/null || true
    gh label create "phase-4" --description "Phase 4: 통합 및 테스트" --color "D93F0B" --repo "$REPO" 2>/dev/null || true
    gh label create "phase-5" --description "Phase 5: 배포 및 문서화" --color "FBCA04" --repo "$REPO" 2>/dev/null || true

    # 담당자 레이블
    gh label create "backend" --description "Backend Developer" --color "0052CC" --repo "$REPO" 2>/dev/null || true
    gh label create "frontend" --description "Frontend Developer" --color "5319E7" --repo "$REPO" 2>/dev/null || true
    gh label create "devops" --description "DevOps" --color "D4C5F9" --repo "$REPO" 2>/dev/null || true
    gh label create "team" --description "전체 팀" --color "BFDADC" --repo "$REPO" 2>/dev/null || true

    # 우선순위 레이블
    gh label create "priority-critical" --description "⭐ 가장 중요" --color "B60205" --repo "$REPO" 2>/dev/null || true
    gh label create "priority-high" --description "높은 우선순위" --color "D93F0B" --repo "$REPO" 2>/dev/null || true
    gh label create "priority-medium" --description "중간 우선순위" --color "FBCA04" --repo "$REPO" 2>/dev/null || true
    gh label create "priority-low" --description "낮은 우선순위" --color "0E8A16" --repo "$REPO" 2>/dev/null || true

    # 작업 타입 레이블
    gh label create "setup" --description "환경 설정" --color "C5DEF5" --repo "$REPO" 2>/dev/null || true
    gh label create "feature" --description "새 기능" --color "A2EEEF" --repo "$REPO" 2>/dev/null || true
    gh label create "test" --description "테스트" --color "D4C5F9" --repo "$REPO" 2>/dev/null || true
    gh label create "documentation" --description "문서화" --color "0075CA" --repo "$REPO" 2>/dev/null || true
    gh label create "deployment" --description "배포" --color "FBCA04" --repo "$REPO" 2>/dev/null || true

    # 병렬 처리 레이블
    gh label create "parallel-ok" --description "✅ 병렬 처리 가능" --color "0E8A16" --repo "$REPO" 2>/dev/null || true
    gh label create "sequential" --description "❌ 순차 처리 필요" --color "B60205" --repo "$REPO" 2>/dev/null || true

    log_success "레이블 생성 완료"
}

# Milestone 생성 함수
create_milestones() {
    log_info "Milestone 생성 중..."

    # 현재 날짜 기준으로 마일스톤 날짜 계산
    TODAY=$(date +%Y-%m-%d)

    # M1: 환경 설정 완료 (Day 3)
    M1_DATE=$(date -d "$TODAY + 3 days" +%Y-%m-%d 2>/dev/null || date -v +3d +%Y-%m-%d)
    gh api repos/"$REPO"/milestones -X POST -f title="M1: 환경 설정 완료" \
        -f description="백엔드/프론트엔드 개발 서버 실행" \
        -f due_on="${M1_DATE}T23:59:59Z" 2>/dev/null || true

    # M2: 백엔드 API 완료 (Week 2)
    M2_DATE=$(date -d "$TODAY + 14 days" +%Y-%m-%d 2>/dev/null || date -v +14d +%Y-%m-%d)
    gh api repos/"$REPO"/milestones -X POST -f title="M2: 백엔드 API 완료" \
        -f description="모든 API 엔드포인트 작동" \
        -f due_on="${M2_DATE}T23:59:59Z" 2>/dev/null || true

    # M3: 프론트엔드 UI 완료 (Week 3)
    M3_DATE=$(date -d "$TODAY + 21 days" +%Y-%m-%d 2>/dev/null || date -v +21d +%Y-%m-%d)
    gh api repos/"$REPO"/milestones -X POST -f title="M3: 프론트엔드 UI 완료" \
        -f description="모든 페이지 렌더링" \
        -f due_on="${M3_DATE}T23:59:59Z" 2>/dev/null || true

    # M4: 통합 테스트 완료 (Week 3.5)
    M4_DATE=$(date -d "$TODAY + 24 days" +%Y-%m-%d 2>/dev/null || date -v +24d +%Y-%m-%d)
    gh api repos/"$REPO"/milestones -X POST -f title="M4: 통합 테스트 완료" \
        -f description="E2E 테스트 통과" \
        -f due_on="${M4_DATE}T23:59:59Z" 2>/dev/null || true

    # M5: 프로덕션 배포 (Week 4)
    M5_DATE=$(date -d "$TODAY + 28 days" +%Y-%m-%d 2>/dev/null || date -v +28d +%Y-%m-%d)
    gh api repos/"$REPO"/milestones -X POST -f title="M5: 프로덕션 배포" \
        -f description="배포 완료 및 모니터링" \
        -f due_on="${M5_DATE}T23:59:59Z" 2>/dev/null || true

    log_success "Milestone 생성 완료"
}

# Issue 생성 함수
create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"
    local milestone="$4"
    local assignee="$5"

    local cmd="gh issue create --repo $REPO --title \"$title\" --body \"$body\" --label \"$labels\""

    if [ -n "$milestone" ]; then
        cmd="$cmd --milestone \"$milestone\""
    fi

    if [ -n "$assignee" ]; then
        cmd="$cmd --assignee \"$assignee\""
    fi

    eval $cmd
}

# 레이블과 마일스톤 생성
create_labels
create_milestones

log_info "GitHub Issues 생성 중..."

###############################################################################
# Phase 1: 프로젝트 초기화 및 환경 설정
###############################################################################

log_info "Phase 1 Issues 생성 중..."

# 1.1 프로젝트 구조 생성
create_issue \
    "[1.1] 프로젝트 구조 생성" \
    "## WBS 코드: 1.1
## 작업 시간: 2시간
## 담당: DevOps

### 작업 내용

\`\`\`bash
# 1.1.1: 프로젝트 루트 생성 (15분)
mkdir docunova-saas
cd docunova-saas

# 1.1.2: Git 초기화 (15분)
git init

# 1.1.3: 디렉토리 구조 생성 (30분)
mkdir -p backend/app/{api/v1,core,services,models,utils,db,middleware}
mkdir -p frontend/{app,components,lib,hooks,public}
mkdir -p data/{uploads,processed}
mkdir -p logs/{backend,frontend}
mkdir -p docs scripts

# 1.1.4: README 및 문서 복사 (30분)
# 아키텍처 문서 복사
\`\`\`

### 체크리스트

- [ ] Git 저장소 초기화
- [ ] 기본 디렉토리 구조 생성
- [ ] .gitignore 설정
- [ ] README.md 생성

### 선행 작업
없음

### 관련 문서
- \`05_DIRECTORY_STRUCTURE.md\`" \
    "phase-1,setup,devops,priority-high,parallel-ok" \
    "M1: 환경 설정 완료"

# 1.2 백엔드 환경 설정
create_issue \
    "[1.2] 백엔드 환경 설정" \
    "## WBS 코드: 1.2
## 작업 시간: 4시간
## 담당: Backend Developer

### 작업 내용

#### 1.2.1: Python 가상환경 설정 (30분)
\`\`\`bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\\Scripts\\activate
\`\`\`

#### 1.2.2: 의존성 설치 (30분)
\`\`\`bash
pip install fastapi==0.115.0
pip install uvicorn==0.30.6
pip install qdrant-client==1.12.1
pip install fastembed==0.3.2
# ... (requirements.txt 참고)
pip freeze > requirements.txt
\`\`\`

#### 1.2.3: 개발 환경 설정 (1시간)
- pyproject.toml 생성
- .pre-commit-config.yaml 생성
- pre-commit install

#### 1.2.4: 환경 변수 설정 (30분)
- .env.example 생성
- .env 생성 및 설정

#### 1.2.5: VS Code 설정 (30분)
- .vscode/settings.json 생성

#### 1.2.6: Ollama 설치 및 모델 다운로드 (1시간)
\`\`\`bash
ollama serve
ollama pull llama3.1:8b
ollama list
\`\`\`

### 체크리스트

- [ ] Python 3.11 설치 확인
- [ ] 가상환경 생성 및 활성화
- [ ] requirements.txt 생성
- [ ] requirements-dev.txt 생성
- [ ] pyproject.toml 생성
- [ ] pre-commit hooks 설치
- [ ] .env 파일 설정
- [ ] Ollama 설치 및 모델 다운로드
- [ ] VS Code 설정 완료

### 선행 작업
- #1 (1.1 프로젝트 구조 생성)

### 병렬 처리
✅ 1.3과 동시 진행 가능

### 관련 문서
- \`06_DEVELOPMENT_ENVIRONMENT_SETUP.md\`
- \`requirements.txt\`
- \`requirements-dev.txt\`" \
    "phase-1,setup,backend,priority-high,parallel-ok" \
    "M1: 환경 설정 완료"

# 1.3 프론트엔드 환경 설정
create_issue \
    "[1.3] 프론트엔드 환경 설정" \
    "## WBS 코드: 1.3
## 작업 시간: 4시간
## 담당: Frontend Developer

### 작업 내용

#### 1.3.1: Next.js 프로젝트 생성 (30분)
\`\`\`bash
cd frontend
npx create-next-app@latest . --typescript --tailwind --app --no-src-dir --import-alias \"@/*\"
\`\`\`

#### 1.3.2: UI 라이브러리 설치 (30분)
\`\`\`bash
npx shadcn@latest init
npx shadcn@latest add button card input dialog alert toast tabs
\`\`\`

#### 1.3.3: 개발 도구 설치 (1시간)
\`\`\`bash
npm install --save-dev @typescript-eslint/eslint-plugin @typescript-eslint/parser prettier prettier-plugin-tailwindcss husky lint-staged
\`\`\`

#### 1.3.4: 개발 환경 설정 (1.5시간)
- tsconfig.json 수정 (jsx: \"preserve\")
- .eslintrc.json 생성
- .prettierrc.json 생성
- next.config.mjs 보안 설정
- Husky pre-commit hooks 설정

#### 1.3.5: 환경 변수 설정 (30분)
- .env.local.example 생성
- .env.local 생성

### 체크리스트

- [ ] Next.js 16 설치
- [ ] TypeScript 설정
- [ ] Tailwind CSS 설정
- [ ] shadcn/ui 초기화 및 컴포넌트 설치
- [ ] ESLint 플러그인 설치
- [ ] Prettier 설치
- [ ] Husky 설치 및 설정
- [ ] tsconfig.json 수정 완료
- [ ] .eslintrc.json 생성
- [ ] next.config.mjs 보안 설정
- [ ] 환경 변수 설정

### 선행 작업
- #1 (1.1 프로젝트 구조 생성)

### 병렬 처리
✅ 1.2와 동시 진행 가능

### 관련 문서
- \`06_DEVELOPMENT_ENVIRONMENT_SETUP.md\`" \
    "phase-1,setup,frontend,priority-high,parallel-ok" \
    "M1: 환경 설정 완료"

# 1.4 Qdrant 설정
create_issue \
    "[1.4] Qdrant 설정" \
    "## WBS 코드: 1.4
## 작업 시간: 1시간
## 담당: Backend Developer

### 작업 내용

\`\`\`bash
# Docker로 Qdrant 실행
docker run -p 6333:6333 qdrant/qdrant

# 또는 로컬 모드 (Python 코드에서)
# QdrantClient(path=\"./qdrant_storage\")
\`\`\`

### 체크리스트

- [ ] Qdrant 서버 실행 (Docker 또는 로컬)
- [ ] 포트 6333 확인
- [ ] 웹 UI 접속 테스트 (http://localhost:6333/dashboard)
- [ ] 컬렉션 생성 테스트

### 선행 작업
- #2 (1.2 백엔드 환경 설정 - 의존성 설치 완료 후)

### 병렬 처리
✅ 1.3과 동시 진행 가능" \
    "phase-1,setup,backend,priority-medium,parallel-ok" \
    "M1: 환경 설정 완료"

# 1.5 초기 테스트 및 검증
create_issue \
    "[1.5] 초기 테스트 및 검증" \
    "## WBS 코드: 1.5
## 작업 시간: 2시간
## 담당: 전체 팀

### 작업 내용

#### 1.5.1: 백엔드 헬스체크 (30분)
\`\`\`bash
cd backend
python -c \"import fastapi; print('FastAPI OK')\"
python -c \"import qdrant_client; print('Qdrant OK')\"
python -c \"import fastembed; print('FastEmbed OK')\"
curl http://localhost:11434/api/tags  # Ollama 테스트
\`\`\`

#### 1.5.2: 프론트엔드 빌드 테스트 (30분)
\`\`\`bash
cd frontend
npm run type-check
npm run lint
npm run build
\`\`\`

#### 1.5.3: Git 커밋 테스트 (30분)
\`\`\`bash
git add .
git commit -m \"chore: initial project setup\"
\`\`\`

#### 1.5.4: 문서 정리 (30분)
- 환경 설정 문서 업데이트
- 팀원에게 설정 공유

### 체크리스트

- [ ] 모든 백엔드 패키지 import 성공
- [ ] Ollama 연결 확인
- [ ] Qdrant 연결 확인
- [ ] TypeScript 에러 0개
- [ ] ESLint 에러 0개
- [ ] 빌드 성공
- [ ] Pre-commit hooks 정상 작동
- [ ] 커밋 성공

### 선행 작업
- #2 (1.2 백엔드 환경 설정)
- #3 (1.3 프론트엔드 환경 설정)
- #4 (1.4 Qdrant 설정)

### 병렬 처리
❌ 순차 진행 필요" \
    "phase-1,test,team,priority-high,sequential" \
    "M1: 환경 설정 완료"

log_success "Phase 1 Issues 생성 완료 (5개)"

###############################################################################
# Phase 2: 백엔드 개발 (주요 작업만 생성, 나머지는 필요시 추가)
###############################################################################

log_info "Phase 2 주요 Issues 생성 중..."

# 2.1 핵심 설정 및 유틸리티
create_issue \
    "[2.1] 백엔드 핵심 설정 및 유틸리티" \
    "## WBS 코드: 2.1
## 작업 시간: 8시간
## 담당: Backend Developer

### 작업 내용

#### 2.1.1: 설정 모듈 (2시간)
- \`backend/app/core/config.py\` 구현
- Pydantic Settings 사용
- 환경 변수 매핑

#### 2.1.2: 로깅 설정 (1시간)
- \`backend/app/core/logging.py\` 구현
- 파일 및 콘솔 로깅
- 에러 로그 분리

#### 2.1.3: 예외 처리 (2시간)
- \`backend/app/core/exceptions.py\` 구현
- 커스텀 예외 클래스 정의

#### 2.1.4: 유틸리티 함수 (3시간)
- \`backend/app/utils/file_utils.py\`
- \`backend/app/utils/text_utils.py\`
- \`backend/app/utils/validators.py\`

### 체크리스트

- [ ] Pydantic Settings 구현
- [ ] 로깅 설정 완료
- [ ] 커스텀 예외 클래스 정의
- [ ] 파일 유틸리티 구현
- [ ] 텍스트 처리 유틸리티 구현
- [ ] 검증 함수 구현
- [ ] 단위 테스트 작성

### 선행 작업
- #5 (1.5 초기 테스트 및 검증)

### 관련 문서
- \`05_DIRECTORY_STRUCTURE.md\`" \
    "phase-2,feature,backend,priority-high,sequential" \
    "M2: 백엔드 API 완료"

# 2.2.1 LLM 서비스 (가장 중요!)
create_issue \
    "[2.2.1] ⭐ LLM 서비스 구현 (가장 중요!)" \
    "## WBS 코드: 2.2.1
## 작업 시간: 6시간
## 담당: Backend Developer

### ⚠️ 중요도: 가장 중요!

이 작업은 **DocuNova의 핵심 기능**입니다. Ollama와의 통신 안정성이 전체 시스템의 품질을 결정합니다.

### 작업 내용

\`\`\`python
# backend/app/services/llm_service.py

import httpx
import asyncio
from fastapi import HTTPException

class LLMService:
    def __init__(self, host: str, port: int, model: str):
        self.base_url = f\"http://{host}:{port}\"
        self.model = model

    async def query_with_retry(
        self,
        prompt: str,
        max_retries: int = 2
    ) -> dict:
        \"\"\"재시도 로직 포함 LLM 질의\"\"\"
        for attempt in range(max_retries):
            try:
                async with httpx.AsyncClient(timeout=30.0) as client:
                    response = await client.post(
                        f\"{self.base_url}/api/generate\",
                        json={\"model\": self.model, \"prompt\": prompt}
                    )
                    response.raise_for_status()
                    return response.json()

            except httpx.TimeoutException:
                if attempt == max_retries - 1:
                    raise HTTPException(
                        status_code=504,
                        detail=\"LLM 응답 시간 초과\"
                    )
                await asyncio.sleep(1 * (attempt + 1))

            except httpx.ConnectError:
                raise HTTPException(
                    status_code=503,
                    detail=\"LLM 서버 연결 불가\"
                )

    async def health_check(self) -> dict:
        \"\"\"LLM 헬스체크\"\"\"
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                response = await client.get(f\"{self.base_url}/api/tags\")
                return {\"status\": \"healthy\", \"models\": response.json()}
        except Exception as e:
            return {\"status\": \"unhealthy\", \"error\": str(e)}
\`\`\`

### 체크리스트

- [ ] LLMService 클래스 구현
- [ ] query_with_retry 메서드 (타임아웃, 재시도)
- [ ] health_check 메서드
- [ ] 에러 핸들링 완벽 구현
- [ ] 통합 테스트 (실제 Ollama와 연동)
- [ ] 타입 힌트 및 docstring
- [ ] 로깅 추가

### 선행 작업
- #6 (2.1 핵심 설정 및 유틸리티)

### 관련 문서
- \`04_TECHNOLOGY_STACK_REVIEW.md\` - Ollama 통합 안정성
- \`01_SYSTEM_OVERVIEW.md\` - LLM 통신 안정성" \
    "phase-2,feature,backend,priority-critical,sequential" \
    "M2: 백엔드 API 완료"

# 2.3.4 채팅 API (가장 중요!)
create_issue \
    "[2.3.4] ⭐ 채팅 API 구현 (가장 중요!)" \
    "## WBS 코드: 2.3.4
## 작업 시간: 5시간
## 담당: Backend Developer

### ⚠️ 중요도: 가장 중요!

DocuNova의 **메인 기능**입니다. RAG와 LLM 모드를 모두 지원해야 합니다.

### 작업 내용

\`\`\`python
# backend/app/api/v1/chat.py

from fastapi import APIRouter
from fastapi.responses import StreamingResponse

router = APIRouter(prefix=\"/chat\", tags=[\"chat\"])

@router.post(\"/query\")
async def query(request: ChatRequest):
    \"\"\"일반 채팅 (비스트리밍)\"\"\"
    # 1. 질문 검증
    # 2. RAG/LLM 모드 확인
    # 3. RAG: 벡터 검색 → 컨텍스트 생성
    # 4. LLM 질의
    # 5. 응답 반환
    pass

@router.post(\"/query_stream\")
async def query_stream(request: ChatRequest):
    \"\"\"스트리밍 채팅\"\"\"
    async def generate():
        # SSE 스트리밍 응답
        pass

    return StreamingResponse(generate(), media_type=\"text/event-stream\")
\`\`\`

### 체크리스트

- [ ] 일반 채팅 엔드포인트 구현
- [ ] 스트리밍 채팅 엔드포인트 구현
- [ ] RAG 모드 구현 (벡터 검색 + 컨텍스트)
- [ ] LLM 모드 구현
- [ ] 요청/응답 모델 정의 (Pydantic)
- [ ] 에러 핸들링
- [ ] API 테스트 (Postman/Thunder Client)
- [ ] 문서화

### 선행 작업
- #7 (2.2.1 LLM 서비스)
- 임베딩 서비스
- 벡터 DB 서비스
- 문서 처리 서비스

### 병렬 처리
✅ 다른 API와 병렬 개발 가능 (서비스 레이어 완료 후)" \
    "phase-2,feature,backend,priority-critical,parallel-ok" \
    "M2: 백엔드 API 완료"

log_success "Phase 2 주요 Issues 생성 완료 (3개)"

###############################################################################
# Phase 3: 프론트엔드 개발 (주요 작업만 생성)
###############################################################################

log_info "Phase 3 주요 Issues 생성 중..."

# 3.1.1 API 클라이언트 (가장 중요!)
create_issue \
    "[3.1.1] ⭐ API 클라이언트 구현 (가장 중요!)" \
    "## WBS 코드: 3.1.1
## 작업 시간: 4시간
## 담당: Frontend Developer

### ⚠️ 중요도: 가장 중요!

프론트엔드의 **핵심 인프라**입니다. 모든 HTTP 통신이 이 클라이언트를 통해 이루어집니다.

### 작업 내용

\`\`\`typescript
// frontend/lib/api.ts

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
        throw new Error(\`HTTP error! status: \${response.status}\`);
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
    const response = await this.fetchWithRetry(\`\${this.baseURL}\${endpoint}\`, {
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
\`\`\`

### 체크리스트

- [ ] APIClient 클래스 구현
- [ ] fetchWithRetry (타임아웃, 재시도)
- [ ] get, post, delete 메서드
- [ ] 에러 핸들링
- [ ] 타입 정의 (\`types.ts\`)
- [ ] 단위 테스트

### 선행 작업
- #5 (1.5 초기 테스트 및 검증)

### 관련 문서
- \`06_DEVELOPMENT_ENVIRONMENT_SETUP.md\`
- \`01_SYSTEM_OVERVIEW.md\` - API 클라이언트 레이어" \
    "phase-3,feature,frontend,priority-critical,sequential" \
    "M3: 프론트엔드 UI 완료"

# 3.2.3 채팅 페이지 (가장 중요!)
create_issue \
    "[3.2.3] ⭐ 채팅 페이지 구현 (가장 중요!)" \
    "## WBS 코드: 3.2.3
## 작업 시간: 12시간
## 담당: Frontend Developer

### ⚠️ 중요도: 가장 중요!

DocuNova의 **메인 UI**입니다. 사용자 경험의 핵심입니다.

### 작업 내용

#### 페이지 구조
\`\`\`typescript
// app/chat/page.tsx
export default function ChatPage() {
  const { messages, isLoading, error, sendMessage } = useChat();

  return (
    <div className=\"container mx-auto h-screen flex flex-col\">
      <MessageList messages={messages} />
      <MessageInput onSend={sendMessage} isLoading={isLoading} />
      {error && <ErrorMessage message={error} />}
    </div>
  );
}
\`\`\`

#### 컴포넌트
1. **MessageList**: 메시지 목록 표시
2. **MessageInput**: 사용자 입력
3. **MessageBubble**: 개별 메시지

### 체크리스트

- [ ] ChatInterface 컴포넌트
- [ ] MessageList 컴포넌트
- [ ] MessageInput 컴포넌트
- [ ] MessageBubble 컴포넌트
- [ ] RAG/LLM 모드 토글
- [ ] 스트리밍 응답 처리
- [ ] 로딩 상태 표시
- [ ] 에러 핸들링
- [ ] 반응형 디자인
- [ ] 접근성 (ARIA)

### 선행 작업
- #9 (3.1.1 API 클라이언트)
- useChat Hook
- 레이아웃 및 에러 바운더리

### 병렬 처리
✅ 다른 페이지와 병렬 개발 가능

### 관련 문서
- UI Reference 문서" \
    "phase-3,feature,frontend,priority-critical,parallel-ok" \
    "M3: 프론트엔드 UI 완료"

log_success "Phase 3 주요 Issues 생성 완료 (2개)"

###############################################################################
# Phase 4: 통합 및 테스트
###############################################################################

log_info "Phase 4 Issues 생성 중..."

# 4.1 백엔드-프론트엔드 통합
create_issue \
    "[4.1] 백엔드-프론트엔드 통합" \
    "## WBS 코드: 4.1
## 작업 시간: 16시간
## 담당: 전체 팀

### 작업 내용

#### 4.1.1: 로컬 통합 테스트 (8시간)

\`\`\`bash
# 터미널 1: 백엔드
cd backend
python main.py

# 터미널 2: 프론트엔드
cd frontend
npm run dev

# 브라우저: http://localhost:3000
\`\`\`

**테스트 시나리오**:
1. 문서 업로드
2. RAG 모드 채팅
3. LLM 모드 채팅
4. 문서 삭제
5. 대시보드 확인

#### 4.1.2: 버그 수정 (8시간)

### 체크리스트

- [ ] 문서 업로드 정상 작동
- [ ] 채팅 정상 작동 (RAG/LLM)
- [ ] 문서 삭제 정상 작동
- [ ] 통계 표시 정상 작동
- [ ] 에러 핸들링 확인
- [ ] CORS 이슈 없음
- [ ] 모든 critical 버그 수정
- [ ] UI 오류 0개
- [ ] 재테스트 완료

### 선행 작업
- Phase 2 완료 (백엔드)
- Phase 3 완료 (프론트엔드)

### 병렬 처리
❌ 순차 진행 필요" \
    "phase-4,test,team,priority-critical,sequential" \
    "M4: 통합 테스트 완료"

log_success "Phase 4 Issues 생성 완료 (1개)"

###############################################################################
# Phase 5: 배포 및 문서화
###############################################################################

log_info "Phase 5 Issues 생성 중..."

# 5.4 최종 검증 및 배포
create_issue \
    "[5.4] 최종 검증 및 프로덕션 배포" \
    "## WBS 코드: 5.4
## 작업 시간: 4시간
## 담당: 전체 팀

### 작업 내용

#### 5.4.1: 최종 체크리스트 (2시간)

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

#### 5.4.2: 프로덕션 배포 (2시간)

\`\`\`bash
# 프로덕션 서버에서
./scripts/start-prod.sh

# 헬스체크
curl http://localhost:8000/api/v1/health
curl http://localhost:3000

# 모니터링 시작
tail -f logs/backend/app.log
\`\`\`

### 체크리스트

- [ ] 프로덕션 서버 실행
- [ ] 헬스체크 통과
- [ ] 모니터링 설정
- [ ] 팀에 배포 알림
- [ ] 🎉 프로젝트 완료!

### 선행 작업
- #11 (4.1 백엔드-프론트엔드 통합)
- 프로덕션 빌드
- 배포 스크립트
- 사용자 문서

### 병렬 처리
❌ 순차 진행 필요" \
    "phase-5,deployment,team,priority-critical,sequential" \
    "M5: 프로덕션 배포"

log_success "Phase 5 Issues 생성 완료 (1개)"

###############################################################################
# 완료
###############################################################################

log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "GitHub Issues 생성 완료!"
log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_info "생성된 항목:"
echo "  - 레이블: 20개"
echo "  - Milestones: 5개"
echo "  - Issues: 13개 (주요 작업)"
echo ""
log_info "다음 단계:"
echo "  1. GitHub 저장소 확인: https://github.com/$REPO/issues"
echo "  2. 추가 Issues 생성 (필요시)"
echo "  3. 프로젝트 보드 설정 (선택사항)"
echo "  4. 팀원에게 assign"
echo ""
log_info "전체 Issues를 생성하려면:"
echo "  ./create-github-issues-full.sh $REPO"
echo ""
log_success "Good luck! 🚀"
