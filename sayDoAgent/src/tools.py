from langchain.tools import tool, ToolRuntime

from src.context import SayDoContext


@tool
def create_event(
    title: str,
    date: str,
    time: str,
    runtime: ToolRuntime[SayDoContext],
    people: list[str] | None = None,
) -> dict:
    """Propose a calendar event. Only call this when title, date and time are all known.

    Args:
        title: Short event title.
        date: ISO date, e.g. 2026-10-04.
        time: 24h time, e.g. 17:00.
        people: Names of people involved, if any.
    """
    return {
        "type": "event",
        "title": title,
        "date": date,
        "time": time,
        "people": people or [],
        "timezone": runtime.context.timezone,
        "user_id": runtime.context.user_id,
    }


@tool
def create_task(
    title: str,
    runtime: ToolRuntime[SayDoContext],
    due_date: str | None = None,
) -> dict:
    """Propose a task (a to-do without a fixed time).

    Args:
        title: Short task title.
        due_date: ISO date if the user gave a deadline, otherwise leave empty.
    """
    return {
        "type": "task",
        "title": title,
        "due_date": due_date,
        "user_id": runtime.context.user_id,
    }


@tool
def ask_missing_info(missing_fields: list[str], question: str) -> dict:
    """Ask the user for information that is missing. NEVER guess a missing date or time.

    Args:
        missing_fields: What is missing, e.g. ["date"] or ["date", "time"].
        question: One short question for the user, in their language.
    """
    return {
        "type": "question",
        "missing_fields": missing_fields,
        "question": question,
    }


@tool
def create_email(
    to_name: str,
    subject: str,
    body: str,
    runtime: ToolRuntime[SayDoContext],
) -> dict:
    """Propose an email draft. The user must approve it before it is sent.

    Args:
        to_name: Name of the recipient, as spoken (e.g. "Sarah").
        subject: Short email subject.
        body: Full email text, ready to send.
    """
    return {
        "type": "email",
        "to_name": to_name,
        "subject": subject,
        "body": body,
        "user_id": runtime.context.user_id,
    }