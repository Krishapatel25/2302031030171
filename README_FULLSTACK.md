# TruthGuard AI — Full Stack v4

## 1. Start backend

```bash
cd backend
python -m venv .venv
```

Windows:
```bash
.venv\Scripts\activate
```

macOS/Linux:
```bash
source .venv/bin/activate
```

```bash
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

The first model request can take time because Hugging Face downloads and initializes the model.

## 2. Start frontend

Open a second terminal:

```bash
npm install
npm run dev
```

Frontend uses `http://localhost:8000` by default. To override it:

```bash
# .env
VITE_API_URL=http://localhost:8000
```

## 3. Architecture

Browser → React/Vite → FastAPI → Hugging Face Transformers/PyTorch → JSON result → React result card. URL scans now route media URLs to the matching image/video/voice detector instead of incorrectly sending video captions to the fake-news model.

## 4. Model choices

Text uses a RoBERTa fake-news classifier.
Image/video use the MS-EffGCViT deepfake detector.
Voice uses a Wav2Vec2-based deepfake audio classifier.

## 5. Production roadmap

1. URL/media routing: YouTube/direct media URLs are analyzed with the correct modality; normal webpages use the text model.
2. Multiple image/video forensic models + calibration.
3. Audio ensemble + codec/noise robustness.
4. Authentication and database.
5. Rate limiting and file scanning.
6. Background jobs for long videos.
7. Evaluation on a held-out dataset representative of the target users.


## Fixed URL scanning and explanations

- URL scanner now uses a browser-like User-Agent and follows redirects.
- Article extraction prefers `<article>`, `<main>` and `articleBody` content.
- Pages that expose too little readable text return a clear explanation instead of silently failing.
- Every model result includes a human-readable "Why this result?" section and, when available, fake/real class scores.
- "LIKELY REAL" means the authenticity model found patterns closer to its real class; it is **not** a factual guarantee.
- "LIKELY FAKE" means the authenticity model found patterns closer to its fake/synthetic class; it is **not** proof of deception.
