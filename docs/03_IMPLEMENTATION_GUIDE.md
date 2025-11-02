# DocuNova 단계별 구현 가이드

## 📋 문서 개요

이 가이드는 **안정적이고 오류 없는** DocuNova SaaS를 단계별로 구현하는 방법을 설명합니다.

**핵심 원칙**:
- ✅ 각 단계를 완료한 후 철저히 테스트
- ✅ UI 오류 제로 목표
- ✅ 단순하고 유지보수 가능한 코드

---

## 📁 프로젝트 구조

```
docunova-saas/
├── backend/                    # FastAPI 백엔드
│   ├── main.py                # 메인 서버 파일
│   ├── requirements.txt       # Python 의존성
│   ├── .env                   # 환경 변수
│   ├── data/                  # 업로드된 문서
│   ├── qdrant_storage/        # Qdrant 데이터
│   └── chat_history/          # 채팅 히스토리
│
├── frontend/                   # Next.js 프론트엔드
│   ├── app/                   # 페이지 (App Router)
│   │   ├── page.tsx          # 홈
│   │   ├── layout.tsx        # 루트 레이아웃
│   │   ├── globals.css       # 전역 스타일
│   │   ├── chat/             # 채팅 페이지
│   │   ├── dashboard/        # 대시보드
│   │   ├── documents/        # 문서 관리
│   │   └── settings/         # 설정
│   │
│   ├── components/            # 재사용 컴포넌트
│   │   └── ui/               # shadcn/ui 컴포넌트
│   │
│   ├── lib/                   # 유틸리티
│   │   ├── api.ts            # ⭐ API 클라이언트 (핵심!)
│   │   └── utils.ts          # 유틸리티 함수
│   │
│   ├── package.json           # Node 의존성
│   ├── next.config.mjs        # Next.js 설정
│   ├── tailwind.config.ts     # Tailwind 설정
│   └── tsconfig.json          # TypeScript 설정
│
├── docker-compose.yml         # Docker 배포 (선택)
└── README.md                  # 프로젝트 설명
```

---

## 🔷 Phase 1: 백엔드 구축 (안정성 최우선)

### Step 1.1: 백엔드 초기 설정

```bash
# 백엔드 폴더 생성
mkdir docunova-saas
cd docunova-saas
mkdir backend
cd backend

# Python 가상환경 생성
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# requirements.txt 생성
```

**requirements.txt**:
```txt
fastapi==0.115.0
uvicorn[standard]==0.30.6
python-multipart==0.0.9
httpx==0.27.0

qdrant-client==1.12.1
fastembed==0.3.2

pypdf==4.3.1
PyMuPDF==1.24.10
docx2txt==0.8
python-docx==1.1.2
openpyxl==3.1.5

pydantic==2.9.2
typing_extensions>=4.12.2
aiofiles==23.2.1
```

```bash
# 의존성 설치
pip install -r requirements.txt
```

### Step 1.2: main.py 작성 (핵심 백엔드)

**파일 위치**: `backend/main.py`

기존 `C:\Users\leeji\Desktop\006 Web_page\DocuNova\private_rag_docunova_backup\backend\main.py`를 복사하되, 다음 수정사항 적용:

#### ✅ 수정사항 1: CORS 설정 강화

```python
# CORS 설정 (프론트엔드 통신을 위해 필수!)
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",      # 개발 환경
        "http://127.0.0.1:3000",      # 개발 환경 (대체)
        # 프로덕션 환경에서는 실제 도메인 추가
        # "https://yourdomain.com"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

#### ✅ 수정사항 2: 헬스체크 엔드포인트 개선

```python
@app.get("/api/health")
async def health_check():
    """헬스체크 - 모든 서비스 상태 확인"""
    try:
        # Ollama 연결 확인
        ollama_status = "healthy" if _ollama_available else "unhealthy"

        # Qdrant 연결 확인
        qdrant_status = "healthy"
        try:
            if _qdrant:
                _qdrant.get_collections()
        except:
            qdrant_status = "unhealthy"

        return {
            "status": "healthy" if (ollama_status == "healthy" and qdrant_status == "healthy") else "degraded",
            "timestamp": datetime.now().isoformat(),
            "services": {
                "ollama": ollama_status,
                "qdrant": qdrant_status,
                "embedding": "healthy" if _embedding_model else "unhealthy"
            }
        }
    except Exception as e:
        log.error(f"Health check failed: {e}")
        raise HTTPException(status_code=500, detail="Health check failed")
