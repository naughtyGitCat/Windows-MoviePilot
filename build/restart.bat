@echo off
rem RebotMP.bat - stand-in for RebotMP.exe
rem SystemUtils.restart() in the Python code invokes `start RebotMP.exe`;
rem this batch wraps the same behavior for the StaticFiles build.
rem
rem Flow: kill the running python/uvicorn, wait briefly, relaunch.

cd /d "%~dp0"

rem Kill any MoviePilot python process we can identify
for /f "tokens=2 delims=," %%p in ('tasklist /fi "imagename eq python.exe" /fo csv /nh 2^>nul') do (
    set "pid=%%~p"
    taskkill /pid %%~p /f >nul 2>&1
)

rem Short sleep via ping trick (no external deps)
ping -n 3 127.0.0.1 >nul

rem Relaunch
start "" "%~dp0MoviePilot.bat"
exit /b 0
