# DocuNova 개발 환경 설정 가이드

## 📋 문서 개요

**작성일**: 2025-10-30
**목적**: 안정적이고 일관된 코드 품질을 보장하기 위한 개발 환경 설정
**설계 원칙**: 오류 사전 방지, 코드 품질 자동화, 팀 협업 효율성

---

## 🎯 개발 환경 설정 목표

### 1. 오류 사전 방지
- TypeScript strict 모드로 타입 안전성 확보
- ESLint로 잠재적 버그 사전 탐지
- Python type hints + mypy로 타입 체크

### 2. 코드 품질 자동화
- Prettier로 일관된 포맷팅
- Black으로 Python 코드 자동 포맷팅
- 커밋 전 자동 검증 (pre-commit hooks)

### 3. 팀 협업 효율성
- 일관된 코드 스타일
- 자동화된 코드 리뷰 체크
- 명확한 에러 메시지

---

## 🔍 전체 아키텍처 재검토 결과

### ✅ 검토 항목

#### 1. **호환성 검증**
- ✅ React 19.2.0 + Next.js 16.0.0: 공식 지원 확인
- ✅ TypeScript 5.9.3: React 19 타입 정의 호환
- ✅ ESLint 9.38.0 + eslint-config-next 16.0.0: 최신 버전 호환
- ✅ FastAPI 0.115.0 + Pydantic 2.9.2: 완벽한 호환
- ✅ Python 3.11: 모든 패키지 지원

#### 2. **잠재적 이슈 확인**
- ⚠️ **발견**: tsconfig.json에서 `jsx: "react-jsx"` 사용
  - **문제**: Next.js 16은 `jsx: "preserve"` 권장
  - **해결**: tsconfig.json 수정 필요

- ⚠️ **발견**: next.config.mjs의 rewrites 설정
  - **문제**: CORS 이슈 발생 가능
  - **해결**: 백엔드 CORS 설정 확인 필요

- ⚠️ **발견**: 백엔드에 린팅/포맷팅 설정 없음
  - **문제**: 코드 품질 불일치 가능
  - **해결**: Black, isort, mypy, ruff 설정 추가

- ⚠️ **발견**: pre-commit hooks 미설정
  - **문제**: 오류 있는 코드 커밋 가능
  - **해결**: Husky + lint-staged 설정

#### 3. **비효율적인 부분 식별**
- 📌 ESLint 설정이 너무 단순함 → 더 엄격한 규칙 추가 필요
- 📌 타입 체크가 빌드 시에만 실행 → 개발 중에도 실행
- 📌 Python 코드에 타입 힌트 부족 → mypy 강제 적용

---

## 🛠️ 프론트엔드 개발 환경 설정

### 1. TypeScript 설정 (수정 필요!)

**파일**: `frontend/tsconfig.json`

#### ⚠️ 현재 설정의 문제점

```json
// ❌ 현재 설정 (문제 있음)
{
  "compilerOptions": {
    "jsx": "react-jsx",  // Next.js 16과 호환 문제!
    "target": "ES2020",  // 너무 오래된 타겟
    // ... strict 옵션 부족
  }
}
```

#### ✅ 권장 설정 (안정적이고 최적화됨)