```

#### ✅ 수정사항 3: 에러 응답 표준화

모든 엔드포인트에서 일관된 에러 응답:

```python
try:
    # 비즈니스 로직
    pass
except ValueError as e:
    raise HTTPException(
        status_code=400,
        detail={"error": "Invalid input", "message": str(e)}
    )
except FileNotFoundError as e:
    raise HTTPException(
        status_code=404,
        detail={"error": "Not found", "message": str(e)}
    )
except Exception as e:
    log.error(f"Unexpected error: {e}")
    raise HTTPException(
        status_code=500,
        detail={"error": "Internal server error", "message": "An unexpected error occurred"}
    )
```

### Step 1.3: LLM 통신 안정성 강화 (⚠️ 필수!)

**Ollama와의 통신은 불안정할 수 있으므로 반드시 에러 핸들링 추가**

**파일 위치**: `backend/services/llm.py` 또는 `backend/main.py`

```python
import httpx
import asyncio
from fastapi import HTTPException
import logging

log = logging.getLogger(__name__)

async def query_ollama_with_retry(
    question: str,
    model: str = "llama3.1:8b",
    max_retries: int = 2
) -> dict:
    """
    Ollama LLM에 질의 (타임아웃 및 재시도 포함)

    Args:
        question: 질문 내용
        model: 사용할 모델
        max_retries: 최대 재시도 횟수

    Returns:
        LLM 응답

    Raises:
        HTTPException: 연결 실패, 타임아웃, 기타 에러
    """
    for attempt in range(max_retries):
        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    "http://localhost:11434/api/generate",
                    json={
                        "model": model,
                        "prompt": question,
                        "stream": False
                    }
                )
                response.raise_for_status()
                return response.json()

        except httpx.TimeoutException:
            log.warning(f"Ollama 타임아웃 (시도 {attempt + 1}/{max_retries})")
            if attempt == max_retries - 1:
                raise HTTPException(
                    status_code=504,
                    detail="AI 서버 응답 시간이 초과되었습니다. 질문을 단순화해보세요."
                )
            await asyncio.sleep(1 * (attempt + 1))  # 1초, 2초 대기

        except httpx.ConnectError:
            log.error("Ollama 연결 실패 - 서버가 실행 중인지 확인하세요")
            raise HTTPException(
                status_code=503,
                detail="AI 서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요."
            )

        except httpx.HTTPStatusError as e:
            log.error(f"Ollama HTTP 에러: {e.response.status_code}")
            raise HTTPException(
                status_code=e.response.status_code,
                detail=f"AI 서버 에러: {e.response.text}"
            )

        except Exception as e:
            log.error(f"예상치 못한 LLM 에러: {e}")
            raise HTTPException(
                status_code=500,
                detail="AI 처리 중 오류가 발생했습니다."
            )

# 헬스체크 엔드포인트 추가
@app.get("/api/health/llm")
async def check_llm_health():
    """Ollama LLM 서버 헬스체크"""
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.get("http://localhost:11434/api/tags")
            models = response.json()
            return {
                "status": "healthy",
                "models": models.get("models", [])
            }
    except Exception as e:
        log.error(f"LLM 헬스체크 실패: {e}")
        return {
            "status": "unhealthy",
            "error": str(e)
        }
```

**중요**: 이 코드를 반드시 적용하세요! Ollama 관련 에러는 가장 흔한 문제입니다.

### Step 1.4: 백엔드 테스트

```bash
# 1. Ollama 실행 확인
ollama list  # llama3.1:8b 모델이 있는지 확인

# 2. 백엔드 실행
cd backend
python main.py
```

**테스트 체크리스트**:
- [ ] 서버가 정상적으로 시작됨 (Port 8000)
- [ ] http://localhost:8000/docs 접속 가능 (Swagger UI)
- [ ] GET /api/health 호출 시 200 응답
- [ ] Ollama 연결 확인
- [ ] Qdrant 초기화 확인

---

## 🔷 Phase 2: 프론트엔드 구축 (UI 오류 제로)

### Step 2.1: Next.js 프로젝트 생성

```bash
cd ..  # docunova-saas 루트로 이동
npx create-next-app@latest frontend --typescript --tailwind --app --no-src-dir --import-alias "@/*"
cd frontend
```

**선택 사항**:
- TypeScript: Yes
- ESLint: Yes
- Tailwind CSS: Yes
- App Router: Yes
- Import alias (@/*): Yes

### ⚠️ 중요: React 19 + Next.js 16 호환성 체크

**Next.js 16부터 동기 Request API가 제거되었습니다!**

```typescript
// ❌ 동기 방식 (Next.js 16에서 불가능)
import { cookies, headers } from 'next/headers';

