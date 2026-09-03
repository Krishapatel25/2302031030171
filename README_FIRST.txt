TRUTHGUARD AI - FINAL FIXED VERSION

1. Extract this ZIP completely (right-click -> Extract All, don't run it
   straight from inside the zip).
2. Double-click START_TRUTHGUARD_WINDOWS.bat to START everything.
3. Wait until the browser opens by itself.
4. Use the website normally. You never need to open CMD or type anything.
5. Double-click STOP_TRUTHGUARD_WINDOWS.bat to STOP everything when done.

FIRST RUN:
The launcher installs Python and Node dependencies automatically. This may
take several minutes (mostly downloading PyTorch, ~200 MB) and requires
internet access. You will see a black window with progress messages -
that is normal, just wait for it.

IF SOMETHING GOES WRONG:
The launcher never expects you to type a command. If a step fails, it will
automatically open a Notepad window showing the exact error - just copy
everything in that Notepad window when asking for help.

SUPPORTED:
- Text/article URL -> RoBERTa fake-news classifier
- Direct image URL / image upload -> DeepGuard MS-EffGCViT
- Direct video URL / YouTube URL / video upload -> DeepGuard video pipeline
- Audio upload / direct audio URL -> audio classifier

IMPORTANT:
The media deepfake model is face-based. If an image/video contains no detectable face, the system returns NO FACE DETECTED instead of inventing REAL/FAKE.
A REAL result is an authenticity-model estimate, not proof that a news claim is factually true.