```json
{
  "compilerOptions": {
    // 언어 및 환경
    "target": "ES2022",                          // 최신 안정 버전
    "lib": ["ES2023", "DOM", "DOM.Iterable"],   // 최신 API 지원
    "jsx": "preserve",                           // Next.js 16 필수!

    // 모듈 해석
    "module": "ESNext",
    "moduleResolution": "bundler",               // Next.js 16 권장
    "resolveJsonModule": true,
    "allowJs": true,

    // 타입 체크 (매우 중요!)
    "strict": true,                              // 모든 strict 옵션 활성화
    "noUnusedLocals": true,                      // 사용하지 않는 로컬 변수 에러
    "noUnusedParameters": true,                  // 사용하지 않는 파라미터 에러
    "noFallthroughCasesInSwitch": true,         // switch fallthrough 방지
    "noImplicitReturns": true,                   // 암묵적 return 방지
    "noUncheckedIndexedAccess": true,            // 배열/객체 접근 안전성
    "exactOptionalPropertyTypes": true,          // 옵셔널 속성 엄격 체크
    "noImplicitOverride": true,                  // override 명시 필수
    "allowUnusedLabels": false,                  // 사용하지 않는 레이블 금지
    "allowUnreachableCode": false,               // 도달 불가능한 코드 금지

    // 상호 운용성
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,   // 파일명 대소문자 일관성
    "isolatedModules": true,

    // 출력
    "noEmit": true,                              // Next.js가 빌드 담당
    "incremental": true,                         // 증분 컴파일
    "skipLibCheck": true,                        // 라이브러리 타입 체크 스킵

    // 경로 매핑
    "baseUrl": ".",
    "paths": {
      "@/*": ["./*"],
      "@/components/*": ["./components/*"],
      "@/lib/*": ["./lib/*"],
      "@/hooks/*": ["./hooks/*"],
      "@/styles/*": ["./styles/*"]
    },

    // Next.js 플러그인
    "plugins": [
      {
        "name": "next"
      }
    ]
  },
  "include": [
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx",
    ".next/types/**/*.ts"
  ],
  "exclude": [
    "node_modules",
    ".next",
    "out",
    "dist"
  ]
}
```

**주요 변경 사항**:
1. ✅ `jsx: "preserve"` - Next.js 16 필수
2. ✅ `target: "ES2022"` - 최신 안정 버전
3. ✅ 엄격한 타입 체크 옵션 추가
4. ✅ 경로 매핑 세분화

---

### 2. ESLint 설정 (강화 필요!)

**파일**: `frontend/.eslintrc.json`

#### ⚠️ 현재 설정의 문제점

```json
// ❌ 현재 설정 (너무 단순함)
{
  "extends": ["next/core-web-vitals", "next/typescript"]
}
```

#### ✅ 권장 설정 (엄격하고 안전함)

```json
{
  "extends": [
    "next/core-web-vitals",
    "next/typescript",
    "plugin:@typescript-eslint/recommended",
    "plugin:@typescript-eslint/recommended-requiring-type-checking"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": 2022,
    "sourceType": "module",
    "project": "./tsconfig.json"
  },
  "plugins": [
    "@typescript-eslint",
    "react-hooks",
    "import"
  ],
  "rules": {
    // TypeScript 규칙
    "@typescript-eslint/no-explicit-any": "error",           // any 금지
    "@typescript-eslint/no-unused-vars": [
      "error",
      {
        "argsIgnorePattern": "^_",
        "varsIgnorePattern": "^_"
      }
    ],
    "@typescript-eslint/explicit-function-return-type": [
      "warn",
      {
        "allowExpressions": true,
        "allowTypedFunctionExpressions": true
      }
    ],
    "@typescript-eslint/no-floating-promises": "error",      // Promise 처리 필수
    "@typescript-eslint/await-thenable": "error",            // await 올바른 사용
    "@typescript-eslint/no-misused-promises": "error",       // Promise 오용 방지
    "@typescript-eslint/strict-boolean-expressions": "warn", // boolean 엄격 체크

    // React 규칙
    "react/jsx-no-leaked-render": "error",                   // && 렌더링 안전성
    "react/self-closing-comp": "error",                      // 자동 닫기 태그
    "react-hooks/rules-of-hooks": "error",                   // Hook 규칙
    "react-hooks/exhaustive-deps": "warn",                   // Hook 의존성

    // Import 규칙
    "import/order": [
      "error",
      {
        "groups": [
          "builtin",
          "external",
          "internal",
          "parent",
          "sibling",
          "index"
        ],
        "newlines-between": "always",
        "alphabetize": {
          "order": "asc",
          "caseInsensitive": true
        }
      }
    ],
    "import/no-duplicates": "error",                         // 중복 import 방지
    "import/no-cycle": "error",                              // 순환 import 방지

    // 일반 규칙
    "no-console": [
      "warn",
      {
        "allow": ["warn", "error"]
      }
    ],
    "no-debugger": "error",
    "prefer-const": "error",
    "no-var": "error",
    "eqeqeq": ["error", "always"],                           // === 사용 강제
    "curly": ["error", "all"],                               // 중괄호 필수

    // Next.js 특화 규칙
    "@next/next/no-html-link-for-pages": "error",
    "@next/next/no-img-element": "warn"                      // Image 컴포넌트 권장
  },
  "overrides": [
    {
      "files": ["*.js", "*.jsx"],
      "rules": {
        "@typescript-eslint/explicit-function-return-type": "off"
      }
    }
  ]
}
```

