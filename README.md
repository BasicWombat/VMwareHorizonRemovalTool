# VMware Horizon Dirty Uninstaller (Datto RMM Compatible)

This PowerShell script performs an **aggressive and comprehensive removal of the VMware Horizon Client and all related components**. It's specifically designed for deployment via **Datto RMM** or other remote management tools, and handles both MSI- and registry-based uninstallations, as well as orphaned files and shortcuts.



## ✅ Features

- Uninstalls **VMware Horizon Client** using known MSI ProductCodes
- Searches registry for any remaining Horizon components and removes them
- Cleans up:
  - Residual installation folders
  - Start Menu shortcuts
  - Desktop shortcuts
- Logs full uninstall history to both **console** and **file**
- Safe to run repeatedly — skips or logs missing items
- Designed for **Datto RMM** with clear exit codes:
  - `0` = Success
  - `1` = Errors or items left behind



## 🔧 Supported VMware Horizon Components

The script targets and removes:

- VMware Horizon Client
- Horizon HTML5 Multimedia Redirection Client
- Horizon Media Engine
- Horizon Media Redirection for Microsoft Teams
- Any other `DisplayName` containing **"VMware Horizon"**



## 📁 Log Output

A full uninstall log is written to: C:\ProgramData\VMwareHorizon_Uninstall.log


Additionally, all output is sent to the **console** for visibility in Datto RMM or manual execution logs.

## 🚀 Usage

### In Datto RMM

1. Go to **Components** > **Create New Component**
2. Choose:
   - **Category**: PowerShell
   - **Architecture**: Windows
   - **Execution context**: System
3. Paste the script content into the **Script Body**
4. Save and deploy to target devices

### Manually

1. Open PowerShell as Administrator
2. Run:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process
.\Remove-VMwareHorizon.ps1
```


## ⚠️ Notes

- Does not require the original VMware Horizon EXE installer
- Will not reboot the system, but you may schedule one if required
- Script is safe to run even if VMware Horizon was already removed
- Registry keys and folders not found are logged as "not found" — not as errors

## 📌 Exit Codes

| Exit Code | Meaning                                                        |
| --------- | -------------------------------------------------------------- |
| 0         | All targeted Horizon components removed                        |
| 1         | Some components or registry keys failed to uninstall or delete |


## 🧪 Tested On

- Windows 10 (x64)
- Datto RMM agent environments

## 📜 License

This script is provided under the MIT License. Use at your own risk.

## 🤝 Contributing

Contributions welcome! Please submit a PR if you find a more reliable detection method or need support for additional cleanup paths.
