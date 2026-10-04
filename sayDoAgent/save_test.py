import os, sys, requests
from datetime import datetime
from zoneinfo import ZoneInfo
from dotenv import load_dotenv

load_dotenv()
URL = os.environ["SUPABASE_URL"]
KEY = os.environ["SUPABASE_SECRET_KEY"]
H = {"apikey": KEY, "Authorization": f"Bearer {KEY}", "Content-Type": "application/json"}
TZ = "Africa/Algiers"

with open(sys.argv[1], "rb") as f:
    r = requests.post(
        "http://localhost:8000/saydo-parse",
        files={"audio": f},
        data={"timezone": TZ, "client_now": datetime.now(ZoneInfo(TZ)).isoformat()},
    ).json()
print("Agent:", r)
if r["status"] != "ok":
    sys.exit("Agent needs more info or failed, nothing saved.")

user_id = requests.get(f"{URL}/rest/v1/profiles?select=id&limit=1", headers=H).json()[0]["id"]

if r["type"] == "email":
    name = r["to_name"]
    found = requests.get(
        f"{URL}/rest/v1/contacts", headers=H,
        params={"user_id": f"eq.{user_id}", "name": f"ilike.{name}", "select": "email"},
    ).json()
    new_contact = not found
    if found:
        to_email = found[0]["email"]
        print(f"\nContact found: {name} <{to_email}>")
    else:
        to_email = input(f"\nEmail address of {name}: ").strip()

    print(f"\nTo: {name} <{to_email}>\nSubject: {r['subject']}\n\n{r['body']}\n")
    if input("Approve and send? (y/n): ").strip().lower() != "y":
        sys.exit("Rejected, nothing saved.")

    if new_contact:
        requests.post(f"{URL}/rest/v1/contacts", headers=H,
                      json={"user_id": user_id, "name": name, "email": to_email})

    table = "emails"
    row = {"user_id": user_id, "to_name": name, "to_email": to_email,
           "subject": r["subject"], "body": r["body"], "source_transcript": r["transcript"]}

elif r["type"] == "event":
    start = datetime.fromisoformat(f"{r['date']}T{r['time']}").replace(tzinfo=ZoneInfo(TZ))
    table = "events"
    row = {"user_id": user_id, "title": r["title"], "start_at": start.isoformat(),
           "timezone": TZ, "related_people": r["people"], "source_transcript": r["transcript"]}

else:
    due = datetime.fromisoformat(r["date"]).replace(tzinfo=ZoneInfo(TZ)).isoformat() if r["date"] else None
    table = "tasks"
    row = {"user_id": user_id, "title": r["title"], "due_at": due,
           "related_people": r["people"], "source_transcript": r["transcript"]}

res = requests.post(f"{URL}/rest/v1/{table}", json=row, headers=H)
print("Supabase:", res.status_code, res.text)