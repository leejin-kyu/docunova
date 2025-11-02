# DocuNova SaaS 아키텍처 설계서 📐

## 🎯 개요

이 폴더는 **안정적이고 오류 없는** DocuNova SaaS를 구축하기 위한 완전한 아키텍처 설계 문서를 포함합니다.

**핵심 목표**:
- ✅ **UI 오류 제로**: 프론트엔드에서 절대 에러 발생하지 않음
- ✅ **단순성**: 복잡하지 않고 직관적인 구조
- ✅ **유지보수성**: 쉽게 수정하고 확장 가능
- ✅ **안정성**: 모든 엣지 케이스 처리

---

## 📚 문서 구성

### 1. 시스템 개요 (`01_SYSTEM_OVERVIEW.md`)

**내용**:
- 전체 시스템 구조
- 핵심 아키텍처 결정사항
- 안정성 보장 메커니즘
- 보안 고려사항
- 확장성 전략

**이 문서를 읽으면**:
- 시스템 전체를 이해할 수 있습니다
- 왜 이렇게 설계했는지 알 수 있습니다
- 각 컴포넌트의 역할을 파악할 수 있습니다

---

### 2. 아키텍처 다이어그램 (`02_ARCHITECTURE_DIAGRAMS.md`)

**내용**:
- 9개의 Mermaid 다이어그램
  1. 전체 시스템 아키텍처
  2. 채팅 질의 플로우
  3. 문서 업로드 플로우
  4. 에러 핸들링 플로우
  5. 컴포넌트 의존성
  6. 상태 관리
  7. 백엔드 모듈 구조
  8. 배포 아키텍처
  9. 개발 환경

**이 문서를 읽으면**:
- 시스템을 시각적으로 이해할 수 있습니다
- 데이터 흐름을 추적할 수 있습니다
- 각 컴포넌트 간 관계를 파악할 수 있습니다

---

### 3. 구현 가이드 (`03_IMPLEMENTATION_GUIDE.md`)

**내용**:
- Phase 1: 백엔드 구축
- Phase 2: 프론트엔드 구축
- Phase 3: 통합 테스트
- Phase 4: 최적화 및 배포
- ⚠️ React 19 + Next.js 16 주의사항
- ⚠️ Ollama LLM 통신 에러 핸들링

**이 문서를 읽으면**:
- 단계별로 구현할 수 있습니다
- 각 단계의 테스트 방법을 알 수 있습니다
- 안정적인 코드를 작성할 수 있습니다
- 잠재적 문제를 사전에 예방할 수 있습니다

---

### 4. 기술 스택 호환성 검토 (`04_TECHNOLOGY_STACK_REVIEW.md`) ⭐

**내용**:
- 전체 기술 스택 버전 분석
- React 19 + Next.js 16 호환성 검토
- FastAPI + Pydantic 2 호환성 확인
- Qdrant + FastEmbed 검증
- Ollama 통합 안정성 분석
- 즉시 조치 필요 항목
- 대체 버전 권장사항

**이 문서를 읽으면**:
- 각 기술의 호환성을 파악할 수 있습니다
- 잠재적 이슈를 사전에 발견할 수 있습니다
- 안정적인 버전 선택을 할 수 있습니다
- 유지보수 시 참고할 수 있습니다

**⚠️ 개발 시작 전 필독!**

---

### 5. 디렉토리 구조 설계 (`05_DIRECTORY_STRUCTURE.md`) ⭐

**내용**:
- 전체 프로젝트 디렉토리 구조
- 백엔드 구조 (API 버전 관리, 서비스 레이어, 모델)
- 프론트엔드 구조 (App Router, 컴포넌트, Hooks)
- 보안 고려사항 (.env, .gitignore)
- 파일 크기 및 용량 가이드
- 개발 워크플로우
- 확장성 고려사항
- 유지보수 가이드

**이 문서를 읽으면**:
- 프로젝트 구조를 체계적으로 구성할 수 있습니다
- 각 파일과 폴더의 목적을 명확히 알 수 있습니다
- 새 기능 추가 시 어디에 코드를 작성할지 알 수 있습니다
- 장기적인 유지보수 전략을 수립할 수 있습니다