export default function Page() {
  const cookieStore = cookies();  // 에러 발생!
  const headersList = headers();  // 에러 발생!
}

// ✅ 비동기 방식 (필수)
import { cookies, headers } from 'next/headers';

export default async function Page() {
  const cookieStore = await cookies();  // OK
  const headersList = await headers();  // OK
}
```

**필수 확인 사항**:
1. `cookies()`, `headers()` 사용 시 **반드시 await 추가**
2. 컴포넌트를 **async function**으로 변경
3. Server Component만 해당 (Client Component는 영향 없음)

**관련 문서**: `04_TECHNOLOGY_STACK_REVIEW.md` 참고

### Step 2.2: UI 컴포넌트 복사

```bash
# DocuNova_NextJS_UI_Reference에서 복사
# 1. app/ 폴더 전체
# 2. components/ 폴더 전체
# 3. lib/ 폴더 전체
# 4. tailwind.config.ts
# 5. globals.css
```

**Windows PowerShell**:
```powershell
Copy-Item -Path "C:\Users\leeji\Desktop\006 Web_page\DocuNova\DocuNova_NextJS_UI_Reference\app\*" -Destination ".\app\" -Recurse -Force
Copy-Item -Path "C:\Users\leeji\Desktop\006 Web_page\DocuNova\DocuNova_NextJS_UI_Reference\components\*" -Destination ".\components\" -Recurse -Force
Copy-Item -Path "C:\Users\leeji\Desktop\006 Web_page\DocuNova\DocuNova_NextJS_UI_Reference\lib\*" -Destination ".\lib\" -Recurse -Force
```

### Step 2.3: API 클라이언트 작성 (⭐ 가장 중요!)

**파일 위치**: `frontend/lib/api.ts`

```typescript
// lib/api.ts
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

interface APIError {
  error: string;
  message: string;
}

class APIClient {
  private baseURL: string;
  private timeout: number;
  private maxRetries: number;

  constructor() {
    this.baseURL = API_BASE_URL;
    this.timeout = 30000; // 30초
    this.maxRetries = 3;
  }

  /**
   * 기본 fetch 래퍼 (타임아웃 + 재시도)
   */
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
      return response;
    } catch (error: any) {
      clearTimeout(timeoutId);

      // 타임아웃이나 네트워크 에러 시 재시도
      if (error.name === 'AbortError' || error.name === 'TypeError') {
        if (retries < this.maxRetries) {
          console.log(`Retrying (${retries + 1}/${this.maxRetries})...`);
          await this.delay(1000 * (retries + 1)); // 백오프
          return this.fetchWithRetry(url, options, retries + 1);
        }
      }

      throw error;
    }
  }

  /**
   * 지연 함수
   */
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * 에러 메시지 추출
   */
  private getErrorMessage(error: any): string {
    if (error.name === 'AbortError') {
      return '요청 시간이 초과되었습니다. 다시 시도해주세요.';
    }
    if (error.name === 'TypeError') {
      return '서버에 연결할 수 없습니다. 네트워크를 확인해주세요.';
    }
    if (error.detail?.message) {
      return error.detail.message;
    }
    if (error.message) {
      return error.message;
    }
    return '알 수 없는 오류가 발생했습니다.';
  }

  /**
   * 채팅 질의 (스트리밍)
   */
  async queryStream(
    question: string,
    mode: 'rag' | 'llm' = 'rag',
    top_k: number = 5
  ): Promise<ReadableStream> {
    try {
      const response = await this.fetchWithRetry(`${this.baseURL}/api/query_stream`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question, mode, top_k, language: 'ko' }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(this.getErrorMessage(error));
      }

      if (!response.body) {
        throw new Error('No response body');
      }

      return response.body;
    } catch (error) {
      console.error('Query stream error:', error);
      throw new Error(this.getErrorMessage(error));
    }
  }

  /**
   * 문서 업로드
   */
  async uploadFiles(files: File[]): Promise<{ success: boolean; message: string }> {
    try {
      const formData = new FormData();
      files.forEach(file => formData.append('files', file));

      const response = await this.fetchWithRetry(`${this.baseURL}/api/upload`, {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(this.getErrorMessage(error));
      }

      const result = await response.json();
      return { success: true, message: '문서 업로드 성공' };
    } catch (error) {
      console.error('Upload error:', error);
      throw new Error(this.getErrorMessage(error));
    }
  }

  /**
   * 문서 목록 조회
   */
  async getDocuments(): Promise<{ sources: string[] }> {
    try {
      const response = await this.fetchWithRetry(`${this.baseURL}/api/vectors`);

      if (!response.ok) {
        const error = await response.json();
        throw new Error(this.getErrorMessage(error));
      }

      return await response.json();
    } catch (error) {
      console.error('Get documents error:', error);
      throw new Error(this.getErrorMessage(error));
    }
  }

  /**
   * 문서 삭제
   */
  async deleteDocuments(sources: string[]): Promise<{ success: boolean }> {
    try {
      const response = await this.fetchWithRetry(`${this.baseURL}/api/delete`, {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ sources }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(this.getErrorMessage(error));
      }

      return { success: true };
    } catch (error) {
      console.error('Delete documents error:', error);
      throw new Error(this.getErrorMessage(error));
    }
  }

  /**
   * 헬스체크
   */
  async healthCheck(): Promise<{ status: string; services: any }> {
    try {
      const response = await this.fetchWithRetry(`${this.baseURL}/api/health`);

      if (!response.ok) {
        throw new Error('Health check failed');
      }

      return await response.json();
    } catch (error) {
      console.error('Health check error:', error);
      throw new Error(this.getErrorMessage(error));
    }
  }
}

