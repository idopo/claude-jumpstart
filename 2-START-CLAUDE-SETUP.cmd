@echo off
rem Double-click me after 1-INSTALL-WINDOWS.cmd. Opens Claude in this folder and starts the guided setup.
start "Claude Code setup" powershell.exe -NoExit -NoProfile -ExecutionPolicy Bypass -File "%~dp0install\claude-here.ps1" "%~dp0." "Read SETUP.md in this folder and walk me through it, one step at a time."