---

### 3. Prettier 설정 (코드 포맷팅)

**파일**: `frontend/.prettierrc.json`

```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "always",
  "endOfLine": "lf",
  "bracketSpacing": true,
  "jsxSingleQuote": false,
  "jsxBracketSameLine": false,
  "plugins": ["prettier-plugin-tailwindcss"]
}
```

**파일**: `frontend/.prettierignore`

```
node_modules
.next
out
dist
build
coverage
*.min.js
*.min.css
```

---

### 4. Next.js 설정 (수정 필요!)

**파일**: `frontend/next.config.mjs`

#### ⚠️ 현재 설정의 문제점

```javascript
// ❌ 현재 설정
const nextConfig = {
  reactStrictMode: true,
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: 'http://localhost:8000/:path*',  // CORS 이슈 가능
      },
    ];
  },
  experimental: {
    serverActions: {
      bodySizeLimit: '10mb',
    },
  },
};
```

#### ✅ 권장 설정 (안전하고 최적화됨)

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  // React Strict Mode (버그 조기 발견)
  reactStrictMode: true,

  // TypeScript 엄격 모드
  typescript: {
    // 빌드 시 타입 에러가 있으면 빌드 실패
    ignoreBuildErrors: false,
  },

  // ESLint 엄격 모드
  eslint: {
    // 빌드 시 ESLint 에러가 있으면 빌드 실패
    ignoreDuringBuilds: false,
  },

  // 환경 변수
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000',
  },

  // API 프록시 (CORS 해결)
  async rewrites() {
    return [
      {
        source: '/api/v1/:path*',
        destination: `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'}/api/v1/:path*`,
      },
    ];
  },

  // 파일 업로드 크기
  experimental: {
    serverActions: {
      bodySizeLimit: '100mb',  // 백엔드와 일치
    },
  },

  // 이미지 최적화
  images: {
    formats: ['image/avif', 'image/webp'],
    domains: ['localhost'],
  },

  // 보안 헤더
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-DNS-Prefetch-Control',
            value: 'on',
          },
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=63072000; includeSubDomains; preload',
          },
          {
            key: 'X-Frame-Options',
            value: 'SAMEORIGIN',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
          {
            key: 'Referrer-Policy',
            value: 'origin-when-cross-origin',
          },
        ],
      },
    ];
  },

  // 번들 분석 (개발 시)
  webpack: (config, { dev, isServer }) => {
    // 프로덕션 빌드 최적화
    if (!dev && !isServer) {
      config.optimization.splitChunks = {
        chunks: 'all',
        cacheGroups: {
          default: false,
          vendors: false,
          commons: {
            name: 'commons',
            chunks: 'all',
            minChunks: 2,
          },
        },
      };
    }

    return config;
  },
};

