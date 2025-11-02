# GitHub Issues 자동 생성 스크립트

WBS (Work Breakdown Structure) 기반으로 DocuNova SaaS 프로젝트의 GitHub Issues를 자동으로 생성하는 스크립트입니다.

## 📋 목차

- [개요](#개요)
- [사전 준비](#사전-준비)
- [스크립트 종류](#스크립트-종류)
- [사용 방법](#사용-방법)
- [생성되는 항목](#생성되는-항목)
- [문제 해결](#문제-해결)

## 개요

이 스크립트는 다음을 자동으로 생성합니다:

- **20개의 레이블**: Phase, 역할, 우선순위, 작업 유형, 병렬 처리 표시
- **5개의 마일스톤**: M1~M5 (환경 설정 → 프로덕션 배포)
- **13개의 주요 Issues**: WBS의 Critical Path 작업들

## 사전 준비

### 1. GitHub CLI 설치

**Windows (PowerShell)**
```powershell
winget install GitHub.cli
```

**macOS**
```bash
brew install gh
```

**Linux**
```bash
# Debian/Ubuntu
sudo apt install gh

# Fedora
sudo dnf install gh
```

### 2. GitHub 인증

```bash
gh auth login
```

인증 과정:
1. GitHub.com 선택
2. HTTPS 선택
3. 브라우저에서 인증 완료

### 3. 인증 확인

```bash
gh auth status
```

출력 예시:
```
✓ Logged in to github.com as username
```

## 스크립트 종류

### 1. Bash 스크립트 (Linux/macOS)

- **파일**: `create-github-issues.sh`
- **권장**: Linux, macOS, WSL 환경

### 2. PowerShell 스크립트 (Windows)

- **파일**: `create-github-issues.ps1`
- **권장**: Windows PowerShell, PowerShell Core

### 3. Python 스크립트 (크로스 플랫폼)

- **파일**: `create-github-issues.py`
- **권장**: 모든 플랫폼 (Python 3.11+ 필요)

## 사용 방법

### Bash (Linux/macOS/WSL)

```bash
# 실행 권한 부여
chmod +x create-github-issues.sh

# 스크립트 실행
./create-github-issues.sh username/docunova-saas
```

### PowerShell (Windows)

```powershell
# 실행 정책 변경 (필요시)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 스크립트 실행
.\create-github-issues.ps1 -Repo "username/docunova-saas"
```

### Python (모든 플랫폼)

```bash
# Python 3.11+ 필요
python create-github-issues.py username/docunova-saas

# 또는
python3 create-github-issues.py username/docunova-saas
```

### 📝 예시

실제 저장소 이름으로 변경해서 실행:

```bash
# Bash
./create-github-issues.sh leejin-kyu/docunova-saas

# PowerShell
.\create-github-issues.ps1 -Repo "leejin-kyu/docunova-saas"

# Python
python create-github-issues.py leejin-kyu/docunova-saas
```

## 생성되는 항목

### 레이블 (20개)

#### Phase 레이블
- `phase-1` - Phase 1: 프로젝트 초기화 (🟢)
- `phase-2` - Phase 2: 백엔드 개발 (🔵)
- `phase-3` - Phase 3: 프론트엔드 개발 (🟣)
- `phase-4` - Phase 4: 통합 및 테스트 (🟡)
- `phase-5` - Phase 5: 배포 및 모니터링 (🔴)

#### 역할 레이블
- `backend` - 백엔드 작업
- `frontend` - 프론트엔드 작업
- `devops` - DevOps/인프라 작업
- `team` - 팀 전체 작업

#### 우선순위 레이블
- `priority-critical` - ⭐ 가장 중요 (🔴)
- `priority-high` - 우선순위: 높음 (🟠)
- `priority-medium` - 우선순위: 중간 (🟡)
- `priority-low` - 우선순위: 낮음 (🟢)

#### 작업 유형 레이블
- `setup` - 환경 설정
- `feature` - 기능 개발
- `test` - 테스트
- `documentation` - 문서화
- `deployment` - 배포

#### 병렬 처리 레이블
- `parallel-ok` - ✅ 병렬 처리 가능
- `sequential` - ⏳ 순차 처리 필요

### 마일스톤 (5개)

| 마일스톤 | 기한 | 설명 |
|---------|------|------|
| M1: 환경 설정 완료 | Day 3 | 프로젝트 초기화 및 개발 환경 설정 완료 |
| M2: 백엔드 API 완료 | Week 2 | 백엔드 핵심 기능 및 API 개발 완료 |
| M3: 프론트엔드 UI 완료 | Week 3 | 프론트엔드 UI 컴포넌트 및 페이지 개발 완료 |
| M4: 통합 테스트 완료 | Week 3.5 | 백엔드-프론트엔드 통합 및 E2E 테스트 완료 |
| M5: 프로덕션 배포 | Week 4 | 프로덕션 환경 배포 및 최종 검증 완료 |

### Issues (13개)

#### Phase 1: 프로젝트 초기화 (5개)
1. `[1.1]` 프로젝트 구조 생성 (2h)
2. `[1.2]` 백엔드 환경 설정 (4h)
3. `[1.3]` 프론트엔드 환경 설정 (4h)
4. `[1.4]` Qdrant 설정 (3h)
5. `[1.5]` 초기 테스트 및 검증 (2h)

#### Phase 2: 백엔드 개발 (3개)
6. `[2.1]` 백엔드 핵심 설정 및 유틸리티 (6h)
7. `[2.2.1]` ⭐ LLM 서비스 구현 (6h) - **CRITICAL**
8. `[2.3.4]` ⭐ 채팅 API 구현 (5h) - **CRITICAL**

#### Phase 3: 프론트엔드 개발 (2개)
9. `[3.1.1]` ⭐ API 클라이언트 구현 (4h) - **CRITICAL**
10. `[3.2.3]` ⭐ 채팅 페이지 구현 (12h) - **CRITICAL**

#### Phase 4: 통합 및 테스트 (1개)
11. `[4.1]` 백엔드-프론트엔드 통합 (12h)

#### Phase 5: 배포 및 모니터링 (1개)
12. `[5.4]` 최종 검증 및 프로덕션 배포 (6h)

## 출력 예시

```
[INFO] 필수 요구사항 확인 중...
[SUCCESS] 필수 요구사항 확인 완료
[INFO] GitHub 레이블 생성 중...
[SUCCESS] 레이블 생성: phase-1
[SUCCESS] 레이블 생성: phase-2
...
[INFO] GitHub 마일스톤 생성 중...
[SUCCESS] 마일스톤 생성: M1: 환경 설정 완료
...
[INFO] Phase 1 Issues 생성 중...
[SUCCESS] Issue 생성: [1.1] 프로젝트 구조 생성
...
[SUCCESS] ✅ GitHub Issues 생성 완료!
[INFO] 총 13개의 주요 Issue가 생성되었습니다.
```

## 다음 단계

스크립트 실행 후:

### 1. GitHub 저장소 확인

```
https://github.com/username/docunova-saas/issues
```

### 2. Projects 보드 생성 (권장)

GitHub UI에서:
1. **Projects** 탭 클릭
2. **New project** 클릭
3. **Board** 템플릿 선택
4. 칸반 보드로 Issues 관리

칸반 컬럼 예시:
- 📋 To Do
- 🔄 In Progress
- 👀 Review
- ✅ Done

### 3. 팀원 할당

각 Issue를 열고:
- **Assignees**에 담당자 추가
- 필요시 **Labels** 추가 조정
- 코멘트로 추가 정보 제공

### 4. 마일스톤 추적

```
https://github.com/username/docunova-saas/milestones
```

각 마일스톤의 진행 상황을 시각적으로 확인할 수 있습니다.

## 문제 해결

### 에러: "gh: command not found"

**원인**: GitHub CLI가 설치되지 않음

**해결**:
```bash
# macOS
brew install gh

# Windows
winget install GitHub.cli

# Linux
sudo apt install gh
```

### 에러: "You are not logged into any GitHub hosts"

**원인**: GitHub 인증이 안 됨

**해결**:
```bash
gh auth login
```

### 에러: "already_exists" 또는 "already exists"

**원인**: 레이블/마일스톤/Issue가 이미 존재

**해결**: 이는 정상입니다. 스크립트는 계속 진행됩니다.

기존 항목을 삭제하고 다시 실행하려면:
```bash
# 모든 레이블 삭제 (주의!)
gh api repos/username/repo/labels --jq '.[].name' | xargs -I {} gh label delete {} --repo username/repo --yes

# 모든 마일스톤 삭제 (주의!)
gh api repos/username/repo/milestones --jq '.[].number' | xargs -I {} gh api repos/username/repo/milestones/{} -X DELETE
```

### PowerShell 실행 정책 에러

**에러**:
```
.\create-github-issues.ps1 : File cannot be loaded because running scripts is disabled
```

**해결**:
```powershell
# 현재 세션에만 적용
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 또는 현재 사용자에게 적용
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### Python 버전 에러

**에러**:
```
SyntaxError: invalid syntax
```

**원인**: Python 3.11 미만 버전

**해결**:
```bash
# Python 버전 확인
python --version

# Python 3.11+ 설치
# macOS
brew install python@3.11

# Windows
# https://www.python.org/downloads/ 에서 다운로드

# Linux
sudo apt install python3.11
```

### 권한 에러 (Bash)

**에러**:
```
Permission denied: ./create-github-issues.sh
```

**해결**:
```bash
chmod +x create-github-issues.sh
```

## 고급 사용법

### 특정 Phase만 생성

스크립트를 수정하여 특정 Phase의 Issues만 생성:

```python
# Python 스크립트에서
def main():
    # ...
    create_labels(repo)
    create_milestones(repo)

    # Phase 1만 생성
    create_phase1_issues(repo)
    # create_phase2_issues(repo)  # 주석 처리
    # create_phase3_issues(repo)  # 주석 처리
```

### 커스텀 마일스톤 날짜

스크립트에서 날짜 계산 부분 수정:

```python
# Python 예시
today = datetime.now()
milestones = [
    ("M1: 환경 설정 완료", today + timedelta(days=7), "..."),  # 3일 → 7일
    # ...
]
```

### 레이블 색상 커스터마이징

스크립트에서 색상 코드 변경:

```python
labels = [
    ("phase-1", "Phase 1: 프로젝트 초기화", "0E8A16"),  # 기본 녹색
    # "0E8A16" → "00FF00" 등으로 변경
]
```

## 참고 문서

- [07_WBS_PROJECT_PLAN.md](../07_WBS_PROJECT_PLAN.md) - 전체 WBS 상세 내용
- [GitHub CLI 문서](https://cli.github.com/manual/)
- [GitHub Issues 가이드](https://docs.github.com/en/issues)
- [GitHub Projects 가이드](https://docs.github.com/en/issues/planning-and-tracking-with-projects)

## 라이선스

이 스크립트는 DocuNova SaaS 프로젝트의 일부입니다.

## 작성자

DocuNova Development Team

## 버전

- **v1.0.0** (2025-10-30) - 초기 버전
  - Bash, PowerShell, Python 스크립트 제공
  - 13개 주요 Issues 자동 생성
  - 20개 레이블, 5개 마일스톤 생성
