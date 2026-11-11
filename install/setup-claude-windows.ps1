<#
.SYNOPSIS
  One-shot Windows setup for the lab kit: Git for Windows, Node.js 24+, Claude Code, GSD Core,
  an "Open Claude here" right-click entry, the person's own git clone of the kit and a desktop shortcut.

.DESCRIPTION
  Rule: never change what already exists. Every step checks first and skips (with a message) when the
  tool, setting, menu entry or shortcut is already there. An existing Node, GSD, settings.json,
  execution policy or PATH entry is left exactly as it is.

  Only the Git and Node installers need admin. They run in a separate elevated window, and only when
  one of them is missing. Everything else runs as the person who double-clicked, so files land in
  their own profile and no npm package ever runs with admin rights.

.USAGE
  Double-click 1-INSTALL-WINDOWS.cmd in the repo root (it runs this file). Safe to re-run.
  Or: powershell -ExecutionPolicy Bypass -File .\install\setup-claude-windows.ps1

.NOTES
  Written for Windows PowerShell 5.1 (built into Windows 10/11). ASCII only, on purpose:
  PowerShell 5.1 misreads non-ASCII characters in a file saved without a BOM.
#>

[CmdletBinding()]
param(
  [switch]$SkipGsd,                 # install Git/Node/Claude only
  [switch]$AdminInstall,            # internal: this is the elevated child window
  [switch]$NeedGit,                 # internal: child installs Git
  [switch]$NeedNode,                # internal: child installs Node
  [string]$KitRepoUrl = 'https://github.com/idopo/claude-jumpstart.git'
)

# Started by double-click: keep the window open on any failure so the error can be read and sent to Ido.
trap {
  Write-Host ""
  Write-Host "    [FAIL] $($_.Exception.Message)" -ForegroundColor Red
  Write-Host "    Take a screenshot of this window and send it to Ido." -ForegroundColor Red
  Read-Host "Press Enter to close"
  exit 1
}

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'   # Invoke-WebRequest is 10x faster without the progress bar
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Process scope only: lets this run start child scripts, gone when the window closes. Can throw
# under a Group Policy even though nothing is wrong.
try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force } catch { Write-Verbose 'process policy locked' }

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function Write-Step([string]$Text) { Write-Host ""; Write-Host "==> $Text" -ForegroundColor Cyan }
function Write-Ok([string]$Text)   { Write-Host "    [OK]   $Text" -ForegroundColor Green }
function Write-Skip([string]$Text) { Write-Host "    [SKIP] $Text" -ForegroundColor DarkCyan }
function Write-Warn([string]$Text) { Write-Host "    [WARN] $Text" -ForegroundColor Yellow }
function Write-Fail([string]$Text) { Write-Host "    [FAIL] $Text" -ForegroundColor Red }