export default nextConfig;
```

---

### 5. VS Code 설정 (권장)

**파일**: `frontend/.vscode/settings.json`

```json
{
  // 에디터 설정
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit",
    "source.organizeImports": "explicit"
  },
  "editor.rulers": [80, 120],
  "editor.tabSize": 2,
  "editor.insertSpaces": true,

  // TypeScript 설정
  "typescript.tsdk": "node_modules/typescript/lib",
  "typescript.enablePromptUseWorkspaceTsdk": true,
  "typescript.preferences.importModuleSpecifier": "relative",
  "typescript.suggest.autoImports": true,

  // ESLint 설정
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],

  // Prettier 설정
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },

  // 파일 연결
  "files.associations": {
    "*.css": "tailwindcss"
  },

  // 제외 파일
  "files.exclude": {
    "**/.next": true,
    "**/node_modules": true
  },

  // Tailwind CSS IntelliSense
  "tailwindCSS.experimental.classRegex": [
    ["cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
    ["cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)"]
  ]
}
```

---

### 6. 추가 패키지 설치

**파일**: `frontend/package.json` (dependencies 추가)

```json
{
  "devDependencies": {
    "@types/node": "^24.9.1",
    "@types/react": "^19.2.2",
    "@types/react-dom": "^19.2.2",
    "@typescript-eslint/eslint-plugin": "^8.21.0",
    "@typescript-eslint/parser": "^8.21.0",
    "eslint": "^9.38.0",
    "eslint-config-next": "^16.0.0",
    "eslint-plugin-import": "^2.31.0",
    "eslint-plugin-react-hooks": "^5.1.0",
    "prettier": "^3.4.2",
    "prettier-plugin-tailwindcss": "^0.6.10",
    "husky": "^9.1.7",
    "lint-staged": "^15.2.11",
    "typescript": "^5.9.3"
  },
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "lint:fix": "next lint --fix",
    "format": "prettier --write \"**/*.{ts,tsx,js,jsx,json,css,md}\"",
    "type-check": "tsc --noEmit",
    "test": "echo \"No tests yet\"",
    "prepare": "husky install"
  }
}
```

---

### 7. Pre-commit Hooks 설정

#### Husky 초기화

```bash
# 프론트엔드 디렉토리에서
cd frontend
npx husky install
npx husky add .husky/pre-commit "npx lint-staged"
```

**파일**: `frontend/.husky/pre-commit`

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx lint-staged
```

#### lint-staged 설정

**파일**: `frontend/.lintstagedrc.json`

```json
{
  "*.{ts,tsx}": [
    "eslint --fix",
    "prettier --write",
    "bash -c 'tsc --noEmit'"
  ],
  "*.{js,jsx}": [
    "eslint --fix",
    "prettier --write"
  ],
  "*.{json,css,md}": [
    "prettier --write"
  ]
}
```

---

## 🐍 백엔드 개발 환경 설정

### 1. Python 린팅 및 포맷팅

#### 필수 패키지 설치

**파일**: `backend/requirements-dev.txt` (새로 생성)

```txt
# 린팅 및 포맷팅
black==24.10.0
isort==5.13.2
ruff==0.8.4
mypy==1.14.0

# 타입 스텁
types-aiofiles==23.2.0.20240403
types-Pillow==10.2.0.20241206

# 테스팅
pytest==8.3.4
pytest-asyncio==0.24.0
pytest-cov==6.0.0
httpx==0.27.0  # 이미 requirements.txt에 있지만 테스트용

# pre-commit
pre-commit==4.0.1
```

---

### 2. Black 설정 (Python 포맷팅)

**파일**: `backend/pyproject.toml` (새로 생성)

