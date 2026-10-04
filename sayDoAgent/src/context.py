from dataclasses import dataclass


@dataclass
class SayDoContext:
    user_id: str                       # Supabase auth.uid()
    timezone: str = "Africa/Algiers"   # from the user's profile
    current_datetime: str = ""         # ISO string sent by the app on each request
    preferred_language: str = "fr"     # language for confirmation messages