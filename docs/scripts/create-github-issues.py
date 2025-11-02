#!/usr/bin/env python3
"""
GitHub Issues 자동 생성 스크립트 (Python)
DocuNova SaaS 프로젝트 WBS 기반
사용법: python create-github-issues.py username/docunova-saas
"""

import sys
import subprocess
import json
from datetime import datetime, timedelta
from typing import Optional


class Colors:
    """ANSI 색상 코드"""
    INFO = '\033[96m'
    SUCCESS = '\033[92m'
    WARNING = '\033[93m'
    ERROR = '\033[91m'
    RESET = '\033[0m'


def log_info(msg: str) -> None:
    print(f"{Colors.INFO}[INFO]{Colors.RESET} {msg}")


def log_success(msg: str) -> None:
    print(f"{Colors.SUCCESS}[SUCCESS]{Colors.RESET} {msg}")


def log_warning(msg: str) -> None:
    print(f"{Colors.WARNING}[WARNING]{Colors.RESET} {msg}")


def log_error(msg: str) -> None:
    print(f"{Colors.ERROR}[ERROR]{Colors.RESET} {msg}")


def run_command(cmd: list[str]) -> tuple[bool, str]:
    """외부 명령어 실행"""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=False
        )
        return result.returncode == 0, result.stdout + result.stderr
    except Exception as e:
        return False, str(e)


def check_prerequisites() -> bool:
    """필수 요구사항 체크"""
    log_info("필수 요구사항 확인 중...")

    # gh CLI 설치 확인
    success, _ = run_command(["gh", "--version"])
    if not success:
        log_error("gh CLI가 설치되어 있지 않습니다.")
        log_info("설치: https://cli.github.com/")
        return False

    # gh 인증 확인
    success, _ = run_command(["gh", "auth", "status"])
    if not success:
        log_error("GitHub 인증이 필요합니다.")
        log_info("실행: gh auth login")
        return False

    log_success("필수 요구사항 확인 완료")
    return True


def create_labels(repo: str) -> None:
    """GitHub 레이블 생성"""
    log_info("GitHub 레이블 생성 중...")

    labels = [
        # Phase 레이블
        ("phase-1", "Phase 1: 프로젝트 초기화", "0E8A16"),
        ("phase-2", "Phase 2: 백엔드 개발", "1D76DB"),
        ("phase-3", "Phase 3: 프론트엔드 개발", "5319E7"),
        ("phase-4", "Phase 4: 통합 및 테스트", "FBCA04"),
        ("phase-5", "Phase 5: 배포 및 모니터링", "D93F0B"),

        # 역할 레이블
        ("backend", "백엔드 작업", "0052CC"),
        ("frontend", "프론트엔드 작업", "1D76DB"),
        ("devops", "DevOps/인프라 작업", "C5DEF5"),
        ("team", "팀 전체 작업", "FEF2C0"),

        # 우선순위 레이블
        ("priority-critical", "⭐ 가장 중요", "B60205"),
        ("priority-high", "우선순위: 높음", "D93F0B"),
        ("priority-medium", "우선순위: 중간", "FBCA04"),
        ("priority-low", "우선순위: 낮음", "0E8A16"),

        # 작업 유형 레이블
        ("setup", "환경 설정", "C5DEF5"),
        ("feature", "기능 개발", "A2EEEF"),
        ("test", "테스트", "D4C5F9"),
        ("documentation", "문서화", "FEF2C0"),
        ("deployment", "배포", "D93F0B"),

        # 병렬 처리 레이블
        ("parallel-ok", "✅ 병렬 처리 가능", "0E8A16"),
        ("sequential", "⏳ 순차 처리 필요", "D93F0B"),
    ]

    for name, description, color in labels:
        success, output = run_command([
            "gh", "label", "create", name,
            "--description", description,
            "--color", color,
            "--repo", repo
        ])
        if success or "already exists" in output.lower():
            log_success(f"레이블 생성: {name}")
        else:
            log_warning(f"레이블 생성 실패: {name}")


