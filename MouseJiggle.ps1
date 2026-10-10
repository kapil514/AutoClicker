# MouseJiggle.ps1
# Fallback for machines where the lock screen is enforced by Group Policy.
# Moves the cursor 1 pixel and back every ~50 seconds - enough to reset the
# idle timer, but it never clicks, so it can't interact with anything on screen.
#
# Usage:   powershell -ExecutionPolicy Bypass -File .\MouseJiggle.ps1
# Stop:    close the window or press Ctrl+C.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Write-Host "Mouse jiggle active every 50 seconds. Close window or Ctrl+C to stop."

while ($true) {
    $pos = [System.Windows.Forms.Cursor]::Position
    [System.Windows.Forms.Cursor]::Position =
        New-Object System.Drawing.Point(($pos.X + 1), $pos.Y)
    Start-Sleep -Milliseconds 200
    [System.Windows.Forms.Cursor]::Position = $pos
    Start-Sleep -Seconds 50
}
