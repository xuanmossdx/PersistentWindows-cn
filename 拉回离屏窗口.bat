@echo off
rem Pull back ALL windows that went fully off-screen (e.g. after virtual display disconnect)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0拉回离屏窗口.ps1"