def create_milestones(repo: str) -> None:
    """GitHub 마일스톤 생성"""
    log_info("GitHub 마일스톤 생성 중...")

    today = datetime.now()
    milestones = [
        ("M1: 환경 설정 완료", today + timedelta(days=3), "프로젝트 초기화 및 개발 환경 설정 완료"),
        ("M2: 백엔드 API 완료", today + timedelta(days=14), "백엔드 핵심 기능 및 API 개발 완료"),
        ("M3: 프론트엔드 UI 완료", today + timedelta(days=21), "프론트엔드 UI 컴포넌트 및 페이지 개발 완료"),
        ("M4: 통합 테스트 완료", today + timedelta(days=25), "백엔드-프론트엔드 통합 및 E2E 테스트 완료"),
        ("M5: 프로덕션 배포", today + timedelta(days=28), "프로덕션 환경 배포 및 최종 검증 완료"),
    ]

    for title, due_date, description in milestones:
        due_str = due_date.strftime("%Y-%m-%dT23:59:59Z")
        data = {
            "title": title,
            "due_on": due_str,
            "description": description
        }

        success, output = run_command([
            "gh", "api", f"repos/{repo}/milestones",
            "-X", "POST",
            "-f", f"title={title}",
            "-f", f"due_on={due_str}",
            "-f", f"description={description}"
        ])

        if success or "already_exists" in output.lower():
            log_success(f"마일스톤 생성: {title}")
        else:
            log_warning(f"마일스톤 생성 실패: {title}")


def create_issue(
    repo: str,
    title: str,
    body: str,
    labels: str,
    milestone: str
) -> None:
    """GitHub Issue 생성"""
    success, output = run_command([
        "gh", "issue", "create",
        "--repo", repo,
        "--title", title,
        "--body", body,
        "--label", labels,
        "--milestone", milestone
    ])

    if success:
        log_success(f"Issue 생성: {title}")
    else:
        log_error(f"Issue 생성 실패: {title}")


def create_phase1_issues(repo: str) -> None:
    """Phase 1 Issues 생성"""
    log_info("Phase 1 Issues 생성 중...")

    # [1.1] 프로젝트 구조 생성
    create_issue(
        repo=repo,
        title="[1.1] 프로젝트 구조 생성",
        body="""## WBS 코드: 1.1
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
이 작업 완료 후 [1.2], [1.3] 병렬 진행 가능""",
        labels="phase-1,setup,devops,priority-high,parallel-ok",
        milestone="M1: 환경 설정 완료"
    )

    # [1.2] 백엔드 환경 설정
    create_issue(
        repo=repo,
        title="[1.2] 백엔드 환경 설정",
        body="""## WBS 코드: 1.2
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
```toml
# pyproject.toml
[tool.black]
line-length = 88
target-version = ['py311']

[tool.isort]
profile = "black"

[tool.mypy]
python_version = "3.11"
disallow_untyped_defs = true
```

### 참고 문서
- [06_DEVELOPMENT_ENVIRONMENT_SETUP.md](../06_DEVELOPMENT_ENVIRONMENT_SETUP.md)
- [04_TECHNOLOGY_STACK_REVIEW.md](../04_TECHNOLOGY_STACK_REVIEW.md)""",
        labels="phase-1,setup,backend,priority-high,parallel-ok",
        milestone="M1: 환경 설정 완료"
    )

    # [1.3] 프론트엔드 환경 설정
    create_issue(
        repo=repo,
        title="[1.3] 프론트엔드 환경 설정",
        body="""## WBS 코드: 1.3
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
```json
// tsconfig.json - 중요!
{
  "compilerOptions": {
    "jsx": "preserve",  // ⚠️ Next.js 16 필수
    "strict": true,
    "noUnusedLocals": true,
    "noUncheckedIndexedAccess": true
  }
}
```

### 참고 문서
- [06_DEVELOPMENT_ENVIRONMENT_SETUP.md](../06_DEVELOPMENT_ENVIRONMENT_SETUP.md)
- [04_TECHNOLOGY_STACK_REVIEW.md](../04_TECHNOLOGY_STACK_REVIEW.md)

### ⚠️ 주의사항
React 19 + Next.js 16 호환성 확인 필수!""",
        labels="phase-1,setup,frontend,priority-high,parallel-ok",
        milestone="M1: 환경 설정 완료"
    )

    # [1.4] Qdrant 설정
    create_issue(
        repo=repo,
        title="[1.4] Qdrant 설정",
        body="""## WBS 코드: 1.4
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
```bash
# Qdrant Docker 실행
docker run -p 6333:6333 -p 6334:6334 \\
    -v qdrant_storage:/qdrant/storage \\
    qdrant/qdrant
```

```python
# 연결 테스트
from qdrant_client import QdrantClient

client = QdrantClient(url="http://localhost:6333")
print(client.get_collections())
```

### 참고 문서
- [01_SYSTEM_OVERVIEW.md](../01_SYSTEM_OVERVIEW.md)""",
        labels="phase-1,setup,backend,priority-high,sequential",
        milestone="M1: 환경 설정 완료"
    )

    # [1.5] 초기 테스트 및 검증
    create_issue(
        repo=repo,
        title="[1.5] 초기 테스트 및 검증",
        body="""## WBS 코드: 1.5
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
```bash
# 백엔드
cd backend && pytest tests/

# 프론트엔드
cd frontend && npm run type-check && npm run lint
```

### 참고 문서
- [06_DEVELOPMENT_ENVIRONMENT_SETUP.md](../06_DEVELOPMENT_ENVIRONMENT_SETUP.md)

### 다음 단계
✅ Phase 1 완료 → Phase 2 백엔드 개발 시작""",
        labels="phase-1,test,team,priority-high,sequential",
        milestone="M1: 환경 설정 완료"
    )