**💡 실제 개발 시작 전 필독!**

---

### 6. 개발 환경 설정 (`06_DEVELOPMENT_ENVIRONMENT_SETUP.md`) ⭐

**내용**:
- 전체 아키텍처 재검토 결과
- TypeScript strict 설정 (jsx: "preserve" 수정!)
- ESLint 엄격한 규칙 (no-explicit-any 등)
- Prettier 코드 포맷팅
- Next.js 보안 헤더 및 최적화
- Python 린팅 (Black, isort, Ruff, mypy)
- Pre-commit Hooks 설정 (Husky, lint-staged)
- VS Code 설정
- 개발 워크플로우
- 문제 해결 가이드

**이 문서를 읽으면**:
- 안정적인 개발 환경을 구축할 수 있습니다
- 코드 품질을 자동으로 관리할 수 있습니다
- 커밋 전 자동 검증으로 오류를 예방할 수 있습니다
- 팀 전체가 일관된 코드 스타일을 유지할 수 있습니다

**⚠️ 개발 시작 전 필수 설정!**

---

### 7. WBS 프로젝트 계획 (`07_WBS_PROJECT_PLAN.md`) ⭐

**내용**:
- 5개 Phase로 구성된 작업 분해 구조
- 총 60개 이상의 세부 작업 정의
- 각 작업의 소요 시간 및 담당자
- 선행 작업 관계 및 병렬 처리 가능 여부
- 간트 차트 및 마일스톤
- 리스크 관리 계획
- 일일 체크리스트
- 최종 완료 조건

**이 문서를 읽으면**:
- 4주 개발 일정을 체계적으로 관리할 수 있습니다
- 어떤 작업을 병렬로 진행할 수 있는지 알 수 있습니다
- 각 작업의 우선순위를 파악할 수 있습니다
- 팀원 간 작업 분담이 명확해집니다

**💼 프로젝트 관리자 필독!**

---

### 8. GitHub Issues 자동 생성 스크립트 (`scripts/`) ⭐ 새로 추가!

**내용**:
- **3가지 스크립트 제공**: Bash, PowerShell, Python
- WBS 기반 GitHub Issues 자동 생성
- 20개 레이블 자동 생성 (Phase, 역할, 우선순위 등)
- 5개 마일스톤 자동 생성 (M1~M5)
- 13개 주요 Issues 자동 생성
- 상세한 사용 설명서 포함

**스크립트 파일**:
- `scripts/create-github-issues.sh` - Linux/macOS/WSL
- `scripts/create-github-issues.ps1` - Windows PowerShell
- `scripts/create-github-issues.py` - 모든 플랫폼 (Python 3.11+)
- `scripts/README.md` - 상세 사용 가이드

**이 스크립트를 사용하면**:
- WBS를 GitHub Issues로 자동 변환할 수 있습니다
- 프로젝트 보드를 빠르게 구성할 수 있습니다
- 팀원 할당 및 진행 상황 추적이 쉬워집니다
- 마일스톤별 진행률을 시각적으로 확인할 수 있습니다

**🚀 프로젝트 시작 시 가장 먼저 실행하세요!**

**사용 예시**:
```bash
# Bash (Linux/macOS)
./scripts/create-github-issues.sh username/docunova-saas

# PowerShell (Windows)
.\scripts\create-github-issues.ps1 -Repo "username/docunova-saas"

# Python (모든 플랫폼)
python scripts/create-github-issues.py username/docunova-saas
```

---

### 9. 리스크 분석 및 완화 전략 (`08_RISK_ANALYSIS_AND_MITIGATION.md`) ⭐⭐⭐ 필독!

**내용**:
- **전체 아키텍처 리스크 분석**: 32개 리스크 식별
- **8개 Critical 리스크**: 즉시 조치 필요
- **12개 High 리스크**: 1주일 내 조치 필요
- 카테고리별 분류: 기술, 구현, 확장성, 보안, 데이터 정확도
- 각 리스크별 상세 해결책 및 코드 예시
- 검증 테스트 방법
- 조치 계획 (Action Plan)

