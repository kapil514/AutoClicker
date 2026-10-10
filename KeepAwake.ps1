# KeepAwake.ps1
# Prevents the screen from dimming and the system from sleeping while running.
# Uses the built-in Windows SetThreadExecutionState API - no mouse/keyboard
# simulation, nothing injected, so it looks like ordinary PowerShell activity.
#
# Usage:
#   Right-click -> "Run with PowerShell"
#   or in a terminal:  powershell -ExecutionPolicy Bypass -File .\KeepAwake.ps1
# Stop it by closing the window or pressing Ctrl+C.

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class SleepControl {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern uint SetThreadExecutionState(uint esFlags);
}
'@

$ES_CONTINUOUS        = [uint32]0x80000000
$ES_SYSTEM_REQUIRED   = [uint32]0x00000001
$ES_DISPLAY_REQUIRED  = [uint32]0x00000002

# Tell Windows: as long as this process is alive, keep system + display awake.
[SleepControl]::SetThreadExecutionState(
    $ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED -bor $ES_DISPLAY_REQUIRED) | Out-Null

Write-Host "Keep-awake is ON. Screen and system will not sleep."
Write-Host "Close this window or press Ctrl+C to restore normal behavior."

try {
    # Re-assert every 50 seconds (some tools reset the flag periodically).
    while ($true) {
        [SleepControl]::SetThreadExecutionState(
            $ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED -bor $ES_DISPLAY_REQUIRED) | Out-Null
        Start-Sleep -Seconds 50
    }
}
finally {
    # Hand control back to Windows when the script exits.
    [SleepControl]::SetThreadExecutionState($ES_CONTINUOUS) | Out-Null
    Write-Host "Keep-awake is OFF. Normal power settings restored."
}