def create_phase2_issues(repo: str) -> None:
    """Phase 2 Issues 생성 (Critical Path)"""
    log_info("Phase 2 Issues 생성 중...")

    # [2.1] 백엔드 핵심 설정
    create_issue(
        repo=repo,
        title="[2.1] 백엔드 핵심 설정 및 유틸리티",
        body="""## WBS 코드: 2.1
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
```python
# app/core/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    QDRANT_URL: str = "http://localhost:6333"
    OLLAMA_URL: str = "http://localhost:11434"
    CORS_ORIGINS: list[str] = ["http://localhost:3000"]

    class Config:
        env_file = ".env"

settings = Settings()
```

### 참고 문서
- [01_SYSTEM_OVERVIEW.md](../01_SYSTEM_OVERVIEW.md)
- [05_DIRECTORY_STRUCTURE.md](../05_DIRECTORY_STRUCTURE.md)""",
        labels="phase-2,backend,feature,priority-high,parallel-ok",
        milestone="M2: 백엔드 API 완료"
    )

    # [2.2.1] LLM 서비스 (CRITICAL)
    create_issue(
        repo=repo,
        title="[2.2.1] ⭐ LLM 서비스 구현 (CRITICAL)",
        body="""## WBS 코드: 2.2.1
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
```python
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
        \"\"\"Ollama LLM 통신 with 타임아웃 및 재시도\"\"\"
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
                await asyncio.sleep(1 * (attempt + 1))
            except httpx.HTTPError as e:
                raise HTTPException(
                    status_code=500,
                    detail=f"LLM 서버 오류: {str(e)}"
                )
```

### 참고 문서
- [01_SYSTEM_OVERVIEW.md](../01_SYSTEM_OVERVIEW.md) - LLM 재시도 로직
- [04_TECHNOLOGY_STACK_REVIEW.md](../04_TECHNOLOGY_STACK_REVIEW.md)

### ⚠️ 주의사항
이 서비스는 시스템의 핵심입니다. 반드시 에러 핸들링을 철저히 테스트하세요!""",
        labels="phase-2,backend,feature,priority-critical,sequential",
        milestone="M2: 백엔드 API 완료"
    )

    # [2.3.4] 채팅 API (CRITICAL)
    create_issue(
        repo=repo,
        title="[2.3.4] ⭐ 채팅 API 구현 (CRITICAL)",
        body="""## WBS 코드: 2.3.4
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

### 참고 문서
- [02_ARCHITECTURE_DIAGRAMS.md](../02_ARCHITECTURE_DIAGRAMS.md) - Chat Flow
- [03_IMPLEMENTATION_GUIDE.md](../03_IMPLEMENTATION_GUIDE.md) - Step 1.3""",
        labels="phase-2,backend,feature,priority-critical,sequential",
        milestone="M2: 백엔드 API 완료"
    )


