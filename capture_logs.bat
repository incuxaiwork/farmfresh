@echo off
title FarmFresh App Diagnostic tool
echo ========================================================
echo           FarmFresh Crash Log Capture Tool
echo ========================================================
echo.
echo This tool will capture logs from your Android phone to find 
echo the exact reason why the app keeps stopping.
echo.
echo REQUIREMENTS:
echo 1. Connect your Android phone to this PC via USB.
echo 2. Enable "USB Debugging" on your phone:
echo    - Go to Settings - About Phone.
echo    - Tap "Build Number" 7 times until it says "Developer options enabled".
echo    - Go back to Settings - System - Developer Options.
echo    - Turn ON "USB Debugging".
echo    - Accept the prompt on your phone screen to authorize this PC.
echo.
echo Press any key when your phone is connected and ready...
pause > nul

echo.
echo Checking connected devices...
"C:\Users\ansar\AppData\Local\Android\Sdk\platform-tools\adb.exe" devices
echo.

echo ========================================================
echo CAPTURING LOGS:
echo 1. Open the FarmFresh app on your phone so it crashes.
echo 2. Wait 5 seconds.
echo 3. Press [Ctrl + C] in this window to stop capture.
echo 4. When asked "Terminate batch job (Y/N)?", type Y and press Enter.
echo ========================================================
echo.
echo Capturing error logs to crash_log.txt...
"C:\Users\ansar\AppData\Local\Android\Sdk\platform-tools\adb.exe" logcat *:E > "%~dp0crash_log.txt"
