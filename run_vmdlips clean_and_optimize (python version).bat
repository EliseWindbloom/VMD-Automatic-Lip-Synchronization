@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:found_python
if not defined PYTHON set PYTHON=python

echo.
echo Checking pip installation...
%PYTHON% -m pip --version
if %errorlevel% neq 0 (
    echo Error: pip is not installed. Please install pip and try again.
    pause
    exit /b 1
)

echo.
echo Checking tkinter installation...
%PYTHON% -c "import tkinter"
if %errorlevel% neq 0 (
    echo tkinter is not installed. Attempting to install...
    %PYTHON% -m pip install tk
    if %errorlevel% neq 0 (
        echo Error: Failed to install tkinter. Please run this script as administrator or install tkinter manually.
        pause
        exit /b 1
    )
    echo tkinter installed successfully.
) else (
    echo tkinter is already installed.
)

echo.
echo Running Python script...
%PYTHON% "VMD Lips clean & optimize v11.py"

if %errorlevel% neq 0 (
    echo.
    echo The script encountered an error. If you're seeing permission issues, try running this batch file as administrator.
    echo If you're seeing connection issues, check your firewall or antivirus settings.
)
