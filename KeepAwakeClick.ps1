# KeepAwakeClick.ps1
# Does a single left-click at the current cursor position every ~55 seconds,
# for a limited duration (default 2 hours), then stops automatically.
#
# IMPORTANT: the click lands wherever your mouse pointer currently is.
# Before walking away, park the cursor on a safe empty spot (desktop
# background or a blank area of the window you're presenting).
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\KeepAwakeClick.ps1
#   powershell -ExecutionPolicy Bypass -File .\KeepAwakeClick.ps1 -DurationHours 3
#   powershell -ExecutionPolicy Bypass -File .\KeepAwakeClick.ps1 -DurationHours 2.5 -IntervalSeconds 45
# Stop early: close the window or press Ctrl+C.

param(
    [double]$DurationHours = 2,
    [int]$IntervalSeconds = 55
)

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class NativeInput {
    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, IntPtr dwExtraInfo);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern uint SetThreadExecutionState(uint esFlags);
}
'@

$MOUSEEVENTF_LEFTDOWN = [uint32]0x0002
$MOUSEEVENTF_LEFTUP   = [uint32]0x0004
$ES_CONTINUOUS        = [uint32]0x80000000
$ES_SYSTEM_REQUIRED   = [uint32]0x00000001
$ES_DISPLAY_REQUIRED  = [uint32]0x00000002

# Also ask Windows not to sleep or dim the display while this script runs.
[NativeInput]::SetThreadExecutionState(
    $ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED -bor $ES_DISPLAY_REQUIRED) | Out-Null

$deadline = (Get-Date).AddHours($DurationHours)
Write-Host ("Auto-click active: 1 left-click every {0}s, for {1} hour(s)." -f $IntervalSeconds, $DurationHours)
Write-Host ("Will stop automatically at {0}. Close window or Ctrl+C to stop early." -f $deadline.ToString("HH:mm"))

try {
    while ((Get-Date) -lt $deadline) {
        # Single left-click at the current cursor position (down + up).
        [NativeInput]::mouse_event($MOUSEEVENTF_LEFTDOWN, 0, 0, 0, [IntPtr]::Zero)
        Start-Sleep -Milliseconds 50
        [NativeInput]::mouse_event($MOUSEEVENTF_LEFTUP, 0, 0, 0, [IntPtr]::Zero)

        # Re-assert the no-sleep/no-dim flag in case something else reset it.
        [NativeInput]::SetThreadExecutionState(
            $ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED -bor $ES_DISPLAY_REQUIRED) | Out-Null

        Start-Sleep -Seconds $IntervalSeconds
    }
}
finally {
    # Hand power management back to Windows.
    [NativeInput]::SetThreadExecutionState($ES_CONTINUOUS) | Out-Null
    Write-Host "Done. Auto-click stopped and normal power settings restored."
}
