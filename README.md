# WSDoM CM94 Client — Intune Win32 App Packaging Guide

## What changed from the original scripts

| Issue | Original | Fixed |
|-------|----------|-------|
| `MsiExec` called without `START /WAIT` | Multiple MSIs race, 1618 errors, silent failures | All calls use `START /WAIT` |
| Log path hard-coded to UNC share | Fails if machine not on LAN/VPN | PINGs server first; falls back to `C:\Windows\Logs\WSDoM` |
| Office bit detection incomplete | Misses some M365 C2R install paths | Adds registry check for `InstallRoot` keys (both architectures) |
| `EXIT` at end | No return code passed back | `EXIT /B 0` on success |
| Network VBS dependency | VBS pulled from `\\wpwtws0204\...` at startup | VBS copied locally to `C:\Program Files\Kapish\User Settings\` at install time |
| `2>NUL` missing on cleanup | Harmless errors printed, misleading in logs | All cleanup commands suppress stderr |

---

## Folder structure to package

```
WSDoM-Package\          ← this becomes the root, wrap with IntuneWinAppUtil
├── Install.cmd
├── Uninstall.bat
├── Detect.ps1          ← uploaded separately in Intune (not inside .intunewin)
├── SourceX64\
│   ├── MicroFocus\
│   │   ├── CM_x64_9300178.msi
│   │   ├── CM_x64_9320418.msp
│   │   └── CM_x64_9320430.msp
│   └── Kapish\
│       ├── Kapish Easy Link-x64-3.41.3556.msi
│       ├── Kapish Folder Wizard-x64-3.52.1910.msi
│       ├── Kapish PDF Wizard-x64-2.01.1110.msi
│       ├── Kapish Record Remover-x64-1.60.1400.msi
│       ├── Kapish Workflow Wizard-x64-1.04.1066.msi
│       └── Kapish_Explorer-x64-5.11.5026.msi
├── SourceX86\
│   ├── MicroFocus\
│   │   ├── CM_x86_9300178.msi
│   │   ├── CM_x86_9320418.msp
│   │   ├── CM_x86_9320430.msp
│   │   └── UIgnore.tlx          (optional)
│   └── Kapish\
│       ├── Kapish Easy Link-x86-3.41.3556.msi
│       ├── Kapish Folder Wizard-x86-3.52.1910.msi
│       ├── Kapish PDF Wizard-x86-2.01.1110.msi
│       ├── Kapish Record Remover-x86-1.60.1400.msi
│       ├── Kapish Workflow Wizard-x86-1.04.1066.msi
│       ├── Kapish_Explorer-x86-5.11.5026.msi
│       ├── Kapish Excel Add-In v4.20.1434.msi
│       └── Kapish Word Add-In v4.20.1434.msi
└── WSDoM\
    ├── WSDoM Desktop.ico
    ├── WSDoM Explorer.ico
    └── CM93-WSDoM-User-Settings-PROD-43-x86-x64.vbs
```

---

## Step 1 — Create the .intunewin package

Download IntuneWinAppUtil from:
https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool

```cmd
IntuneWinAppUtil.exe -c "C:\WSDoM-Package" -s Install.cmd -o "C:\Output"
```

This produces `Install.intunewin`.

---

## Step 2 — Create the Win32 app in Intune

1. Intune admin centre → Apps → Windows → Add → **Windows app (Win32)**
2. Upload `Install.intunewin`
3. Fill in name/publisher/version

### Install command
```
cmd.exe /c Install.cmd
```

### Uninstall command
```
cmd.exe /c Uninstall.bat
```

### Install behaviour
**System** (runs as SYSTEM, required for MSI installs)

### Return codes
Add these in addition to the default 0:
| Code | Type |
|------|------|
| 3010 | Soft reboot |
| 1641 | Hard reboot |

---

## Step 3 — Detection rule

Choose **Custom detection script**, upload `Detect.ps1`.
- Run as 32-bit: **No**
- Enforce script signature check: **No** (unless your tenant requires it)

---

## Step 4 — Requirements

- OS: Windows 10 1903+ or Windows 11
- Architecture: x64
- Minimum disk: 2 GB free (approx)

---

## Troubleshooting

Logs land in `C:\Windows\Logs\WSDoM\` on the device (or the UNC share if reachable).

Common exit codes from MsiExec:
| Code | Meaning |
|------|---------|
| 0 | Success |
| 1603 | Fatal error (check MSI log) |
| 1618 | Another install already running — means START /WAIT was missing |
| 1619 | Package not found — check ROOTPATH and source file names match exactly |
| 3010 | Success, reboot required |