def create_phase3_issues(repo: str) -> None:
    """Phase 3 Issues 생성 (Critical Path)"""
    log_info("Phase 3 Issues 생성 중...")

    # [3.1.1] API 클라이언트 (CRITICAL)
    create_issue(
        repo=repo,
        title="[3.1.1] ⭐ API 클라이언트 구현 (CRITICAL)",
        body="""## WBS 코드: 3.1.1
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

### 참고 문서
- [01_SYSTEM_OVERVIEW.md](../01_SYSTEM_OVERVIEW.md) - API Client Layer
- [05_DIRECTORY_STRUCTURE.md](../05_DIRECTORY_STRUCTURE.md)

### ⚠️ 주의사항
에러 핸들링은 사용자에게 명확한 메시지를 제공해야 합니다!""",
        labels="phase-3,frontend,feature,priority-critical,parallel-ok",
        milestone="M3: 프론트엔드 UI 완료"
    )

    # [3.2.3] 채팅 페이지 (CRITICAL)
    create_issue(
        repo=repo,
        title="[3.2.3] ⭐ 채팅 페이지 구현 (CRITICAL)",
        body="""## WBS 코드: 3.2.3
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

### 참고 문서
- [DocuNova_NextJS_UI_Reference](../../DocuNova_NextJS_UI_Reference/) - UI 디자인 참고
- [02_ARCHITECTURE_DIAGRAMS.md](../02_ARCHITECTURE_DIAGRAMS.md) - Chat Flow

### ⚠️ 주의사항
- React 19 async/await 패턴 준수
- 에러 바운더리 필수 적용
- 로딩 상태 명확히 표시""",
        labels="phase-3,frontend,feature,priority-critical,sequential",
        milestone="M3: 프론트엔드 UI 완료"
    )


def create_phase4_issues(repo: str) -> None:
    """Phase 4 Issue 생성"""
    log_info("Phase 4 Issue 생성 중...")

    create_issue(
        repo=repo,
        title="[4.1] 백엔드-프론트엔드 통합",
        body="""## WBS 코드: 4.1
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

### 참고 문서
- [02_ARCHITECTURE_DIAGRAMS.md](../02_ARCHITECTURE_DIAGRAMS.md)
- [03_IMPLEMENTATION_GUIDE.md](../03_IMPLEMENTATION_GUIDE.md)""",
        labels="phase-4,test,team,priority-high,sequential",
        milestone="M4: 통합 테스트 완료"
    )


def create_phase5_issues(repo: str) -> None:
    """Phase 5 Issue 생성"""
    log_info("Phase 5 Issue 생성 중...")

    create_issue(
        repo=repo,
        title="[5.4] 최종 검증 및 프로덕션 배포",
        body="""## WBS 코드: 5.4
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

### 참고 문서
- [07_WBS_PROJECT_PLAN.md](../07_WBS_PROJECT_PLAN.md)
- [03_IMPLEMENTATION_GUIDE.md](../03_IMPLEMENTATION_GUIDE.md)

### 🎉 프로젝트 완료!
모든 마일스톤 달성 축하합니다!""",
        labels="phase-5,deployment,devops,team,priority-high,sequential",
        milestone="M5: 프로덕션 배포"
    )


def main() -> None:
    """메인 함수"""
    if len(sys.argv) < 2:
        log_error("사용법: python create-github-issues.py <owner/repo>")
        log_info("예시: python create-github-issues.py username/docunova-saas")
        sys.exit(1)

    repo = sys.argv[1]

    if "/" not in repo:
        log_error("저장소 형식이 올바르지 않습니다.")
        log_info("올바른 형식: owner/repository")
        sys.exit(1)

    if not check_prerequisites():
        sys.exit(1)

    # 레이블 및 마일스톤 생성
    create_labels(repo)
    create_milestones(repo)

    # Issues 생성
    create_phase1_issues(repo)
    create_phase2_issues(repo)
    create_phase3_issues(repo)
    create_phase4_issues(repo)
    create_phase5_issues(repo)

    # 완료 메시지
    log_success("\n✅ GitHub Issues 생성 완료!")
    log_info("총 13개의 주요 Issue가 생성되었습니다.")
    log_info("")
    log_info("다음 단계:")
    log_info("1. GitHub 저장소에서 Issues 탭 확인")
    log_info("2. Projects 보드 생성하여 칸반 뷰로 관리")
    log_info("3. 팀원에게 작업 할당")
    log_info("4. 마일스톤별로 진행 상황 추적")


if __name__ == "__main__":
    main()