// 싱글톤 인스턴스
export const apiClient = new APIClient();
```

### Step 2.4: 환경 변수 설정

**파일 위치**: `frontend/.env.local`

```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

### Step 2.5: 채팅 페이지 수정 (API 클라이언트 사용)

**파일 위치**: `frontend/app/chat/page.tsx`

핵심 수정사항:

```typescript
import { apiClient } from '@/lib/api';

// 기존 fetch 대신 apiClient 사용
const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault();
  if (!input.trim() || isLoading) return;

  const userMessage: Message = { role: "user", content: input };
  setMessages((prev) => [...prev, userMessage]);
  setInput("");
  setIsLoading(true);

  try {
    // ✅ API 클라이언트 사용
    const stream = await apiClient.queryStream(input, mode, 5);

    const reader = stream.getReader();
    const decoder = new TextDecoder();
    let assistantMessage = "";
    let sources: any[] = [];

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      const chunk = decoder.decode(value);
      const lines = chunk.split("\n").filter((line) => line.trim());

      for (const line of lines) {
        try {
          const event = JSON.parse(line);
          if (event.event === "token") {
            assistantMessage += event.text;
            setMessages((prev) => {
              const newMessages = [...prev];
              const lastMessage = newMessages[newMessages.length - 1];
              if (lastMessage && lastMessage.role === "assistant") {
                lastMessage.content = assistantMessage;
              } else {
                newMessages.push({
                  role: "assistant",
                  content: assistantMessage,
                  sources,
                });
              }
              return newMessages;
            });
          } else if (event.event === "sources") {
            sources = (event.items || []).map((item: any) => ({
              ...item,
              filename: item.filename || item.source?.split('\\').pop() || 'Unknown'
            }));
          }
        } catch (e) {
          // JSON 파싱 실패 무시
        }
      }
    }
  } catch (error: any) {
    console.error("Chat error:", error);
    setMessages((prev) => [
      ...prev,
      {
        role: "assistant",
        content: error.message || "죄송합니다. 오류가 발생했습니다.",
      },
    ]);
  } finally {
    setIsLoading(false);
  }
};
```

### Step 2.6: 에러 바운더리 추가

**파일 위치**: `frontend/app/error.tsx`

```typescript
'use client';

import { useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error('Application error:', error);
  }, [error]);

  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <Card className="max-w-md w-full">
        <CardHeader>
          <CardTitle className="text-red-500">오류가 발생했습니다</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <p className="text-sm text-muted-foreground">
            죄송합니다. 예상치 못한 오류가 발생했습니다.
          </p>
          {process.env.NODE_ENV === 'development' && (
            <pre className="text-xs bg-muted p-2 rounded overflow-auto">
              {error.message}
            </pre>
          )}
          <Button onClick={reset} className="w-full">
            다시 시도
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
```

### Step 2.7: 프론트엔드 테스트

```bash
cd frontend
npm run dev
```

**테스트 체크리스트**:
- [ ] http://localhost:3000 접속 가능
- [ ] 홈 페이지 정상 표시
- [ ] 채팅 페이지 이동 가능
- [ ] 대시보드 페이지 이동 가능
- [ ] UI에 에러 없음 (콘솔 확인)

---

## 🔷 Phase 3: 통합 테스트

### Step 3.1: 전체 시스템 시작

**터미널 1 (백엔드)**:
```bash
cd backend
python main.py
```

