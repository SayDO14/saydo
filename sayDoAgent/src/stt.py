"""Single-shot STT + structured extraction in one Gemini call.

Instead of:  audio → text → classify → extract  (3 API calls + LangGraph)
We now do:   audio → structured JSON             (1 API call, no LangGraph)
"""

import json
import time
from google import genai
from google.genai import types

client = genai.Client()  # reads GOOGLE_API_KEY from .env

MIME_TYPES = {
    ".mp3": "audio/mpeg",
    ".wav": "audio/wav",
    ".m4a": "audio/mp4",
    ".ogg": "audio/ogg",
    ".aac": "audio/aac",
}

PARSE_PROMPT = """You are SayDo, a voice-first AI assistant.

The user may speak in Algerian Darija, French, English, or a mix.

Listen to the audio and return ONLY a JSON object with these fields:
{
  "transcript": "<exact words spoken>",
  "type": "event" | "task" | "email",
  "title": "<event/task title or email subject>",
  "date": "<YYYY-MM-DD or null>",
  "time": "<HH:MM or null>",
  "people": ["<name1>"],
  "to_name": "<recipient name for emails, else null>",
  "to_email": "<recipient email if mentioned, else null>",
  "subject": "<email subject or null>",
  "body": "<email body or null>",
  "missing_fields": ["date", "time"],
  "question": "<ask if critical info missing, else null>"
}

Rules:
- type = "event" → happens at a fixed time (meeting, appointment, birthday)
- type = "task"  → something to do (buy, send, finish, remember...)
- type = "email" → user asks to write/send an email NOW
- Return ONLY the JSON, no markdown, no explanation.
"""

STT_PROMPT = """Transcribe this audio exactly as spoken.
The speaker may mix Algerian Darija, French and English in the same sentence.
Do not translate. Do not summarize. Keep each word in the language it was spoken in.
Return only the transcript."""

MODELS = ["gemini-3.5-flash", "gemini-3.7-flash", "gemini-3.8-flash", "gemini-flash-latest"]


def parse_audio(path: str, current_datetime: str = "", timezone: str = "Africa/Algiers") -> dict:
    """Transcribe + parse audio in a single Gemini call. Returns structured dict."""
    ext = "." + path.rsplit(".", 1)[-1].lower()
    with open(path, "rb") as f:
        audio_bytes = f.read()

    prompt = PARSE_PROMPT
    if current_datetime:
        prompt += f"\n\nCurrent date/time: {current_datetime} ({timezone})"

        last_error = None
    for round_num in range(3):  # go through the whole model list up to 3 times
        for model_name in MODELS:
            try:
                print(f"[single-shot] Round {round_num+1} - calling {model_name}...")
                response = client.models.generate_content(
                    model=model_name,
                    contents=[
                        types.Part.from_bytes(data=audio_bytes, mime_type=MIME_TYPES[ext]),
                        prompt,
                    ],
                )
                raw = response.text.strip()
                # Strip markdown code fences if present
                if raw.startswith("```"):
                    lines = raw.split("\n")
                    raw = "\n".join(lines[1:-1] if lines[-1] == "```" else lines[1:])
                return json.loads(raw.strip())
            except Exception as e:
                last_error = e
                err = str(e)
                print(f"[{model_name}] failed: {err[:150]}")
                time.sleep(0.5)
                continue  # try the next model

        # All models failed this round: wait before starting the next round
        if round_num < 2:
            wait = 2 * (round_num + 1)  # 2s, then 4s
            print(f"[single-shot] All models failed, retrying in {wait}s...")
            time.sleep(wait)

    raise last_error

def transcribe(path: str) -> str:
    """Fallback: transcription only."""
    ext = "." + path.rsplit(".", 1)[-1].lower()
    with open(path, "rb") as f:
        audio_bytes = f.read()

    for attempt in range(3):
        try:
            response = client.models.generate_content(
                model=MODEL,
                contents=[
                    types.Part.from_bytes(data=audio_bytes, mime_type=MIME_TYPES[ext]),
                    STT_PROMPT,
                ],
            )
            return response.text.strip()
        except Exception as e:
            err = str(e)
            if ("503" in err or "overload" in err.lower()) and attempt < 2:
                time.sleep(2 ** attempt)
                continue
            raise