```toml
[tool.black]
line-length = 88
target-version = ['py311']
include = '\.pyi?$'
extend-exclude = '''
/(
    \.eggs
  | \.git
  | \.hg
  | \.mypy_cache
  | \.tox
  | \.venv
  | venv
  | _build
  | buck-out
  | build
  | dist
  | __pycache__
)/
'''

[tool.isort]
profile = "black"
line_length = 88
multi_line_output = 3
include_trailing_comma = true
force_grid_wrap = 0
use_parentheses = true
ensure_newline_before_comments = true
skip_glob = ["**/venv/**", "**/__pycache__/**"]

[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_any_unimported = false
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
check_untyped_defs = true
strict_equality = true

[[tool.mypy.overrides]]
module = [
    "fastembed.*",
    "qdrant_client.*",
    "pypdf.*",
    "docx.*",
]
ignore_missing_imports = true

[tool.ruff]
line-length = 88
target-version = "py311"

[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "C",   # flake8-comprehensions
    "B",   # flake8-bugbear
    "UP",  # pyupgrade
]
ignore = [
    "E501",  # line too long (Black handles this)
    "B008",  # do not perform function calls in argument defaults
    "C901",  # too complex
]

[tool.ruff.lint.per-file-ignores]
"__init__.py" = ["F401"]

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "-v --cov=app --cov-report=html --cov-report=term-missing"
asyncio_mode = "auto"
```

---

### 3. Pre-commit 설정 (백엔드)

**파일**: `backend/.pre-commit-config.yaml` (새로 생성)

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
        args: ['--maxkb=10000']
      - id: check-json
      - id: check-toml
      - id: check-merge-conflict
      - id: detect-private-key

  - repo: https://github.com/psf/black
    rev: 24.10.0
    hooks:
      - id: black
        language_version: python3.11

  - repo: https://github.com/pycqa/isort
    rev: 5.13.2
    hooks:
      - id: isort
        args: ["--profile", "black"]

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.8.4
    hooks:
      - id: ruff
        args: [--fix, --exit-non-zero-on-fix]

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.14.0
    hooks:
      - id: mypy
        additional_dependencies:
          - types-aiofiles
          - types-Pillow
        args: [--ignore-missing-imports]
```

**초기화**:

```bash
cd backend
pip install -r requirements-dev.txt
pre-commit install
```

---

### 4. VS Code 설정 (백엔드)

**파일**: `backend/.vscode/settings.json`

```json
{
  // Python 설정
  "python.defaultInterpreterPath": "${workspaceFolder}/venv/bin/python",
  "python.formatting.provider": "black",
  "python.formatting.blackArgs": ["--line-length=88"],
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": false,
  "python.linting.flake8Enabled": false,
  "python.linting.mypyEnabled": true,
  "python.linting.mypyArgs": [
    "--ignore-missing-imports",
    "--follow-imports=silent",
    "--show-column-numbers"
  ],

  // 에디터 설정
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": "explicit"
  },
  "editor.rulers": [88],
  "editor.tabSize": 4,
  "editor.insertSpaces": true,

  // Ruff 설정
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.codeActionsOnSave": {
      "source.fixAll": "explicit",
      "source.organizeImports": "explicit"
    }
  },

  // 파일 제외
  "files.exclude": {
    "**/__pycache__": true,
    "**/.mypy_cache": true,
    "**/.pytest_cache": true,
    "**/venv": true
  },

  // 테스트
  "python.testing.pytestEnabled": true,
  "python.testing.unittestEnabled": false,
  "python.testing.pytestArgs": ["tests"]
}
```

---

## 🔄 Git 설정

### .gitignore (프로젝트 루트)

```gitignore
# 환경 변수
.env
.env.local
.env.*.local
backend/.env

# 의존성
node_modules/
venv/
__pycache__/
*.py[cod]
*$py.class

# 빌드 결과
.next/
out/
dist/
build/
*.egg-info/