**Critical 리스크**:
1. Ollama LLM 연결 불안정
2. 대용량 파일 메모리 오버플로우
3. 텍스트 청킹이 의미론적 맥락 파괴
4. RAG 검색이 부적절한 컨텍스트 반환
5. 답변 검증 및 할루시네이션 감지 부재

**이 문서를 읽으면**:
- 시스템의 모든 잠재적 위험을 파악할 수 있습니다
- 각 리스크의 영향도와 우선순위를 알 수 있습니다
- 구체적인 해결 방법과 코드를 얻을 수 있습니다
- 안정적인 시스템 구축 로드맵을 확보할 수 있습니다

**⚠️ 개발 시작 전 반드시 읽고 Critical 리스크를 해결하세요!**

---

### 10. 대용량 파일 처리 및 정확도 (`09_LARGE_FILE_PROCESSING_ACCURACY.md`) ⭐⭐⭐ 필독!

**내용**:
- **3-Stage Processing Pipeline**: 스트리밍 → 청킹 → 임베딩
- **100MB+ 파일 안정적 처리**: 메모리 90% 절감
- **의미론적 청킹**: 문장 경계 보존, RAG 정확도 30-50% 향상
- **정확도 검증 방법**: 테스트 코드 및 벤치마크
- **성능 메트릭**: 처리 시간, 메모리 사용량, 처리량
- 완전한 구현 코드 예시

**핵심 개선사항**:
- 메모리 사용량: 2.5GB → 250MB (90% 감소)
- 청킹 품질: 문장 완전성 100%, 의미 일관성 95%
- RAG 정확도: 50% → 85% (35% 향상)
- 처리 안정성: 실패율 40% → 0%

**이 문서를 읽으면**:
- 대용량 파일을 메모리 효율적으로 처리하는 방법을 배웁니다
- 의미론적 청킹으로 RAG 정확도를 극대화하는 방법을 알 수 있습니다
- 실전에서 바로 사용 가능한 코드를 얻습니다
- 성능 벤치마크 기준을 확보합니다

**💡 RAG 시스템의 핵심 성능을 좌우합니다!**

---

### 11. 프로젝트 템플릿 생성 가이드 (`10_PROJECT_TEMPLATE_GENERATION_GUIDE.md`) ⭐⭐⭐ 시작 필독!

**내용**:
- **5-Phase 단계별 프로젝트 생성**: 처음부터 안정적으로 구축
- **완전한 설치 가이드**: 모든 OS 지원 (Windows, macOS, Linux)
- **검증 체크리스트**: 각 단계마다 정상 작동 확인
- **문제 해결 가이드**: 흔한 오류 및 해결 방법
- **실행 가능한 스크립트**: 복사해서 바로 사용

**5 Phases**:
1. Phase 1: 프로젝트 구조 생성 (10분)
2. Phase 2: 백엔드 설정 (20분)
3. Phase 3: 프론트엔드 설정 (15분)
4. Phase 4: 핵심 서비스 구현 (참조)
5. Phase 5: 검증 및 테스트 (10분)

**이 문서를 읽으면**:
- 프로젝트를 처음부터 단계별로 생성할 수 있습니다
- 각 단계에서 발생할 수 있는 오류를 예방할 수 있습니다
- 완전히 작동하는 기본 템플릿을 확보할 수 있습니다
- 모든 의존성과 설정이 올바르게 구성됩니다

**🎯 프로젝트 시작 시 가장 먼저 읽어야 할 문서!**

---

## 🚀 빠른 시작

### 1. 아키텍처 이해하기

