# ========================================
# DocuNova 시작 스크립트
# ========================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   DocuNova SaaS 시작 중..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 현재 경로 저장
$ProjectRoot = $PSScriptRoot

# 백엔드 경로
$BackendPath = Join-Path $ProjectRoot "backend"
$VenvPython = Join-Path $ProjectRoot "venv\Scripts\python.exe"

# 프론트엔드 경로
$FrontendPath = Join-Path $ProjectRoot "frontend"

# 1. Ollama 확인
Write-Host "[1/4] Ollama 서비스 확인 중..." -ForegroundColor Yellow
try {
    $OllamaTest = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 3 -ErrorAction SilentlyContinue
    Write-Host "  ✓ Ollama 실행 중 (모델: $($OllamaTest.models.Count)개)" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Ollama가 실행되지 않았습니다!" -ForegroundColor Red
    Write-Host "    먼저 Ollama를 시작하세요." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "계속하려면 Enter를 누르세요"
}

# 2. 백엔드 시작
Write-Host ""
Write-Host "[2/4] 백엔드 시작 중..." -ForegroundColor Yellow

if (-not (Test-Path $VenvPython)) {
    Write-Host "  ⚠ Python 가상환경을 찾을 수 없습니다!" -ForegroundColor Red
    Write-Host "    경로: $VenvPython" -ForegroundColor Gray
    exit 1
}

# 백엔드 프로세스 시작 (새 창)
$BackendScript = "cd '$BackendPath'; & '$VenvPython' main.py"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $BackendScript
Write-Host "  ✓ 백엔드 서버 시작됨 (Port 8000)" -ForegroundColor Green

# 백엔드 초기화 대기
Write-Host "  ⏳ 백엔드 초기화 대기 중 (15초)..." -ForegroundColor Gray
Start-Sleep -Seconds 15

# 3. 프론트엔드 시작
Write-Host ""
Write-Host "[3/4] 프론트엔드 시작 중..." -ForegroundColor Yellow

if (-not (Test-Path $FrontendPath)) {
    Write-Host "  ⚠ 프론트엔드 폴더를 찾을 수 없습니다!" -ForegroundColor Red
    Write-Host "    경로: $FrontendPath" -ForegroundColor Gray
    exit 1
}

# Lock 파일 제거
$LockFile = Join-Path $FrontendPath ".next\dev\lock"
if (Test-Path $LockFile) {
    Remove-Item $LockFile -Force
    Write-Host "  ✓ 이전 lock 파일 제거됨" -ForegroundColor Gray
}

# 프론트엔드 프로세스 시작 (새 창)
$FrontendScript = "cd '$FrontendPath'; npm run dev"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $FrontendScript
Write-Host "  ✓ 프론트엔드 서버 시작됨 (Port 3000 or 3001)" -ForegroundColor Green

# 4. 완료
Start-Sleep -Seconds 3
Write-Host ""
Write-Host "[4/4] 서비스 상태 확인 중..." -ForegroundColor Yellow

# 백엔드 헬스체크
try {
    $Health = Invoke-RestMethod -Uri "http://localhost:8000/health" -TimeoutSec 5
    if ($Health.status -eq "healthy") {
        Write-Host "  ✓ 백엔드: 정상 작동 중" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ 백엔드: 일부 서비스 오류" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ⚠ 백엔드: 아직 초기화 중..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   DocuNova가 시작되었습니다!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📍 접속 주소:" -ForegroundColor White
Write-Host "   프론트엔드:  http://localhost:3001" -ForegroundColor Cyan
Write-Host "   백엔드 API:  http://localhost:8000" -ForegroundColor Cyan
Write-Host "   API 문서:    http://localhost:8000/docs" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 팁:" -ForegroundColor White
Write-Host "   - 종료하려면 각 터미널 창에서 Ctrl+C를 누르세요" -ForegroundColor Gray
Write-Host "   - 문제가 있으면 STOP_DOCUNOVA.ps1을 실행하세요" -ForegroundColor Gray
Write-Host ""
Write-Host "이 창을 닫으셔도 됩니다. 서비스는 별도 창에서 실행됩니다." -ForegroundColor Yellow
Write-Host ""

# 5초 후 자동 종료
Start-Sleep -Seconds 5