**터미널 2 (프론트엔드)**:
```bash
cd frontend
npm run dev
```

### Step 3.2: 기능 테스트

#### ✅ 채팅 기능 테스트

1. http://localhost:3000/chat 접속
2. 질문 입력: "안녕하세요"
3. 확인 사항:
   - [ ] 로딩 인디케이터 표시
   - [ ] 실시간 응답 표시
   - [ ] 에러 없이 완료
   - [ ] 참고 문서 표시 (RAG 모드인 경우)

#### ✅ 문서 업로드 테스트

1. http://localhost:3000/documents 접속
2. 파일 선택 (PDF, DOCX, TXT 등)
3. 업로드 클릭
4. 확인 사항:
   - [ ] 로딩 상태 표시
   - [ ] 성공 메시지 표시
   - [ ] 문서 목록에 추가됨
   - [ ] 에러 없이 완료

#### ✅ 대시보드 테스트

1. http://localhost:3000/dashboard 접속
2. 확인 사항:
   - [ ] 통계 카드 표시
   - [ ] 문서 수 정확히 표시
   - [ ] 에러 없이 로드

### Step 3.3: 에러 시나리오 테스트

#### 1. 백엔드 다운 시나리오

```bash
# 백엔드 중지
# Ctrl+C

# 프론트엔드에서 채팅 시도
# 예상: 사용자 친화적 에러 메시지 표시
```

#### 2. 타임아웃 시나리오

백엔드 main.py에서 임시로 딜레이 추가:

```python
@app.post("/api/query_stream")
async def query_stream(...):
    import time
    time.sleep(35)  # 35초 대기 (타임아웃 30초 초과)
    ...
```

확인 사항:
- [ ] 타임아웃 에러 메시지 표시
- [ ] UI 크래시 없음
- [ ] 재시도 옵션 제공

---

## 🔷 Phase 4: 최적화 및 배포

### Step 4.1: 프로덕션 빌드

```bash
# 프론트엔드
cd frontend
npm run build
npm start  # 프로덕션 서버 (Port 3000)

# 백엔드
cd backend
pip install gunicorn
gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app --bind 0.0.0.0:8000
```

### Step 4.2: 환경 변수 설정

**프로덕션 `.env.local`**:
```env
NEXT_PUBLIC_API_URL=https://api.yourdomain.com
```

### Step 4.3: Docker 배포 (선택사항)

**docker-compose.yml**:
```yaml
version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - QDRANT_LOCAL=1
      - OLLAMA_HOST=ollama
    volumes:
      - ./backend/data:/app/data
      - ./backend/qdrant_storage:/app/qdrant_storage
    depends_on:
      - ollama

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://backend:8000
    depends_on:
      - backend

  ollama:
    image: ollama/ollama:latest
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama

volumes:
  ollama_data:
```

---

## ✅ 최종 체크리스트

### 기능 체크리스트

- [ ] **채팅**: 질문 입력 → 실시간 응답
- [ ] **문서 업로드**: 파일 선택 → 업로드 → 목록 갱신
- [ ] **문서 삭제**: 문서 선택 → 삭제 → 목록 갱신
- [ ] **모드 전환**: RAG ↔ LLM 전환
- [ ] **대시보드**: 통계 표시
- [ ] **설정**: 모델 설정

### 안정성 체크리스트

- [ ] **UI 에러 제로**: 콘솔에 에러 없음
- [ ] **API 에러 핸들링**: 모든 API 호출에 try-catch
- [ ] **타임아웃 처리**: 30초 타임아웃 적용
- [ ] **재시도 로직**: 네트워크 에러 시 3회 재시도
- [ ] **에러 바운더리**: 전역 에러 핸들러 동작
- [ ] **로딩 상태**: 모든 비동기 작업에 로딩 표시

### 성능 체크리스트

- [ ] **응답 시간**: 평균 2초 이내
- [ ] **동시 사용자**: 10명 이상 테스트
- [ ] **파일 업로드**: 100MB 파일 처리 가능
- [ ] **스트리밍**: 부드러운 실시간 응답

---

## 🎯 다음 단계

1. **모니터링 설정**: Sentry, LogRocket 등
2. **분석 도구**: Google Analytics, Mixpanel
3. **A/B 테스트**: 기능 개선
4. **사용자 피드백**: 베타 테스트

---

**이 가이드를 따라 구현하면 안정적이고 오류 없는 SaaS를 만들 수 있습니다!** 🚀
**각 단계를 꼼꼼히 확인하며 진행하세요!** ✅
