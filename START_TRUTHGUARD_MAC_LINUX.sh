#!/usr/bin/env bash
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

PY=python3
command -v "$PY" >/dev/null 2>&1 || { echo "Python 3.10-3.12 is required. Install it from python.org."; read -p "Press Enter to close..."; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "Node.js LTS is required. Install it from nodejs.org."; read -p "Press Enter to close..."; exit 1; }

if [ ! -f "backend/.venv/bin/python" ]; then
  echo "[FIRST RUN] Creating AI environment..."
  "$PY" -m venv backend/.venv
fi

if [ ! -f "backend/.venv/.truthguard_deps_ok" ]; then
  echo "[FIRST RUN] Installing AI packages. This can take several minutes..."
  echo "(Downloading the CPU version of PyTorch, about 200 MB - please wait)"
  backend/.venv/bin/python -m pip install --upgrade pip > backend/install.log 2>&1
  # Matched, CPU-only torch + torchvision pair, installed explicitly so pip
  # does not silently pick a mismatched pair while resolving deepguard.
  backend/.venv/bin/python -m pip install torch==2.10.0 torchvision==0.25.0 --index-url https://download.pytorch.org/whl/cpu >> backend/install.log 2>&1
  backend/.venv/bin/python -m pip install -r backend/requirements.txt >> backend/install.log 2>&1
  touch backend/.venv/.truthguard_deps_ok
fi

# Stop any old TruthGuard processes still holding our ports.
lsof -ti :8000 -ti :5173 2>/dev/null | xargs -r kill -9 2>/dev/null || true

echo "[1/2] Starting AI backend..."
( cd backend && .venv/bin/python run.py > backend.log 2>&1 ) &
BACKEND_PID=$!
trap 'kill $BACKEND_PID 2>/dev/null || true' EXIT

READY=0
for i in $(seq 1 120); do
  if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8000/health 2>/dev/null | grep -q 200; then
    READY=1
    break
  fi
  sleep 1
done

if [ "$READY" != "1" ]; then
  echo ""
  echo "========================================================"
  echo "THE AI BACKEND DID NOT START."
  echo "Exact error is below (also saved in backend/backend.log):"
  echo "========================================================"
  cat backend/backend.log 2>/dev/null
  read -p "Press Enter to close..."
  exit 1
fi

echo "[OK] AI backend ready."

if [ ! -d "node_modules" ]; then
  echo "[FIRST RUN] Installing website packages..."
  npm install > npm-install.log 2>&1
fi

echo "[2/2] Starting website..."
(npm run dev -- --host 127.0.0.1) &
FRONTEND_PID=$!
trap 'kill $BACKEND_PID $FRONTEND_PID 2>/dev/null || true' EXIT

sleep 3
if command -v open >/dev/null 2>&1; then open "http://localhost:5173"; fi
if command -v xdg-open >/dev/null 2>&1; then xdg-open "http://localhost:5173"; fi

echo ""
echo "========================================================"
echo "TruthGuard AI is READY at http://localhost:5173"
echo "Keep this window open. Press Ctrl+C here to stop everything."
echo "========================================================"
wait
