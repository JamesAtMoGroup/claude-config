---
name: Vibecoding Drive sync — always download assets/ subfolder
description: When syncing HTML from Google Drive to vibecoding/lectureN/, the assets/ subfolder must always be downloaded alongside the HTML. HTML files use relative paths like assets/xxx.png which break without the folder.
type: feedback
---

Every vibecoding lecture HTML references images and files with **relative paths** (`assets/xxx.png`, `assets/xxx.mp4`, etc.). The Drive folder structure mirrors this — there is an `assets/` subfolder next to the HTML file.

**Why:** Without downloading the `assets/` subfolder, all image/asset references in the HTML 404. The HTML itself never needs to change — it already has the correct relative paths from the start.

**How to apply:**
- `sync_drive.py` must always detect and download the `assets/` subfolder from each Drive lecture folder into `vibecoding/lectureN/assets/`
- This is already implemented — do not remove or skip this logic when modifying the sync script
- When a new lecture folder is added to Drive, confirm it has an `assets/` subfolder if the HTML references any local images
- Never assume assets are hosted externally — always sync them from Drive
