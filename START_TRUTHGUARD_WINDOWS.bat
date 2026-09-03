@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
title TruthGuard AI - One Click

where npm >nul 2>&1 || (echo Node.js LTS is required. Install it once from nodejs.org. & pause & exit /b 1)

set "PY="
for %%V in (3.12 3.11 3.10) do (
  py -%%V -c "import sys" >nul 2>&1
  if not errorlevel 1 if not defined PY set "PY=py -%%V"
)
if not defined PY (
  python -c "import sys" >nul 2>&1
  if not errorlevel 1 set "PY=python"
)
if not defined PY (echo Python 3.10-3.12 is required. & pause & exit /b 1)

if not exist "backend\.venv\Scripts\python.exe" (
  echo [FIRST RUN] Creating AI environment...
  !PY! -m venv backend\.venv || goto FAIL
)

if not exist "backend\.venv\.truthguard_deps_ok" (
  echo [FIRST RUN] Installing AI packages. This can take several minutes...
  echo   ^(Downloading the CPU version of PyTorch, about 200 MB - please wait^)
  "backend\.venv\Scripts\python.exe" -m pip install --upgrade pip > backend\install.log 2>&1 || goto INSTALLFAIL
  REM Install a matched, CPU-only torch + torchvision pair explicitly.
  REM This is smaller and far more reliable than letting pip guess a pair
  REM while resolving deepguard's requirements.
  "backend\.venv\Scripts\python.exe" -m pip install torch==2.10.0 torchvision==0.25.0 --index-url https://download.pytorch.org/whl/cpu >> backend\install.log 2>&1 || goto INSTALLFAIL
  "backend\.venv\Scripts\python.exe" -m pip install -r backend\requirements.txt >> backend\install.log 2>&1 || goto INSTALLFAIL
  type nul > "backend\.venv\.truthguard_deps_ok"
)

if not exist "node_modules" (
  echo [FIRST RUN] Installing website packages...
  call npm install > npm-install.log 2>&1 || goto NPMFAIL
)

REM Stop only old TruthGuard processes started on our ports.
powershell -NoProfile -Command "$p=Get-NetTCPConnection -LocalPort 8000,5173 -State Listen -ErrorAction SilentlyContinue | Select-Object -Expand OwningProcess -Unique; foreach($x in $p){try{Stop-Process -Id $x -Force -ErrorAction SilentlyContinue}catch{}}" >nul 2>&1

if exist "backend\backend.log" del /q "backend\backend.log" >nul 2>&1

echo [1/2] Starting AI backend...
start "TruthGuard Backend" /min cmd /c "cd /d "%~dp0backend" && .venv\Scripts\python.exe run.py >> backend.log 2>&1"

set READY=0
for /l %%N in (1,1,120) do (
  powershell -NoProfile -Command "try{$r=Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:8000/health' -TimeoutSec 1;if($r.StatusCode -eq 200){exit 0}else{exit 1}}catch{exit 1}" >nul 2>&1
  if not errorlevel 1 (set READY=1 & goto BACKEND_OK)
  timeout /t 1 /nobreak >nul
)

:BACKEND_OK
if "%READY%"=="0" (
  echo.
  echo ========================================================
  echo THE AI BACKEND DID NOT START.
  echo A Notepad window is opening with the exact error below.
  echo Please copy everything in that Notepad window and send
  echo it back - you do NOT need to type any commands.
  echo ========================================================
  echo.
  start "" notepad "backend\backend.log"
  pause
  exit /b 1
)

echo [OK] AI backend ready.
echo [2/2] Starting website...
start "TruthGuard Frontend" /min cmd /c "cd /d "%~dp0" && npm run dev -- --host 127.0.0.1"

for /l %%N in (1,1,30) do (
  powershell -NoProfile -Command "try{$r=Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:5173' -TimeoutSec 1;if($r.StatusCode -ge 200){exit 0}else{exit 1}}catch{exit 1}" >nul 2>&1
  if not errorlevel 1 goto FRONTEND_OK
  timeout /t 1 /nobreak >nul
)

echo Website did not start. See npm-install.log or the frontend window.
pause
exit /b 1

:FRONTEND_OK
start "" "http://localhost:5173"
echo.
echo ========================================================
echo TruthGuard AI is READY.
echo No manual backend commands are required.
echo Close this launcher only after you are finished.
echo ========================================================
timeout /t 5 >nul
exit /b 0

:INSTALLFAIL
echo.
echo Backend package installation failed.
echo A Notepad window is opening with the exact error - please
echo copy everything in it and send it back. No commands needed.
start "" notepad "backend\install.log"
pause
exit /b 1
:NPMFAIL
echo.
echo Frontend package installation failed.
echo A Notepad window is opening with the exact error - please
echo copy everything in it and send it back. No commands needed.
start "" notepad "npm-install.log"
pause
exit /b 1
:FAIL
echo.
echo Python environment creation failed. Make sure Python 3.10-3.12
echo is installed from python.org (check "Add to PATH" during install),
echo then double-click this file again.
pause
exit /b 1
