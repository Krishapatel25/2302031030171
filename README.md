# TruthGuard AI — One-Click Working Version

## Run the website (Windows)

1. Install **Python 3.10+** and **Node.js LTS** once.
2. Double-click **`START_TRUTHGUARD_WINDOWS.bat`**.
3. The launcher automatically creates the Python environment, installs missing packages, starts the AI backend, starts the frontend, and opens Chrome.
4. After the first setup, future launches are just **one double-click**.

You do **not** need to type `cd`, `venv`, `uvicorn`, `npm install`, or `npm run dev` manually.

## What is fixed

- URL fetching with redirects and browser-style headers
- Direct image/video/audio URL detection
- YouTube URL downloading and video analysis
- Normal HTML article extraction
- Article JSON-LD `articleBody` fallback
- Better paragraph/content fallback for pages without `<article>`
- Clear errors for JavaScript/login/blocked pages that cannot expose content
- Fake/real classification with confidence
- Fake vs real class scores
- Human-readable explanation of why the model chose the result
- Text, image, video and voice endpoints
- Vite proxy so the browser does not need direct CORS access to port 8000

## Important

The detector gives an **AI authenticity estimate**. A `LIKELY REAL` result means the configured model found patterns closer to its real/authentic class. It does not prove that every factual claim in a news article is true. A `LIKELY FAKE` result means the model found patterns closer to its fake/synthetic class.

## If a URL still cannot be fetched

Some websites are login-only, JavaScript-rendered, robots/anti-bot protected, or do not expose article text to automated clients. The application now reports this clearly instead of silently returning an incorrect result.