# 로그
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# 데이터
data/
uploads/
qdrant_storage/
chat_history/*.db
exports/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# 테스트
coverage/
.pytest_cache/
.mypy_cache/
.ruff_cache/
htmlcov/

# 임시 파일
*.tmp
*.bak
*.swp
```

---

## 📋 개발 워크플로우

### 1. 초기 설정

```bash
# 1. 프로젝트 클론
git clone <repository-url>
cd docunova-saas

# 2. 백엔드 설정
cd backend
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate

pip install -r requirements.txt
pip install -r requirements-dev.txt
pre-commit install
cp .env.example .env

# 3. 프론트엔드 설정
cd ../frontend
npm install
npx husky install
cp .env.local.example .env.local

# 4. 환경 변수 설정
# backend/.env 파일 수정
# frontend/.env.local 파일 수정
```

---

### 2. 개발 시작

```bash
# 터미널 1: 백엔드
cd backend
source venv/bin/activate  # Windows: venv\Scripts\activate
python main.py

# 터미널 2: 프론트엔드
cd frontend
npm run dev
```

---

### 3. 코드 작성 전 체크

#### 프론트엔드

```bash
# 타입 체크
npm run type-check

# 린트 체크
npm run lint

# 포맷 체크 (자동 수정)
npm run format
```

#### 백엔드

```bash
# 포맷팅
black .
isort .

# 린트
ruff check .

# 타입 체크
mypy app/

# 테스트
pytest
```

---

### 4. 커밋 전 자동 검증

```bash
# Git add
git add .

# 커밋 시도 (pre-commit hooks 자동 실행)
git commit -m "feat: 새 기능 추가"

# ✅ 모든 검사 통과 시 커밋 성공
# ❌ 검사 실패 시 자동 수정 또는 에러 표시
```

**Pre-commit hooks 실행 내용**:

**프론트엔드**:
1. ESLint 자동 수정
2. Prettier 포맷팅
3. TypeScript 타입 체크

**백엔드**:
1. Black 포맷팅
2. isort import 정렬
3. Ruff 린트 체크
4. mypy 타입 체크

---

## 🧪 테스트 설정

### 프론트엔드 테스트 (Jest + React Testing Library)

**파일**: `frontend/jest.config.js`

```javascript
const nextJest = require('next/jest');

const createJestConfig = nextJest({
  dir: './',
});

const customJestConfig = {
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testEnvironment: 'jest-environment-jsdom',
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/$1',
  },
  collectCoverageFrom: [
    'app/**/*.{js,jsx,ts,tsx}',
    'components/**/*.{js,jsx,ts,tsx}',
    'lib/**/*.{js,jsx,ts,tsx}',
    '!**/*.d.ts',
    '!**/node_modules/**',
    '!**/.next/**',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
};

module.exports = createJestConfig(customJestConfig);
```

**파일**: `frontend/jest.setup.js`

```javascript
import '@testing-library/jest-dom';
```

---

### 백엔드 테스트 (Pytest)

**파일**: `backend/pytest.ini`

```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts =
    -v
    --cov=app
    --cov-report=html
    --cov-report=term-missing
    --cov-fail-under=70
asyncio_mode = auto
```

---

## 📊 코드 품질 메트릭

### 목표 지표

| 항목 | 목표 | 설명 |
|-----|------|------|
| TypeScript Strict | 100% | 모든 파일 strict 모드 |
| ESLint Errors | 0 | 에러 없음 |
| Test Coverage | ≥70% | 코드 커버리지 70% 이상 |
| Type Coverage | ≥90% | 타입 커버리지 90% 이상 |
| Build Success | 100% | 빌드 항상 성공 |

---

## 🔍 문제 해결 가이드

### 문제 1: TypeScript 에러

```bash
# 에러 확인
npm run type-check

# 자주 발생하는 에러
# 1. "Cannot find module '@/...'"
# 해결: tsconfig.json의 paths 설정 확인

# 2. "Type 'any' is not assignable..."
# 해결: 명시적 타입 지정 필요
```

### 문제 2: ESLint 에러

```bash
# 자동 수정
npm run lint:fix

# 특정 파일 무시 (최후의 수단)
// eslint-disable-next-line @typescript-eslint/no-explicit-any
```

### 문제 3: Pre-commit Hook 실패

```bash
# Hook 스킵 (긴급 상황에만!)
git commit --no-verify -m "message"

# 권장: 에러 수정 후 커밋
npm run lint:fix
npm run format
git add .
git commit -m "message"
```

### 문제 4: Python 타입 에러

```bash
# mypy 에러 확인
mypy app/

