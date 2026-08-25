@echo off
chcp 65001 >nul
title MoviePilot-V2
cd /d "%~dp0"

rem ------------------------------------------------------------
rem MoviePilot-V2 launcher (FastAPI StaticFiles edition)
rem No Nginx: the FastAPI backend serves the frontend directly
rem at http://127.0.0.1:3000
rem ------------------------------------------------------------

rem Path length check only. 空格是可以的 (FastAPI/Python 能正确处理 spaces-in-path)
setlocal enabledelayedexpansion
set "_dir=%cd%"
if not "!_dir!"=="!_dir:~,240!" (
    echo [ERROR] 安装路径超过 240 字符，请缩短后重试。
    pause
    exit /b 1
)
endlocal

rem Tell MoviePilot to serve the frontend itself
set "MOVIEPILOT_SERVE_FRONTEND=true"
set "FRONTEND_PATH=%~dp0MoviePilot-Frontend"
set "PYTHONUNBUFFERED=1"
set "PORT=3000"

rem Launch
if not exist "%~dp0Python3.11\python.exe" (
    echo [ERROR] 未找到内置 Python 解释器，安装可能损坏。
    pause
    exit /b 1
)

cd MoviePilot
echo 启动 MoviePilot-V2 后端 ^(端口 3000^)...
start "" "http://127.0.0.1:3000"
"..\Python3.11\python.exe" app\main.py
pause
