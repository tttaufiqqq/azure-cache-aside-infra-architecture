# Working with screenshots

This project documents Azure portal work with screenshots, and the assistant model cannot view images. To identify or caption screenshots, use OCR:

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\ocr-shots.ps1 -Folder "<path>\screenshots"
```

- Run through `powershell.exe` (Windows PowerShell 5.1), not `pwsh` (PowerShell 7) - WinRT OCR types do not load in PowerShell 7.
- The script prints `### <filename>` followed by the recognized text for every PNG in the folder.
- OCR output is noisy for portal screenshots; use it to identify pages, not to read exact values.

## Conventions

- Rename screenshots to numbered descriptive names that sort chronologically, e.g. `01-create-resource.png`, `02-deploy-complete.png`.
- Every `README.md` must reference every image in its `screenshots/` folder with a one-line caption.
- Keep sensitive values (subscription IDs, tenant IDs, emails, public IPs) out of filenames and captions.
