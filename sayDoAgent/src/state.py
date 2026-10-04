from typing import Literal, NotRequired

from langchain.agents import AgentState


class SayDoState(AgentState):
    # `messages` is already included by AgentState

    transcript: NotRequired[str]                          # what the user said
    intent: NotRequired[Literal["event", "task", "email"]]        # what the supervisor decided
    title: NotRequired[str]
    date: NotRequired[str]                                # ISO date, e.g. 2026-10-04
    time: NotRequired[str]                                # e.g. 17:00
    people: NotRequired[list[str]]
    missing_fields: NotRequired[list[str]]                # e.g. ["date"]; triggers a question to the user
    status: NotRequired[Literal["parsing", "needs_info", "awaiting_confirmation", "saved"]]