# --------------------------------------------------------------------------
#            VMware Horizon Client Removal Tool
#            Author: Daniel Burrowes
#
#            Uninstalls VMware Horizon Client Software and
#            performs additional cleanups. This allows for uninstall
#            and clean up without needing original Installer files.
# --------------------------------------------------------------------------
# Enabling -Verbose and -Debug Options
    [CmdletBinding()]
    param()
# --------------------------------------------------------------------------


$logFile = "$env:ProgramData\VMwareHorizon_Uninstall.log"
"==== Starting VMware Horizon Cleanup: $(Get-Date) ====" | Out-File -FilePath $logFile -Encoding UTF8

$exitCode = 0
$errors = @()

function Log {
    param ($message)
    Write-Host $message
    $message | Out-File -Append -FilePath $logFile
}

function Try-RemoveItem {
    param ($Path)
    if (Test-Path $Path) {
        try {
            Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
            Log "Deleted: $Path"
        } catch {
            $errors += "Failed to delete: $Path - $_"
            Log $errors[-1]
        }
    } else {
        Log "Not found (already deleted or missing): $Path"
    }
}

Log ""
Log "Step 1: Attempting known ProductCode uninstall..."
$knownProductCode = "{ff16755a-bea4-44ea-bcdc-f12c0284752f}"
try {
    $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $knownProductCode /qn /norestart" -Wait -PassThru
    Log "msiexec returned ExitCode: $($proc.ExitCode)"
} catch {
    $errors += "Failed MSI uninstall for ${knownProductCode}: $_"
    Log $errors[-1]
}

Log ""
Log "Step 2: Searching uninstall registry for VMware Horizon components..."

$regPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
)

foreach ($regBase in $regPaths) {
    Log "Scanning $regBase"

    Get-ChildItem $regBase -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $entry = Get-ItemProperty $_.PSPath
            if ($entry.DisplayName -like "*VMware Horizon*") {
                $name = $entry.DisplayName
                $id = $_.PSChildName
                Log "Found: $name [$id]"

                try {
                    Start-Process msiexec.exe -ArgumentList "/x $id /qn /norestart" -Wait
                    Log "Uninstalled: $name"
                } catch {
                    $errors += "Failed uninstall: ${name} [${id}] - $_"
                    Log $errors[-1]
                }

                if (Test-Path $_.PSPath) {
                    try {
                        Remove-Item $_.PSPath -Recurse -Force -ErrorAction Stop
                        Log "Removed registry key: $name"
                    } catch {
                        $errors += "Failed to remove registry key: ${name} - $_"
                        Log $errors[-1]
                    }
                } else {
                    Log "Registry key not found (already removed): $name"
                }
            }
        } catch {}
    }
}

Log ""
Log "Step 3: Removing leftover files and folders..."

$pathsToDelete = @(
    "C:\Program Files\VMware\VMware Horizon View Client",
    "C:\Program Files (x86)\VMware\VMware Horizon View Client",
    "$env:APPDATA\VMware",
    "$env:LOCALAPPDATA\VMware",
    "$env:ProgramData\VMware"
)

foreach ($path in $pathsToDelete) {
    Try-RemoveItem -Path $path
}

Log ""
Log "Step 4: Cleaning up Start Menu and Desktop Shortcuts..."

$shortcuts = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\VMware Horizon Client.lnk",
    "$env:PUBLIC\Desktop\VMware Horizon Client.lnk"
)

foreach ($lnk in $shortcuts) {
    Try-RemoveItem -Path $lnk
}

Log ""
Log "Step 5: Final registry verification..."

Start-Sleep -Seconds 3
if (-not (Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$knownProductCode")) {
    Log "Final check passed. VMware Horizon Client registry key is gone."
} else {
    $errors += "Still detected: Registry key $knownProductCode"
    Log $errors[-1]
    $exitCode = 1
}

Log ""
Log "==== Cleanup Completed: $(Get-Date) ===="
Log ""

if ($errors.Count -gt 0) {
    Log "Summary of issues encountered:"
    foreach ($err in $errors) {
        Log "  $err"
    }
    Log "`nCleanup finished with warnings or failures. Please review the above."
    exit 1
} else {
    Log "All VMware Horizon components removed successfully."
    exit 0
}
