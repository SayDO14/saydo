from google import genai
from google.genai import types

client = genai.Client()  # reads GOOGLE_API_KEY from .env

STT_PROMPT = """Transcribe this audio exactly as spoken.
The speaker may mix Algerian Darija, French and English in the same sentence.
Do not translate. Do not summarize. Keep each word in the language it was spoken in.
Return only the transcript."""

MIME_TYPES = {
    ".mp3": "audio/mpeg",
    ".wav": "audio/wav",
    ".m4a": "audio/mp4",
    ".ogg": "audio/ogg",
    ".aac": "audio/aac",
}


def transcribe(path: str) -> str:
    ext = "." + path.rsplit(".", 1)[-1].lower()
    with open(path, "rb") as f:
        audio = f.read()
    response = client.models.generate_content(
        model="gemini-3.5-flash-lite",
        contents=[
            types.Part.from_bytes(data=audio, mime_type=MIME_TYPES[ext]),
            STT_PROMPT,
        ],
    )
    return response.text.strip()