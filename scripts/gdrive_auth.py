#!/usr/bin/env python3
"""One-time Google Drive OAuth — saves token to ~/.claude/gdrive_token.json"""
from pathlib import Path
from google_auth_oauthlib.flow import InstalledAppFlow

SCOPES = ["https://www.googleapis.com/auth/drive"]
TOKEN_PATH = Path.home() / ".claude" / "gdrive_token.json"
CLIENT_SECRET_PATH = Path.home() / ".claude" / "gdrive_client_secret.json"

flow = InstalledAppFlow.from_client_secrets_file(str(CLIENT_SECRET_PATH), SCOPES)
creds = flow.run_local_server(port=8080, open_browser=True)
TOKEN_PATH.write_text(creds.to_json())
print(f"✅ Token saved to {TOKEN_PATH}")