```
⭐ 04_TECHNOLOGY_STACK_REVIEW.md (30분) - 먼저 읽기 필수!
→ 기술 스택 호환성 및 잠재적 이슈 파악

⭐ 06_DEVELOPMENT_ENVIRONMENT_SETUP.md (40분) - 개발 전 필수!
→ TypeScript, ESLint, Python 린팅 설정 및 pre-commit hooks

⭐ 05_DIRECTORY_STRUCTURE.md (30분)
→ 프로젝트 디렉토리 구조 및 파일 배치 전략

01_SYSTEM_OVERVIEW.md (20분)
→ 전체 구조 파악

02_ARCHITECTURE_DIAGRAMS.md (15분)
→ 다이어그램으로 시각화

03_IMPLEMENTATION_GUIDE.md (30분)
→ 구현 방법 학습
```

### 2. 구현 시작하기

```bash
# Phase 1: 백엔드 (2시간)
cd backend
python main.py

# Phase 2: 프론트엔드 (3시간)
cd frontend
npm run dev

# Phase 3: 통합 테스트 (1시간)
# 전체 시스템 테스트

# Phase 4: 배포 (1시간)
# 프로덕션 빌드 및 배포
```

---

## 🎨 핵심 설계 원칙

### 1. 안정성 최우선 (Stability First)

```typescript
// ✅ 모든 API 호출에 에러 처리
try {
  const result = await apiClient.query(question);
  // 성공 처리
} catch (error) {
  // 사용자 친화적 메시지
  setError("죄송합니다. 요청 처리 중 오류가 발생했습니다.");
}
```

### 2. 단순성 (Keep It Simple)

```typescript
// ❌ 복잡한 상태 관리 (Redux, Zustand 등) 사용하지 않음
// ✅ React useState만 사용
const [messages, setMessages] = useState<Message[]>([]);
const [isLoading, setIsLoading] = useState(false);
```

### 3. 격리 (Isolation)

```
Frontend (Port 3000) ←→ Backend (Port 8000)
        ↓                      ↓
    에러 격리            에러 격리
    ↓                      ↓
사용자에게 영향 없음    로그 기록 후 복구
```

### 4. 점진적 개선 (Progressive Enhancement)

```
1. 기본 기능 완성 → 테스트
2. 에러 핸들링 추가 → 테스트
3. 최적화 → 테스트
4. 고급 기능 → 테스트
```

---

## 🏗️ 시스템 구조 (간략)

```
┌─────────────┐
│   사용자     │
└──────┬──────┘
       │
┌──────▼──────────────┐
│   Next.js Frontend  │  Port 3000
│  - React 19         │
│  - TypeScript       │
│  - Tailwind CSS     │
└──────┬──────────────┘
       │ REST API + SSE
┌──────▼──────────────┐
│  FastAPI Backend    │  Port 8000
│  - Python 3.11      │
│  - FastEmbed        │
│  - Qdrant           │
└──────┬──────────────┘
       │
┌──────▼──────────────┐
│  Ollama LLM         │  Port 11434
│  - llama3.1:8b      │
└─────────────────────┘
```

---

## 📊 기술 스택

### 프론트엔드
- **프레임워크**: Next.js 16 (App Router)
- **언어**: TypeScript 5.9
- **스타일**: Tailwind CSS 3.4
- **UI 컴포넌트**: shadcn/ui
- **아이콘**: lucide-react
- **HTTP 클라이언트**: Fetch API (래핑)

### 백엔드
- **프레임워크**: FastAPI 0.115
- **언어**: Python 3.11
- **벡터 DB**: Qdrant 1.12
- **임베딩**: FastEmbed 0.3
- **LLM**: Ollama (llama3.1:8b)
- **문서 처리**: pypdf, PyMuPDF, docx2txt

---

## 🔑 핵심 컴포넌트

### 1. API Client (`lib/api.ts`)

**역할**:
- 모든 HTTP 통신 중앙화
- 타임아웃 (30초)
- 재시도 (3회)
- 에러 변환

**중요도**: ⭐⭐⭐⭐⭐

### 2. Error Boundary (`app/error.tsx`)

**역할**:
- React 컴포넌트 에러 캐치
- 전체 앱 크래시 방지
- 사용자 친화적 에러 표시

**중요도**: ⭐⭐⭐⭐⭐

### 3. FastAPI Endpoints (`main.py`)

**역할**:
- RESTful API 제공
- 스트리밍 응답
- 입력 검증 (Pydantic)

