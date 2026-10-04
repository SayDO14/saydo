from typing import Literal

from langchain.chat_models import init_chat_model
from langgraph.checkpoint.memory import InMemorySaver
from langgraph.graph import END, START, StateGraph
from pydantic import BaseModel

from src.context import SayDoContext
from src.event_agent import event_agent
from src.state import SayDoState
from src.task_agent import task_agent
from src.email_agent import email_agent

class Route(BaseModel):
    intent: Literal["event", "task", "email"]


ROUTER_PROMPT = """Classify the user's voice transcript.
The transcript may mix Algerian Darija, French and English.

- "event": something happening at a specific moment (meeting, appointment, call, birthday).
- "task": something to do, with no fixed time (buy, send, finish, remember to...).
- "email": the user asks SayDo to write or send an email or message to someone now. "Remind me to email X" is a "task".
"""

router_model = init_chat_model("google_genai:gemini-3.5-flash-lite").with_structured_output(Route)


def classify(state: SayDoState) -> dict:
    transcript = state["messages"][-1].content
    result = router_model.invoke([("system", ROUTER_PROMPT), ("user", transcript)])
    return {"intent": result.intent, "transcript": transcript, "status": "parsing"}


def route(state: SayDoState) -> str:
    return state["intent"]


builder = StateGraph(SayDoState, context_schema=SayDoContext)
builder.add_node("classify", classify)
builder.add_node("event_agent", event_agent)
builder.add_node("task_agent", task_agent)
builder.add_node("email_agent", email_agent)

builder.add_edge(START, "classify")
builder.add_conditional_edges(
    "classify", route,
    {"event": "event_agent", "task": "task_agent", "email": "email_agent"},
)
builder.add_edge("event_agent", END)
builder.add_edge("task_agent", END)
builder.add_edge("email_agent", END)

graph = builder.compile(checkpointer=InMemorySaver())