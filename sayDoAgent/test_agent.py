import sys
import io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

from dotenv import load_dotenv

load_dotenv()

from langgraph.types import Command

from src.context import SayDoContext
from src.supervisor import graph

context = SayDoContext(
    user_id="test-user",
    timezone="Africa/Algiers",
    current_datetime="2026-10-03T10:00:00+01:00",  # Saturday
    preferred_language="fr",
)


def run(transcript: str, thread_id: str):
    config = {"configurable": {"thread_id": thread_id}}
    result = graph.invoke(
        {"messages": [{"role": "user", "content": transcript}]},
        config=config,
        context=context,
    )
    print(f"\n=== {transcript}")
    if "__interrupt__" in result:
        print("PAUSED for confirmation:")
        print(result["__interrupt__"][0].value)
    else:
        print("Agent says:", result["messages"][-1].content)
    return config


# 1. Complete event -> should PAUSE with title, date, time
config = run("rappelle moi réunion avec Maya demain à 17h", "t1")

# 2. Missing date -> should ASK a question, not guess
run("نحب نزيد rendez-vous chez le dentiste à 10h", "t2")

# 3. Task -> should PAUSE with a task, no time asked
run("remind me to buy milk", "t3")

# 4. Approve test 1 -> the tool should run and return the proposal
result = graph.invoke(
    Command(resume={"decisions": [{"type": "approve"}]}),
    config=config,
    context=context,
)
print("\n=== After approve:")
print(result["messages"][-1].content)