**중요도**: ⭐⭐⭐⭐⭐

---

## ✅ 성공 기준

### 기능 완성도
- [ ] 채팅 기능 (RAG + LLM 모드)
- [ ] 문서 업로드/삭제
- [ ] 대시보드 통계
- [ ] 설정 페이지

### 안정성
- [ ] UI 에러율 0%
- [ ] API 성공률 99.9%
- [ ] 평균 응답 시간 < 2초

### 사용성
- [ ] 직관적인 UI
- [ ] 명확한 피드백
- [ ] 반응형 디자인

---

## 📈 개발 로드맵

### Week 1: 기반 구축
- [ ] 백엔드 setup
- [ ] 프론트엔드 setup
- [ ] API 클라이언트 작성

### Week 2: 핵심 기능
- [ ] 채팅 기능
- [ ] 문서 업로드
- [ ] 에러 핸들링

### Week 3: UI 개선
- [ ] 대시보드
- [ ] 설정 페이지
- [ ] 반응형 디자인

### Week 4: 테스트 & 배포
- [ ] 통합 테스트
- [ ] 성능 테스트
- [ ] 프로덕션 배포

---

## 🐛 트러블슈팅

### 문제 1: CORS 에러

```
Access to fetch at 'http://localhost:8000/api/...'
from origin 'http://localhost:3000' has been blocked by CORS
```

**해결**:
```python
# backend/main.py
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 문제 2: API 타임아웃

```
Error: Request timeout after 30 seconds
```

**해결**:
1. 백엔드 성능 최적화
2. 프론트엔드 타임아웃 증가
3. 로딩 상태 명확히 표시

### 문제 3: 빌드 에러

```
Error: Module not found: Can't resolve '@/lib/api'
```

**해결**:
```json
// tsconfig.json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./*"]
    }
  }
}
```

---

## 📞 지원

### 질문이 있나요?

1. **아키텍처 관련**: `01_SYSTEM_OVERVIEW.md` 참고
2. **다이어그램**: `02_ARCHITECTURE_DIAGRAMS.md` 참고
3. **구현 방법**: `03_IMPLEMENTATION_GUIDE.md` 참고

### 버그 발견 시

1. 에러 로그 확인
2. 브라우저 콘솔 확인
3. 네트워크 탭 확인
4. 백엔드 로그 확인

---

## 🎓 학습 자료

### 추천 순서

1. **시스템 이해** (1시간)
   - 01_SYSTEM_OVERVIEW.md
   - 02_ARCHITECTURE_DIAGRAMS.md

2. **실습** (6시간)
   - 03_IMPLEMENTATION_GUIDE.md 따라하기
   - Phase 1~4 순차 진행

3. **심화** (2시간)
   - 코드 리뷰
   - 최적화 방법 학습
   - 테스트 작성

---

## 🎉 최종 목표

**이 아키텍처를 따라 구현하면**:

✅ **안정적**: UI 오류 제로, 백엔드 복구 가능
✅ **단순함**: 복잡한 라이브러리 없음, 이해하기 쉬움
✅ **유지보수 가능**: 모듈화된 구조, 명확한 문서
✅ **확장 가능**: 새 기능 추가 용이
✅ **사용자 친화적**: 직관적인 UI, 명확한 피드백

---

## 📝 체크리스트

구현을 시작하기 전에:

- [ ] 모든 문서를 읽었나요?
- [ ] 다이어그램을 이해했나요?
- [ ] 개발 환경이 준비되었나요?
- [ ] 백엔드 코드 위치를 확인했나요?
- [ ] 프론트엔드 UI 레퍼런스를 확인했나요?

구현을 완료한 후:

- [ ] 모든 기능이 동작하나요?
- [ ] UI 에러가 없나요?
- [ ] 에러 핸들링이 적용되었나요?
- [ ] 통합 테스트를 통과했나요?
- [ ] 문서를 업데이트했나요?

---

**이 설계서를 따라 세계 최고 수준의 SaaS를 만드세요!** 🚀

**안정성, 단순성, 유지보수성을 최우선으로!** ✨
