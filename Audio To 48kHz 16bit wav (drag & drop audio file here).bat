@echo off
setlocal enabledelayedexpansion

REM Check if an argument was provided
if "%~1"=="" (
    echo Drag and drop an input audio file onto this batch file.
    pause
    exit /b
)

REM Set the input file path
set "input_file=%~1"

REM Get the input file name without extension
for %%F in ("!input_file!") do set "filename=%%~nF"

REM Set the output file path with a different name (e.g., add "_converted" to the original name)
set "output_file=!filename!_48kHz16bit.wav"

REM Run FFmpeg command
ffmpeg -i "!input_file!" -ar 48000 -ac 1 -sample_fmt s16 "!output_file!"

echo Conversion complete. Output saved to: "!output_file!"