function Test-Command([string]$Name) { return [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

# Runs an external program and returns its exit code. With ErrorActionPreference=Stop, PowerShell 5.1
# turns stderr text from a native program (npm warnings, git progress) into a fatal error; this relaxes
# that for the one call and lets the exit code decide.
function Invoke-Native([scriptblock]$Command) {
  $previous = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { & $Command | Out-Host; return $LASTEXITCODE } finally { $ErrorActionPreference = $previous }
}

# Runs an installer attached directly to this console window and returns its exit code. Interactive
# installers (claude.exe install, GSD's npx installer) can wait forever when their output goes into a
# pipe, which is what Invoke-Native does. Reading .Handle before waiting works around PowerShell 5.1
# returning an empty ExitCode for -NoNewWindow processes.
function Invoke-InConsole([string]$FilePath, [string]$Arguments) {
  $process = Start-Process -FilePath $FilePath -ArgumentList $Arguments -NoNewWindow -PassThru
  $null = $process.Handle
  $process.WaitForExit()
  return $process.ExitCode
}

# Output lines of a native program (or none on failure); never throws.
function Get-NativeOutput([scriptblock]$Command) {
  $previous = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { return @(& $Command 2>$null) } catch { return @() } finally { $ErrorActionPreference = $previous }
}

# First line of `<tool> --version`, or a note when it fails; never throws.
function Get-ToolVersion([string]$Name) {
  $first = Get-NativeOutput { & $Name --version } | Select-Object -First 1
  if ($first) { return [string]$first } else { return '(version check failed)' }
}

# Rebuild this window's PATH from the registry (Machine + User) so freshly installed tools resolve.
function Update-SessionPath {
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

# Append a folder to the User PATH without disturbing the rest of it. The raw registry value is read
# unexpanded and written back as REG_EXPAND_SZ, so entries such as %USERPROFILE%\...\WindowsApps keep
# their variables ([Environment]::SetEnvironmentVariable would freeze them into literal paths).
function Add-ToUserPath([string]$Dir) {
  if (-not (Test-Path $Dir)) { Write-Warn "Not adding to PATH, folder does not exist: $Dir"; return }
  $key = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey('Environment')
  try {
    $raw = [string]$key.GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
    $entries = @($raw -split ';' | Where-Object { $_ -ne '' })
    $already = $entries | Where-Object { [Environment]::ExpandEnvironmentVariables($_).TrimEnd('\') -ieq $Dir.TrimEnd('\') }
    if ($already) {
      Write-Skip "already on your PATH: $Dir"
    } else {
      $key.SetValue('Path', (($entries + $Dir) -join ';'), [Microsoft.Win32.RegistryValueKind]::ExpandString)
      Write-Ok "added to your PATH: $Dir"
      # A registry write does not tell Explorer that PATH changed. Setting and clearing a throwaway
      # variable through .NET sends the WM_SETTINGCHANGE broadcast, so new windows see the new PATH.
      [Environment]::SetEnvironmentVariable('CLAUDE_KIT_PATH_REFRESH', '1', 'User')
      [Environment]::SetEnvironmentVariable('CLAUDE_KIT_PATH_REFRESH', $null, 'User')
    }
  } finally { $key.Close() }
  if (($env:Path -split ';') -notcontains $Dir) { $env:Path = "$env:Path;$Dir" }
}

function Get-File([string]$Url, [string]$OutFile) {
  Write-Host "    downloading $Url"
  Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing
  if (-not (Test-Path $OutFile) -or (Get-Item $OutFile).Length -lt 1024) { throw "Download failed or file is empty: $OutFile" }
}

# winget exists on most Windows 10/11 installs but is often broken on a fresh machine; treat broken as absent.
function Test-Winget {
  if (-not (Test-Command 'winget')) { return $false }
  return [bool](Get-NativeOutput { & winget --version })
}

function Install-WithWinget([string]$Id) {
  Write-Host "    winget install $Id"
  $exitCode = Invoke-Native { & winget install --id $Id -e --silent --accept-package-agreements --accept-source-agreements }
  return ($exitCode -eq 0)
}

# Major version of the active node, or 0 when there is none.
function Get-NodeMajor {
  if (-not (Test-Command 'node')) { return 0 }
  $version = Get-NativeOutput { & node --version } | Select-Object -First 1
  if ([string]$version -match '^v(\d+)\.') { return [int]$Matches[1] } else { return 0 }
}

function Test-NodeVersionManager {
  return [bool]((Test-Command 'nvm') -or (Test-Command 'volta') -or $env:NVM_HOME -or $env:VOLTA_HOME)
}

function Get-GitRoot {
  foreach ($candidate in @("$env:ProgramFiles\Git", "${env:ProgramFiles(x86)}\Git", "$env:LOCALAPPDATA\Programs\Git")) {
    if (Test-Path (Join-Path $candidate 'bin\bash.exe')) { return $candidate }
  }
  return $null
}

# ===========================================================================
# Elevated child: installs only Git and/or Node (both write to Program Files), then exits.
# ===========================================================================
if ($AdminInstall) {
  $DownloadDir = Join-Path $env:TEMP 'claude-setup-downloads'
  New-Item -ItemType Directory -Force -Path $DownloadDir | Out-Null
  $haveWinget = Test-Winget

  if ($NeedGit) {
    Write-Step "Installing Git for Windows"
    $done = $haveWinget -and (Install-WithWinget 'Git.Git')
    if (-not $done) {
      $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/git-for-windows/git/releases/latest' -UseBasicParsing
      $pattern = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'Git-*-arm64.exe' } else { 'Git-*-64-bit.exe' }
      $asset   = $release.assets | Where-Object { $_.name -like $pattern } | Select-Object -First 1
      if (-not $asset) { throw "Could not find a Git installer ($pattern) in the latest release" }
      $exe = Join-Path $DownloadDir $asset.name
      Get-File $asset.browser_download_url $exe
      # PathOption=Cmd puts only git itself on the Machine PATH, not Git's Unix tools.
      $proc = Start-Process -FilePath $exe -ArgumentList '/VERYSILENT', '/NORESTART', '/NOCANCEL', '/SP-', '/o:PathOption=Cmd' -Wait -PassThru
      if ($proc.ExitCode -ne 0) { throw "Git installer exited with code $($proc.ExitCode)" }
    }
    Write-Ok "Git installed"
  }

  if ($NeedNode) {
    Write-Step "Installing Node.js LTS"
    $done = $haveWinget -and (Install-WithWinget 'OpenJS.NodeJS.LTS')
    if (-not $done) {
      $nodeArch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'arm64' } else { 'x64' }
      $lts = Invoke-RestMethod -Uri 'https://nodejs.org/dist/index.json' -UseBasicParsing | Where-Object { $_.lts } | Select-Object -First 1
      if (-not $lts) { throw "Could not determine the current Node LTS version" }
      $msi = Join-Path $DownloadDir "node-$($lts.version)-$nodeArch.msi"
      Get-File "https://nodejs.org/dist/$($lts.version)/node-$($lts.version)-$nodeArch.msi" $msi
      $proc = Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i', "`"$msi`"", '/qn', '/norestart' -Wait -PassThru
      if ($proc.ExitCode -ne 0 -and $proc.ExitCode -ne 3010) { throw "Node installer exited with code $($proc.ExitCode)" }
    }
    Write-Ok "Node installed"
  }
  exit 0
}

# ===========================================================================
# Main window (runs as the person who double-clicked)
# ===========================================================================

# Guard: Windows PowerShell 5.1+ on 64-bit Windows 10/11. Say so plainly instead of failing halfway.
$psVersion = $PSVersionTable.PSVersion
$winBuild  = [Environment]::OSVersion.Version
Write-Host "PowerShell $psVersion on Windows build $($winBuild.Build) ($(if ([Environment]::Is64BitOperatingSystem) { '64-bit' } else { '32-bit' }))"
$problem = $null
if ($psVersion.Major -lt 5 -or ($psVersion.Major -eq 5 -and $psVersion.Minor -lt 1)) { $problem = "PowerShell $psVersion is too old (need 5.1, built into Windows 10 and 11)." }
elseif ($winBuild.Major -lt 10)                     { $problem = "This Windows is older than Windows 10; Claude Code needs Windows 10 or 11." }
elseif (-not [Environment]::Is64BitOperatingSystem) { $problem = "This is 32-bit Windows; Claude Code needs 64-bit Windows." }
if ($problem) {
  Write-Host ""
  Write-Host "STOP: $problem" -ForegroundColor Red
  Write-Host "Nothing was installed. Send Ido a screenshot of this window." -ForegroundColor Red
  Read-Host "Press Enter to close"
  exit 1
}

$isElevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isElevated) { Write-Warn "This window runs as administrator. A normal double-click is enough; continuing anyway." }

$claudeHome = Join-Path $env:USERPROFILE '.claude'
New-Item -ItemType Directory -Force -Path $claudeHome | Out-Null
$notes = New-Object System.Collections.Generic.List[string]   # things the person should know at the end

# ---------------------------------------------------------------------------
# 1. Execution policy: loosen only a policy that blocks scripts; never touch a choice someone made.
# ---------------------------------------------------------------------------
Write-Step "PowerShell script policy"
$userPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($userPolicy -eq 'Undefined' -or $userPolicy -eq 'Restricted') {
  # Undefined falls back to Restricted on Windows clients, which blocks npm's npx.ps1 shim in their own terminals.
  try { Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction Stop } catch { Write-Verbose 'reported as overridden' }
  $now = Get-ExecutionPolicy -Scope CurrentUser
  if ($now -eq 'RemoteSigned') { Write-Ok "set to RemoteSigned for your account (was $userPolicy)" }
  else { Write-Warn "could not change it (still $now) - fine, the kit's launchers do not need it" }
} else {
  Write-Skip "already $userPolicy - leaving it"
}

# ---------------------------------------------------------------------------
# 2. Git and Node: check first; only what is missing goes to the elevated window.
# ---------------------------------------------------------------------------
Write-Step "Git and Node.js"
Update-SessionPath
$needGit   = -not (Test-Command 'git')
$nodeMajor = Get-NodeMajor
$needNode  = ($nodeMajor -eq 0) -and -not (Test-NodeVersionManager)

if (-not $needGit) { Write-Skip "git already installed: $(Get-ToolVersion 'git')" }
if ($nodeMajor -ge 24) { Write-Skip "node already installed: $(Get-ToolVersion 'node')" }
elseif ($nodeMajor -gt 0) {
  Write-Warn "node $(Get-ToolVersion 'node') is installed but GSD needs 24+. Leaving your Node alone; GSD is skipped."
  $notes.Add("GSD was not installed: your Node is older than 24. Ido can help you upgrade without breaking your projects.")
} elseif (-not $needNode) {
  Write-Warn "a Node version manager (nvm / Volta) is installed but no Node is active. Leaving it alone; GSD is skipped."
  $notes.Add("GSD was not installed: activate Node 24+ in your version manager, then double-click the installer again.")
}

if ($needGit -or $needNode) {
  $what = @(); if ($needGit) { $what += 'Git' }; if ($needNode) { $what += 'Node.js' }
  Write-Host "    Installing $($what -join ' and ') needs administrator rights." -ForegroundColor Yellow
  Write-Host "    Windows will ask 'Do you want to allow this app to make changes?' - click Yes." -ForegroundColor Yellow
  $childArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -AdminInstall"
  if ($needGit)  { $childArgs += ' -NeedGit' }
  if ($needNode) { $childArgs += ' -NeedNode' }
  try { $child = Start-Process -FilePath 'powershell.exe' -ArgumentList $childArgs -Verb RunAs -Wait -PassThru }
  catch { throw "The administrator window did not start (did you click No?). Double-click the installer again and click Yes." }
  if ($child.ExitCode -ne 0) { throw "Installing $($what -join ' and ') failed (see the other window)." }
  Update-SessionPath
}

# Installers put git / node on the Machine PATH; add a folder to the User PATH only if it still is not found.
$gitRoot = Get-GitRoot
if (-not (Test-Command 'git') -and $gitRoot) { Add-ToUserPath (Join-Path $gitRoot 'cmd') }
$nodeRoot = Join-Path $env:ProgramFiles 'nodejs'
if ($needNode -and -not (Test-Command 'node') -and (Test-Path $nodeRoot)) { Add-ToUserPath $nodeRoot }
if (-not (Test-Command 'git')) { throw "git is still not found after installing it" }
if ($needNode -and -not (Test-Command 'node')) { throw "node is still not found after installing it" }
$nodeMajor = Get-NodeMajor

# ---------------------------------------------------------------------------
# 3. Claude Code (per user, no admin, as Anthropic's docs say)
# ---------------------------------------------------------------------------
Write-Step "Claude Code"
$claudeBin = Join-Path $env:USERPROFILE '.local\bin'
if (Test-Command 'claude') {
  Write-Skip "claude already installed: $(Get-ToolVersion 'claude')"
} else {
  # Own PowerShell process: install.ps1 calls `exit 1` on failure, which would end THIS script if it
  # ran here through Invoke-Expression, and the fallbacks below would never be reached.
  Write-Host "    running Anthropic's installer (irm https://claude.ai/install.ps1 | iex) - no progress output, be patient"
  $exitCode = Invoke-InConsole 'powershell.exe' '-NoProfile -ExecutionPolicy Bypass -Command "irm https://claude.ai/install.ps1 | iex"'
  if ($exitCode -ne 0) { Write-Warn "Anthropic's installer exited with code $exitCode, trying the alternatives" }
  Update-SessionPath
  if (-not (Test-Command 'claude') -and (Test-Path (Join-Path $claudeBin 'claude.exe'))) { Add-ToUserPath $claudeBin }
  if (-not (Test-Command 'claude') -and (Test-Winget)) { $null = Install-WithWinget 'Anthropic.ClaudeCode'; Update-SessionPath }
  if (-not (Test-Command 'claude') -and $nodeMajor -gt 0) {
    Write-Host "    npm install -g @anthropic-ai/claude-code"
    $null = Invoke-Native { & npm.cmd install -g @anthropic-ai/claude-code }
    $npmGlobal = Join-Path $env:APPDATA 'npm'
    if (-not (Test-Command 'claude') -and (Test-Path $npmGlobal)) { Add-ToUserPath $npmGlobal }
  }
  if (-not (Test-Command 'claude')) { throw "Claude Code could not be installed by any method" }
  Write-Ok "claude $(Get-ToolVersion 'claude')"
}

# ---------------------------------------------------------------------------
# 4. Tell Claude Code where Git Bash is - only by creating settings.json when there is none. An existing
#    file is never rewritten: a JSON round-trip would drop comments, reorder keys and re-escape text,
#    and Claude Code finds Git Bash by itself anyway (the setting is only a fallback).
# ---------------------------------------------------------------------------
Write-Step "Claude Code settings (Git Bash path)"
$settingsPath = Join-Path $claudeHome 'settings.json'
$gitBash = if ($gitRoot) { Join-Path $gitRoot 'bin\bash.exe' } else { $null }
if (Test-Path $settingsPath) {
  Write-Skip "you already have $settingsPath - leaving it untouched"
} elseif (-not $gitBash) {
  Write-Warn "Git Bash not found in the usual folders - Claude Code will look for it itself"
} else {
  $json = @{ env = @{ CLAUDE_CODE_GIT_BASH_PATH = $gitBash } } | ConvertTo-Json -Depth 5
  # PS 5.1's Set-Content -Encoding UTF8 adds a BOM, which Node's JSON.parse (GSD's installer) rejects.
  [IO.File]::WriteAllText($settingsPath, $json, (New-Object Text.UTF8Encoding $false))
  Write-Ok "created $settingsPath"
}

# ---------------------------------------------------------------------------
# 5. GSD Core - only on a machine with no GSD at all. gsd-core's installer also cleans up older
#    get-shit-done installs, so it must never run where someone already uses GSD.
# ---------------------------------------------------------------------------
Write-Step "GSD Core"
$gsdCoreVersion = Join-Path $claudeHome 'gsd-core\VERSION'
$otherGsd       = Join-Path $claudeHome 'get-shit-done'
if ($SkipGsd) { Write-Skip "skipped (-SkipGsd)" }
elseif (Test-Path $gsdCoreVersion) { Write-Skip "GSD Core $(Get-Content $gsdCoreVersion) already installed" }
elseif (Test-Path $otherGsd) {
  Write-Skip "you already have GSD (get-shit-done) - leaving it exactly as it is"
  $notes.Add("You already had GSD, so the kit's GSD Core was not installed. Your /gsd-* commands work as before.")
}
elseif ($nodeMajor -lt 24) { Write-Skip "needs Node 24+ (see above)" }
else {
  $exitCode = Invoke-InConsole 'cmd.exe' '/c npx -y --package=@opengsd/gsd-core@1.19.0 -- gsd-core --claude --global'
  if ($exitCode -ne 0) {
    Write-Fail "GSD installer exited with code $exitCode."
    $notes.Add("GSD did not install. Double-click the installer again later, or ask Ido.")
  } elseif (Test-Path $gsdCoreVersion) { Write-Ok "GSD Core $(Get-Content $gsdCoreVersion) installed" }
  else { Write-Warn "GSD installer finished but $gsdCoreVersion is missing - check the output above" }
}

# ---------------------------------------------------------------------------
# 6. "Open Claude here" in the Explorer right-click menu (per user). Never replaces someone else's entry.
# ---------------------------------------------------------------------------
Write-Step "Right-click menu: Open Claude here"
$launcher = Join-Path $claudeHome 'claude-here.ps1'
Copy-Item -Force (Join-Path $PSScriptRoot 'claude-here.ps1') $launcher   # the kit's own file
Unblock-File $launcher
$menuCommand = "powershell.exe -NoExit -NoProfile -ExecutionPolicy Bypass -File `"$launcher`""
# Background = right-click empty space inside a folder (%V); Directory = right-click a folder icon (%1).
foreach ($entry in @(@{ Key = 'Directory\Background\shell\ClaudeCode'; Arg = '%V' },
                     @{ Key = 'Directory\shell\ClaudeCode';            Arg = '%1' })) {
  $key = "HKCU:\Software\Classes\$($entry.Key)"
  $existing = (Get-ItemProperty -Path "$key\command" -ErrorAction SilentlyContinue).'(default)'
  if ($existing -and $existing -notlike '*claude-here.ps1*') { Write-Skip "an entry named ClaudeCode already exists and is not ours - leaving it"; continue }
  New-Item -Force -Path "$key\command" | Out-Null
  Set-ItemProperty -Path $key -Name '(default)' -Value 'Open Claude here'
  Set-ItemProperty -Path "$key\command" -Name '(default)' -Value "$menuCommand `"$($entry.Arg)`""
}
Write-Ok "right-click a folder -> 'Open Claude here' (Windows 11: under 'Show more options')"

# ---------------------------------------------------------------------------
# 7. Your own copy of the kit (a git clone, so "git pull" updates it) + a desktop shortcut
# ---------------------------------------------------------------------------
Write-Step "Your copy of claude-jumpstart"

function Select-KitParentFolder {
  $default = $env:USERPROFILE
  try {
    Add-Type -AssemblyName System.Windows.Forms
    $owner  = New-Object System.Windows.Forms.Form -Property @{ TopMost = $true }  # keeps the dialog in front
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description  = "Choose where to put your claude-jumpstart folder (Cancel = $default)"
    $dialog.SelectedPath = $default
    if ($dialog.ShowDialog($owner) -eq [System.Windows.Forms.DialogResult]::OK) { return $dialog.SelectedPath }
  } catch { Write-Warn "folder picker unavailable, using $default" }
  return $default
}

$zipFolder = Split-Path -Parent $PSScriptRoot   # this installer lives in <kit>\install
$kitDir    = Join-Path (Select-KitParentFolder) 'claude-jumpstart'
if (Test-Path (Join-Path $kitDir '.git')) {
  Write-Host "    already there, updating: $kitDir"
  if ((Invoke-Native { & git -C $kitDir pull --ff-only }) -ne 0) { Write-Warn "could not update $kitDir (local changes?) - using it as it is" }
} elseif (Test-Path $kitDir) {
  Write-Skip "$kitDir exists and is not a git copy - leaving it alone"
} elseif ((Invoke-Native { & git clone $KitRepoUrl $kitDir }) -ne 0) {
  Write-Warn "git clone failed - you can keep using the folder you downloaded"
}
if (-not (Test-Path (Join-Path $kitDir '2-START-CLAUDE-SETUP.cmd'))) { $kitDir = $zipFolder }
if ($isElevated -and (Test-Path (Join-Path $kitDir '.git'))) {
  # An elevated clone is owned by Administrators; git would later refuse it as "dubious ownership".
  $safePath = $kitDir -replace '\\', '/'
  if ((Get-NativeOutput { & git config --global --get-all safe.directory }) -notcontains $safePath) {
    $null = Invoke-Native { & git config --global --add safe.directory $safePath }
  }
}
Write-Ok "kit folder: $kitDir"

$startFile    = Join-Path $kitDir '2-START-CLAUDE-SETUP.cmd'
$shortcutPath = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Claude setup.lnk'
$shell = New-Object -ComObject WScript.Shell
if (-not (Test-Path $startFile)) {
  Write-Warn "2-START-CLAUDE-SETUP.cmd not found in $kitDir - no desktop shortcut made"
} elseif ((Test-Path $shortcutPath) -and ($shell.CreateShortcut($shortcutPath).TargetPath -notlike '*2-START-CLAUDE-SETUP.cmd')) {
  Write-Skip "a 'Claude setup' shortcut that is not ours is already on the desktop - leaving it"
} else {
  $shortcut = $shell.CreateShortcut($shortcutPath)
  $shortcut.TargetPath       = $startFile
  $shortcut.WorkingDirectory = $kitDir
  $shortcut.Save()
  Write-Ok "desktop shortcut: 'Claude setup'"
}

# ---------------------------------------------------------------------------
# 8. Summary
# ---------------------------------------------------------------------------
Write-Step "Summary"
foreach ($tool in 'git', 'node', 'claude') {
  if (Test-Command $tool) { Write-Ok ("{0,-7} {1}" -f $tool, (Get-ToolVersion $tool)) } else { Write-Warn "$tool not found" }
}
foreach ($note in $notes) { Write-Warn $note }
Write-Host ""
Write-Host "ALL DONE - NEXT STEPS" -ForegroundColor Cyan
Write-Host "  1. Close this window."
Write-Host "  2. Double-click 'Claude setup' on your desktop (or 2-START-CLAUDE-SETUP.cmd in $kitDir)."
Write-Host "     The first time, a browser opens: log in with your Claude account."
Write-Host "     Claude then walks you through the rest, one question at a time."
Write-Host "  3. Later, for your own work: right-click your project folder -> 'Open Claude here'."
if ($kitDir -ne $zipFolder) { Write-Host "  The folder you downloaded is no longer needed; you can delete it." }
Write-Host ""
Read-Host "Press Enter to close this window"
exit 0
