"""FastAPI wrapper — single-shot audio parsing (STT + extraction in 1 Gemini call).
No LangGraph imports at startup → starts instantly.
"""

import os
import tempfile
import traceback
from datetime import datetime

from dotenv import load_dotenv
from fastapi import FastAPI, UploadFile, Form, Header
from fastapi.responses import JSONResponse

load_dotenv()

app = FastAPI(title="SayDo Agent", version="0.2.0")


def empty_response(status: str, transcript: str = "", question: str | None = None) -> dict:
    return {
        "status": status,
        "transcript": transcript,
        "type": None,
        "title": None,
        "date": None,
        "time": None,
        "people": [],
        "missing_fields": [],
        "question": question,
        "to_name": None,
        "to_email": None,
        "subject": None,
        "body": None,
    }


@app.post("/saydo-parse")
async def parse_voice(
    audio: UploadFile,
    timezone: str = Form("Africa/Algiers"),
    client_now: str = Form(None),
    previous: str | None = Form(None),
    authorization: str | None = Header(None),
):
    """
    Receive audio file from Flutter.
    Single Gemini call: STT + intent classification + field extraction.
    No LangGraph — starts instantly, ~3x faster than the previous pipeline.
    """
    if client_now is None:
        client_now = datetime.now().isoformat()

    suffix = os.path.splitext(audio.filename or "audio.m4a")[1] or ".m4a"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        tmp.write(await audio.read())
        audio_path = tmp.name

    try:
        from src.stt import parse_audio

        print(f"[single-shot] Parsing {audio.filename}...")
        parsed = parse_audio(audio_path, current_datetime=client_now, timezone=timezone)
        try:
            import json
            print(f"[result] {json.dumps(parsed, ensure_ascii=True)}")
        except Exception:
            pass

        transcript = parsed.get("transcript", "")
        intent_type = parsed.get("type")

        if intent_type and parsed.get("title"):
            response = empty_response("ok", transcript)
            response.update({
                "type": intent_type,
                "title": parsed.get("title"),
                "date": parsed.get("date"),
                "time": parsed.get("time"),
                "people": parsed.get("people", []),
                "missing_fields": parsed.get("missing_fields", []),
                "question": parsed.get("question"),
                "to_name": parsed.get("to_name"),
                "to_email": parsed.get("to_email"),
                "subject": parsed.get("subject"),
                "body": parsed.get("body"),
            })
            return JSONResponse(response)

        question = parsed.get("question") or "Je n'ai pas bien compris. Pouvez-vous répéter ?"
        return JSONResponse(empty_response("needs_info", transcript, question))

    except Exception as e:
        print(f"[error] {e}")
        traceback.print_exc()
        return JSONResponse(empty_response("error"), status_code=500)
    finally:
        os.unlink(audio_path)


@app.get("/health")
async def health():
    return {"status": "ok", "mode": "single-shot", "model": "gemini-3.8-flash"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
