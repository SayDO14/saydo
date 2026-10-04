"""FastAPI wrapper around the LangGraph SayDo agent.
Accepts audio files, transcribes with Gemini, then runs the agent.
"""

import os
import tempfile
import traceback
from datetime import datetime

from dotenv import load_dotenv
from fastapi import FastAPI, UploadFile, Form, Header
from fastapi.responses import JSONResponse

load_dotenv()

from src.context import SayDoContext
from src.stt import transcribe
from src.supervisor import graph

app = FastAPI(title="SayDo Agent", version="0.1.0")


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


def message_text(content) -> str:
    """Gemini sometimes returns a list of parts instead of a string."""
    if isinstance(content, list):
        return " ".join(
            part.get("text", "") if isinstance(part, dict) else str(part)
            for part in content
        ).strip()
    return str(content).strip()


@app.post("/saydo-parse")
async def parse_voice(
    audio: UploadFile,
    timezone: str = Form("Africa/Algiers"),
    client_now: str = Form(None),
    previous: str | None = Form(None),
    authorization: str | None = Header(None),
):
    """
    Receive audio file from Flutter, transcribe, extract structured data.

    Args:
        audio: Voice file (.mp3, .wav, .m4a, .aac)
        timezone: User's timezone
        client_now: Current time from phone (ISO 8601)
        previous: Optional previous partial JSON (for follow-up answers)
        authorization: Bearer token (Supabase JWT), to be verified later
    """
    if client_now is None:
        client_now = datetime.now().isoformat()

    # Save uploaded audio to a temp file
    suffix = os.path.splitext(audio.filename or "audio.mp3")[1]
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        tmp.write(await audio.read())
        audio_path = tmp.name

    try:
        # Step 1: speech-to-text
        print(f"Transcribing {audio.filename}...")
        transcript = transcribe(audio_path)
        print(f"Transcript: {transcript}")

        # Step 2: run the LangGraph agent
        context = SayDoContext(
            user_id="test-user",  # TODO: extract from JWT
            timezone=timezone,
            current_datetime=client_now,
            preferred_language="fr",
        )
        config = {"configurable": {"thread_id": f"voice_{datetime.now().timestamp()}"}}

        result = graph.invoke(
            {"messages": [{"role": "user", "content": transcript}]},
            config=config,
            context=context,
        )

        # Step 3: build the response
        if "__interrupt__" in result:
            # The agent paused: an event or task is ready for confirmation
            interrupt_data = result["__interrupt__"][0].value
            action_requests = interrupt_data.get("action_requests", [])

            if action_requests:
                request = action_requests[0]
                args = request.get("args", {})
                response = empty_response("ok", transcript)
                response.update({
                    "type": request.get("name", "").replace("create_", ""),
                    "title": args.get("title"),
                    "date": args.get("date") or args.get("due_date"),
                    "time": args.get("time"),
                    "people": args.get("people", []),
                    "to_name": args.get("to_name"),
                    "subject": args.get("subject"),
                    "body": args.get("body"),
                })
                return JSONResponse(response)

        # No pause: the agent asked a question (missing info)
        messages = result.get("messages", [])
        question = message_text(messages[-1].content) if messages else "?"
        return JSONResponse(empty_response("needs_info", transcript, question))

    except Exception as e:
        print(f"Error: {e}")
        traceback.print_exc()
        return JSONResponse(empty_response("error"), status_code=500)
    finally:
        os.unlink(audio_path)


@app.get("/health")
async def health():
    return {"status": "ok", "stt": "gemini"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)