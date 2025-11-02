# DocuNova Modern - 차세대 AI 문서 분석 플랫폼

> Next.js 14 + TypeScript + Tailwind CSS로 구축된 현대적인 Private RAG 프론트엔드

## 🚀 주요 기능

- ✨ **현대적인 UI/UX**: shadcn/ui 기반 깔끔한 디자인
- 📊 **인터랙티브 대시보드**: 사용 통계 및 인사이트 시각화
- 💬 **실시간 채팅**: 스트리밍 답변 지원
- 📁 **문서 관리**: 드래그앤드롭, 폴더 구조
- ⌨️ **키보드 단축키**: Cmd+K 커맨드 팔레트
- 🌓 **다크 모드**: 자동 테마 전환
- 📱 **반응형**: 모바일/태블릿 완벽 지원

## 📦 설치 방법

```bash
# 1. 의존성 설치
npm install

# 2. 개발 서버 실행
npm run dev

# 3. 브라우저에서 열기
# http://localhost:3000
```

## 🏗️ 프로젝트 구조

```
docunova-modern/
├── app/                    # Next.js App Router
│   ├── dashboard/         # 대시보드 페이지
│   ├── chat/              # 채팅 페이지
│   ├── documents/         # 문서 관리 페이지
│   ├── globals.css        # 전역 스타일
│   ├── layout.tsx         # 루트 레이아웃
│   └── page.tsx           # 홈페이지
├── components/
│   └── ui/                # shadcn/ui 컴포넌트
│       ├── button.tsx
│       ├── card.tsx
│       └── input.tsx
├── lib/
│   └── utils.ts           # 유틸리티 함수
├── next.config.mjs        # Next.js 설정
├── tailwind.config.ts     # Tailwind CSS 설정
└── tsconfig.json          # TypeScript 설정
```

## 🔧 백엔드 연동

이 프론트엔드는 FastAPI 백엔드(포트 8000)와 연동됩니다.

```bash
# 1. 백엔드 실행 (별도 터미널)
cd ../private_rag_docunova_backup_ver2/backend
python main.py

# 2. 프론트엔드 실행
npm run dev
```

API 프록시 설정은 `next.config.mjs`에서 확인할 수 있습니다.

## 🎨 디자인 시스템

### 색상 팔레트
- **Primary**: Blue (#3B82F6)
- **Secondary**: Purple (#8B5CF6)
- **Accent**: 그라디언트 (Blue → Purple)
- **다크 모드**: 완벽 지원

### 컴포넌트
- Button, Card, Input
- 추가 컴포넌트는 [shadcn/ui](https://ui.shadcn.com/)에서 확인

## 📝 개발 가이드

### 새 페이지 추가
```typescript
// app/new-page/page.tsx
export default function NewPage() {
  return <div>New Page</div>
}
```

### API 호출
```typescript
const response = await fetch('/api/vectors')
const data = await response.json()
```

## 🚢 배포

```bash
# 빌드
npm run build

# 프로덕션 실행
npm start
```

## 📄 라이선스

MIT

---

**DocuNova** - 기업 문서를 AI로 분석하는 가장 빠른 방법