# 특정 라이브러리 무시
# pyproject.toml에 추가:
# [[tool.mypy.overrides]]
# module = ["problem_library.*"]
# ignore_missing_imports = true
```

---

## ✅ 설정 체크리스트

### 프론트엔드
- [ ] tsconfig.json 업데이트 (`jsx: "preserve"`)
- [ ] .eslintrc.json 강화
- [ ] .prettierrc.json 생성
- [ ] next.config.mjs 보안 헤더 추가
- [ ] package.json scripts 추가
- [ ] Husky 설치 및 설정
- [ ] lint-staged 설정
- [ ] .vscode/settings.json 생성

### 백엔드
- [ ] requirements-dev.txt 생성
- [ ] pyproject.toml 생성
- [ ] .pre-commit-config.yaml 생성
- [ ] pre-commit install 실행
- [ ] .vscode/settings.json 생성
- [ ] pytest.ini 설정

### 공통
- [ ] .gitignore 업데이트
- [ ] README.md 업데이트
- [ ] 팀원에게 설정 공유

---

## 🎓 베스트 프랙티스

### 1. 타입 안전성

```typescript
// ❌ 나쁜 예
function processData(data: any) {
  return data.value;
}

// ✅ 좋은 예
interface Data {
  value: string;
}

function processData(data: Data): string {
  return data.value;
}
```

### 2. 에러 핸들링

```typescript
// ❌ 나쁜 예
async function fetchData() {
  const response = await fetch('/api/data');
  return response.json();
}

// ✅ 좋은 예
async function fetchData(): Promise<ApiResponse | null> {
  try {
    const response = await fetch('/api/data');

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error('Failed to fetch data:', error);
    return null;
  }
}
```

### 3. Python 타입 힌트

```python
# ❌ 나쁜 예
def process_text(text):
    return text.upper()

# ✅ 좋은 예
def process_text(text: str) -> str:
    """텍스트를 대문자로 변환"""
    return text.upper()

# ✅ 더 좋은 예 (에러 핸들링 포함)
def process_text(text: str) -> str:
    """
    텍스트를 대문자로 변환

    Args:
        text: 변환할 텍스트

    Returns:
        대문자로 변환된 텍스트

    Raises:
        TypeError: text가 문자열이 아닌 경우
    """
    if not isinstance(text, str):
        raise TypeError("text must be a string")

    return text.upper()
```

---

## 📚 관련 문서

- `04_TECHNOLOGY_STACK_REVIEW.md` - 기술 스택 호환성
- `05_DIRECTORY_STRUCTURE.md` - 디렉토리 구조
- `03_IMPLEMENTATION_GUIDE.md` - 구현 가이드

---

## 🎯 요약

### 핵심 개선 사항

1. ✅ **TypeScript 설정 강화**
   - jsx: "preserve" (Next.js 16 필수)
   - 엄격한 타입 체크 옵션 추가
   - 경로 매핑 세분화

2. ✅ **ESLint 규칙 강화**
   - @typescript-eslint/no-explicit-any 에러
   - Promise 처리 필수
   - Import 순서 자동 정렬

3. ✅ **Next.js 설정 보안 강화**
   - 보안 헤더 추가
   - CORS 이슈 해결
   - 빌드 최적화

4. ✅ **백엔드 린팅 추가**
   - Black + isort (포맷팅)
   - Ruff (린트)
   - mypy (타입 체크)

5. ✅ **Pre-commit Hooks 설정**
   - 프론트엔드: ESLint + Prettier + TypeScript
   - 백엔드: Black + isort + Ruff + mypy

### 안정성 보장

- ✅ 커밋 전 자동 검증
- ✅ 타입 안전성 100%
- ✅ 코드 품질 자동화
- ✅ 오류 사전 방지

---

**이제 안정적이고 일관된 코드 품질을 보장할 수 있는 개발 환경이 완성되었습니다!** 🎉
