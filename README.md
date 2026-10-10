# AutoClicker
PowerShell scripts to keep a Windows PC awake: KeepAwake.ps1 blocks sleep/dimming via the SetThreadExecutionState API with zero input simulation, MouseJiggle.ps1 nudges the cursor 1px every 50s (never clicks), and KeepAwakeClick.ps1 auto-clicks at the cursor position for a configurable duration. No installs, no admin rights, no third-party tools.


# Autoclicker

A small collection of Windows PowerShell scripts to keep your machine awake and
prevent the screen from locking or dimming — useful during long presentations,
monitoring dashboards, waiting on builds, etc.

## Scripts

### `KeepAwake.ps1` — Recommended

Keeps the system and display awake **without simulating any mouse or keyboard
input**. It calls the Windows
[`SetThreadExecutionState`](https://learn.microsoft.com/windows/win32/api/winbase/nf-winbase-setthreadexecutionstate)
API to tell Windows "don't sleep while this process is alive", so nothing is
injected and it looks like ordinary PowerShell activity. The flag is re-asserted
every 50 seconds in case something else resets it, and handed back to Windows
when the script exits.

```powershell
powershell -ExecutionPolicy Bypass -File .\KeepAwake.ps1
```

### `MouseJiggle.ps1` — Fallback for lock-down machines

Moves the cursor 1 pixel and back every ~50 seconds. Use this when the lock
screen is enforced by Group Policy and the execution-state approach isn't
enough. It **never clicks**, so it can't interact with anything on screen.

```powershell
powershell -ExecutionPolicy Bypass -File .\MouseJiggle.ps1
```

### `KeepAwakeClick.ps1` — Active simulation

Performs a single **left-click at the current cursor position** every ~55
seconds, for a limited duration (2 hours by default), then stops automatically.
Also keeps the system awake via `SetThreadExecutionState`.

> **Warning:** the click lands wherever your mouse pointer is at that moment.
> Before walking away, park the cursor somewhere safe (empty desktop background
> or a blank area of a window).

```powershell
# Defaults: every 55s, for 2 hours
powershell -ExecutionPolicy Bypass -File .\KeepAwakeClick.ps1

# Custom duration / interval
powershell -ExecutionPolicy Bypass -File .\KeepAwakeClick.ps1 -DurationHours 3
powershell -ExecutionPolicy Bypass -File .\KeepAwakeClick.ps1 -DurationHours 2.5 -IntervalSeconds 45
```

| Parameter         | Default | Description                      |
| ----------------- | ------- | -------------------------------- |
| `DurationHours`   | `2`     | How long to run before auto-stop |
| `IntervalSeconds` | `55`    | Time between clicks              |

## Usage

- Right-click any script → **Run with PowerShell**, or
- Run from a terminal with `powershell -ExecutionPolicy Bypass -File .\Script.ps1`
  (the `-ExecutionPolicy Bypass` flag is needed on machines where script
  execution is restricted by default).
- Stop any script by closing the window or pressing `Ctrl+C`. Power management
  is restored on exit.

## Requirements

- Windows with PowerShell 5.1+ (built into Windows 10/11).
- No third-party tools or admin rights required; the scripts only use built-in
  Win32 APIs (`kernel32.SetThreadExecutionState`, `user32.mouse_event`) and
  .NET (`System.Windows.Forms.Cursor`).
