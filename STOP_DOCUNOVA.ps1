# ========================================
# DocuNova 종료 스크립트
# ========================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   DocuNova 종료 중..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Port 8000 (백엔드) 종료
Write-Host "[1/2] 백엔드 종료 중 (Port 8000)..." -ForegroundColor Yellow
try {
    $BackendProcess = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue |
                      Select-Object -ExpandProperty OwningProcess -Unique

    if ($BackendProcess) {
        Stop-Process -Id $BackendProcess -Force -ErrorAction SilentlyContinue
        Write-Host "  ✓ 백엔드 프로세스 종료됨 (PID: $BackendProcess)" -ForegroundColor Green
    } else {
        Write-Host "  ℹ 실행 중인 백엔드를 찾을 수 없습니다" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ⚠ 백엔드 종료 중 오류: $($_.Exception.Message)" -ForegroundColor Yellow
}

Start-Sleep -Seconds 1

# Port 3000/3001 (프론트엔드) 종료
Write-Host ""
Write-Host "[2/2] 프론트엔드 종료 중 (Port 3000, 3001)..." -ForegroundColor Yellow

foreach ($port in @(3000, 3001)) {
    try {
        $FrontendProcess = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue |
                           Select-Object -ExpandProperty OwningProcess -Unique

        if ($FrontendProcess) {
            Stop-Process -Id $FrontendProcess -Force -ErrorAction SilentlyContinue
            Write-Host "  ✓ 프론트엔드 프로세스 종료됨 (Port $port, PID: $FrontendProcess)" -ForegroundColor Green
        }
    } catch {
        # 포트가 사용 중이 아니면 무시
    }
}

if (-not $FrontendProcess) {
    Write-Host "  ℹ 실행 중인 프론트엔드를 찾을 수 없습니다" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   DocuNova가 종료되었습니다!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Start-Sleep -Seconds 2
