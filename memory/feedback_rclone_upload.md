---
name: rclone upload must use subfolder path
description: rclone upload to Google Drive must use "gdrive:$DATE" not "gdrive:" — files must be inside a dated subfolder
type: feedback
---

Always upload to `gdrive:$DATE` (creates a subfolder), never to `gdrive:` (dumps files at root).

**Why:** Files uploaded to `gdrive:` land at the root of the Drive folder with no organization. James expects each episode in its own `YYYY-MM-DD/` subfolder, consistent with all previous episodes.

**How to apply:** In any rclone upload for article-video, the destination must always be `gdrive:$DATE`:
```bash
rclone copy "$PROJECT/out/$DATE/" "gdrive:$DATE" \
  --drive-root-folder-id "$GDRIVE_FOLDER_ID" \
  --drive-use-trash=false
```
