from langchain.agents.middleware import HumanInTheLoopMiddleware

confirmation_middleware = HumanInTheLoopMiddleware(
    interrupt_on={
        "create_event": {"allowed_decisions": ["approve", "edit", "reject"]},
        "create_task": {"allowed_decisions": ["approve", "edit", "reject"]},
        "ask_missing_info": False,  # asking a question never needs approval
                "create_email": {"allowed_decisions": ["approve", "edit", "reject"]},
    },
    description_prefix="SayDo understood:",
)

from langchain.agents.middleware import dynamic_prompt, ModelRequest


def build_prompt(base_prompt: str):
    @dynamic_prompt
    def _prompt(request: ModelRequest) -> str:
        ctx = request.runtime.context
        return (
            f"{base_prompt}\n\n"
            f"Current date and time: {ctx.current_datetime}\n"
            f"User timezone: {ctx.timezone}\n"
            f"Reply in this language: {ctx.preferred_language}"
        )
    return _prompt