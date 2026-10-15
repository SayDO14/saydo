# SayDo

**Speak the way you actually talk. SayDo turns it into a calendar event, a task, or an email draft.**

SayDo is a voice-first AI assistant that understands Algerian Darija, French and English, even when a single sentence switches between them. Tap a button, say what you need, and SayDo shows you what it understood. Nothing is created until you confirm.

> Demo: _add your demo link or video here_
> Landing page: _add your landing page link here_

---

## The problem

Millions of Algerians speak Darija and switch between Arabic, French and English mid-sentence. Voice assistants break on exactly that, so people end up typing their reminders and copying dates by hand.

## The solution

1. **Speak.** Press a button and talk naturally, in any mix of Darija, French and English.
2. **Understand.** SayDo extracts the intent, date, time and people involved.
3. **Confirm.** A confirmation card shows what SayDo understood. If something is missing, like the date, it asks instead of guessing.
4. **Done.** After you confirm, the event goes to Google Calendar, the task to Google Tasks, and the email draft to Gmail once you approve it.

The app itself is available in Arabic, French and English.

## Key features

- Mixed-language voice input (Darija, French, English)
- Three actions from one voice command: calendar events, tasks, emails
- Human-in-the-loop: nothing is created without your confirmation
- Asks for missing details instead of guessing
- Editable email drafts, sent only after approval
- Google sign-in, with each user's data isolated by row-level security
- Fully localized interface (Arabic, French, English)

## Architecture

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

## Repository structure

| Folder | Content |
| --- | --- |
| `saydo/` | Flutter mobile app |
| `sayDoAgent/` | Python AI agent (speech-to-text, intent routing, human-in-the-loop) |
| `n8n/` | Importable n8n workflow (sync to Google Calendar, Tasks and Gmail) |
| `supabase/migrations/` | SQL for tables, triggers and permissions |
| `landing_page/` | Project landing page |

## Tech stack

| Layer | Tools |
| --- | --- |
| Mobile app | Dart, Flutter |
| AI agent | Python, FastAPI, LangChain, LangGraph, Gemini |
| Backend | Supabase (PostgreSQL, Auth with Google OAuth, RLS) |
| Automation | n8n, Google Calendar API, Google Tasks API, Gmail API |

## Getting started

### Prerequisites

- Flutter SDK
- Python 3.10+
- A Supabase project
- An n8n instance
- A Gemini API key (Google AI Studio)

### 1. Supabase

Run the SQL files in `supabase/migrations/` in order. Then enable Google as an auth provider in your Supabase project.

### 2. AI agent

```bash
cd sayDoAgent
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env             # then fill in your keys
uvicorn src.api:app --reload
```

Open <http://localhost:8000/docs> and try `POST /saydo-parse` with a voice file.

### 3. n8n

1. Import the workflow JSON from `n8n/`.
2. Connect your Google Calendar, Google Tasks, Gmail and Supabase credentials.
3. In Supabase, add three database webhooks (INSERT on `events`, `tasks`, `emails`) pointing to the workflow URL.

### 4. Flutter app

```bash
cd saydo
flutter pub get
flutter run
```

Set your Supabase URL, anon key and agent URL in the app configuration before running.

## Team

| Name | Role |
| --- | --- |
| Khadidja Bourzama | Flutter app, AI agent, n8n workflows , supabase backend |
| Hiba | Flutter app, AI , supabase|
| May | Flutter app, AI , supabase |

All team members are native Darija speakers from Algeria.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
