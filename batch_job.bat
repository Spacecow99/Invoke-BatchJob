@echo off
SET cmd_path="C:\Windows\Temp\TMP486.tmp"
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