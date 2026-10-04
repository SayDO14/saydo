from langchain.agents import create_agent

from src.context import SayDoContext
from src.middleware import build_prompt, confirmation_middleware
from src.state import SayDoState
from src.tools import ask_missing_info, create_event

EVENT_PROMPT = """You turn a voice transcript into a calendar event.
The transcript may mix Algerian Darija, French and English.

Rules:
- Extract: title, date, time, people.
- Resolve relative dates ("tomorrow", "next Monday") using the current date.
- If the date or the time is missing, call ask_missing_info. NEVER guess.
- Only call create_event when title, date and time are all known.
"""

event_agent = create_agent(
    model="google_genai:gemini-3.5-flash-lite",
    tools=[create_event, ask_missing_info],
    state_schema=SayDoState,
    context_schema=SayDoContext,
    middleware=[build_prompt(EVENT_PROMPT), confirmation_middleware],
)