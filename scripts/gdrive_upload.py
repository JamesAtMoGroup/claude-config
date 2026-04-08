#!/usr/bin/env python3
"""Upload a local folder to a Google Drive folder, preserving structure."""

import os, sys, json, mimetypes
from pathlib import Path
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

SCOPES = ["https://www.googleapis.com/auth/drive"]
TOKEN_PATH = Path.home() / ".claude" / "gdrive_token.json"
CLIENT_SECRET_PATH = Path.home() / ".claude" / "gdrive_client_secret.json"

def get_service():
    creds = None
    if TOKEN_PATH.exists():
        creds = Credentials.from_authorized_user_file(str(TOKEN_PATH), SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(str(CLIENT_SECRET_PATH), SCOPES)
            # Use redirect_uri that matches what's configured in GCP console
            flow.redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
            auth_url, _ = flow.authorization_url(prompt="consent")
            print("\n🔐 Open this URL in your browser to authorize:")
            print(f"\n  {auth_url}\n")
            import subprocess
            subprocess.run(["open", auth_url])
            code = input("Paste the authorization code here: ").strip()
            flow.fetch_token(code=code)
            creds = flow.credentials
        TOKEN_PATH.write_text(creds.to_json())
    return build("drive", "v3", credentials=creds)

def create_folder(service, name, parent_id):
    meta = {"name": name, "mimeType": "application/vnd.google-apps.folder", "parents": [parent_id]}
    f = service.files().create(body=meta, fields="id").execute()
    print(f"  📁 Created folder: {name} ({f['id']})")
    return f["id"]

def upload_file(service, local_path: Path, parent_id: str):
    mime = mimetypes.guess_type(str(local_path))[0] or "application/octet-stream"
    meta = {"name": local_path.name, "parents": [parent_id]}
    media = MediaFileUpload(str(local_path), mimetype=mime, resumable=True)
    f = service.files().create(body=meta, media_body=media, fields="id").execute()
    size_mb = local_path.stat().st_size / 1024 / 1024
    print(f"  ✅ {local_path.name} ({size_mb:.1f} MB)")
    return f["id"]

def upload_folder(service, local_dir: Path, drive_parent_id: str):
    folder_id = create_folder(service, local_dir.name, drive_parent_id)
    for item in sorted(local_dir.iterdir()):
        if item.is_dir():
            upload_folder(service, item, folder_id)
        elif item.is_file() and not item.name.startswith("."):
            upload_file(service, item, folder_id)
    return folder_id

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: gdrive_upload.py <drive_folder_id> <local_dir1> [local_dir2 ...]")
        sys.exit(1)

    drive_folder_id = sys.argv[1]
    local_dirs = [Path(p) for p in sys.argv[2:]]

    service = get_service()
    for d in local_dirs:
        if not d.exists():
            print(f"❌ Not found: {d}")
            continue
        print(f"\n🚀 Uploading: {d.name}")
        fid = upload_folder(service, d, drive_folder_id)
        print(f"  → Drive folder ID: {fid}")

    print("\n✅ All uploads complete.")
