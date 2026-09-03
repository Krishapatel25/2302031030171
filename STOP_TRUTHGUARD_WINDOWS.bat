@echo off
title TruthGuard AI - Stop
echo Stopping TruthGuard AI (backend + website)...

powershell -NoProfile -Command "$p=Get-NetTCPConnection -LocalPort 8000,5173 -State Listen -ErrorAction SilentlyContinue | Select-Object -Expand OwningProcess -Unique; foreach($x in $p){try{Stop-Process -Id $x -Force -ErrorAction SilentlyContinue}catch{}}" >nul 2>&1

echo.
echo Done. Both the AI backend and the website have been stopped.
echo You can close this window now.
pause
exit /b 0
