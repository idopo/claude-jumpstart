@echo off
rem Double-click me. Installs Git, Node.js, Claude Code and GSD, then sets up PATH.
rem Safe to run again: everything already installed is skipped.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install\setup-claude-windows.ps1"
