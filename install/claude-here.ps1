<#
  Opens Claude Code in a folder. Used by the "Open Claude here" right-click menu entry and by
  2-START-CLAUDE-SETUP.cmd. Reloads PATH from the registry first, so a window opened right after
  the installer still finds claude, git and node.
  Usage: claude-here.ps1 <folder> [first prompt]
#>
param(
  [Parameter(Mandatory = $true)][string]$Folder,
  [string]$FirstPrompt = ''
)

$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
  Write-Host "Claude Code is not installed yet. Double-click 1-INSTALL-WINDOWS.cmd first." -ForegroundColor Red
  return
}

Set-Location -LiteralPath $Folder
$host.UI.RawUI.WindowTitle = "Claude Code - $Folder"
Write-Host "Starting Claude Code in $Folder" -ForegroundColor Cyan
Write-Host "(To leave Claude: type /exit or close this window.)"
Write-Host ""
if ($FirstPrompt) { & claude $FirstPrompt } else { & claude }
