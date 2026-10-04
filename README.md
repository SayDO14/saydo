# SayDo

Voice-first AI assistant that understands Algerian Darija, French and English,
even when a sentence switches language. Speak once: SayDo turns your voice into a
calendar event, a task, or an email draft, and nothing is created until you confirm.

## How it works

```
Flutter app (voice + confirmation card)
        │ audio
        ▼
Python agent (FastAPI + LangGraph)
  speech-to-text (Gemini) → supervisor → event / task / email agent
        │ proposal (JSON)
        ▼
User confirms or edits in the app
        │ insert
        ▼
Supabase (Postgres, Google OAuth, RLS)
        │ database webhook
        ▼
n8n workflow
  events → Google Calendar | tasks → Google Tasks | emails → Gmail
```

## Repository

| Folder | Content |
|---|---|
| `app/` | Flutter mobile app |
| `agent/` | Python AI agent (speech-to-text, intent routing, human-in-the-loop) |
| `n8n/` | Importable n8n workflow (sync to Google Calendar, Tasks and Gmail) |
| `supabase/migrations/` | SQL for tables, triggers and permissions |
| `docs/` | Architecture and pitch |

## Run it

**1. Supabase:** run the SQL files in `supabase/migrations/` in order.

**2. Agent**
```bash
cd agent
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env                                  # then fill in the values
uvicorn src.api:app --reload
```
Open http://localhost:8000/docs to try `POST /saydo-parse` with a voice file.

**3. n8n:** import `n8n/saydo_sync_workflow.json`, connect Google Calendar,
Google Tasks, Gmail and Supabase credentials, then add three Supabase database
webhooks (INSERT on `events`, `tasks`, `emails`) pointing to the workflow URL.

**4. App**
```bash
cd app
flutter pub get
flutter run
```

## Stack

Flutter · Python · FastAPI · LangChain / LangGraph · Gemini · Supabase · n8n

## Team

Khadidja Bourzama 