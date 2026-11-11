<#
.SYNOPSIS
  One-shot Windows setup: Git for Windows (Git Bash) + Node.js LTS + Claude Code + GSD Core,
  plus an 'Open Claude here' entry in the Explorer right-click menu.

.DESCRIPTION
  Designed for a fresh Windows machine where nothing is on PATH yet.
  Every tool is installed, then its folder is written to the *User* PATH (persisted in the registry)
  AND added to the current session, so later steps in this same script can already see it.

  Order of preference for each tool:
    1. skip if already installed
    2. winget (if present and working)
    3. direct download from the vendor + silent install

.USAGE
  Easiest: double-click 1-INSTALL-WINDOWS.cmd in the repo root (it runs this file).

  Or: right-click PowerShell -> "Run as administrator", then:
    Set-ExecutionPolicy -Scope Process Bypass -Force
    .\setup-claude-windows.ps1

  Or from any PowerShell / cmd window:
    powershell -ExecutionPolicy Bypass -File .\setup-claude-windows.ps1

  Admin is needed for the Git and Node installers (they install to Program Files).
  If you are not admin, the script relaunches itself elevated (UAC prompt).

.NOTES
  Tested against PowerShell 5.1 syntax (the version that ships with Windows 10/11).
  After the script finishes: double-click 2-START-CLAUDE-SETUP.cmd (opens Claude with a fresh PATH).
#>

[CmdletBinding()]
param(
  [switch]$SkipGsd,         # install Git/Node/Claude only
  [string]$OriginalUser = $env:USERNAME,  # who double-clicked, passed through the elevation
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

# Guard: this script needs Windows PowerShell 5.1+ on 64-bit Windows 10/11. Say so plainly instead of
# failing halfway on a missing command.
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
$ProgressPreference    = 'SilentlyContinue'   # Invoke-WebRequest is 10x faster without the progress bar

# Fresh Windows ships with ExecutionPolicy=Restricted, which blocks Node's npm.ps1/npx.ps1 shims and
# any .ps1 a tool drops later. Bypass for this process; RemoteSigned for the user is the standard
# developer setting (local scripts run, downloaded ones must be signed).
# Both calls throw when a Group Policy (or the more specific Process scope we just set) overrides
# them, even though nothing is wrong; that must not stop the install.
try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force } catch { }
try { Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force } catch { }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ---------------------------------------------------------------------------
# Self-elevate (Git / Node MSI installers need admin)
# ---------------------------------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
           ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
  Write-Host "Not running as administrator - relaunching elevated..." -ForegroundColor Yellow
  $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
  if ($SkipGsd) { $argList += " -SkipGsd" }
  $argList += " -OriginalUser `"$env:USERNAME`""
  Write-Host "Windows will ask 'Do you want to allow this app to make changes?' - click Yes." -ForegroundColor Yellow
  Write-Host "The installation continues in a new blue window."
  Start-Process -FilePath "powershell.exe" -ArgumentList $argList -Verb RunAs
  exit
}

# If a different (admin) account approved the elevation, everything would install into THAT
# account's profile and PATH, and the person who double-clicked would see nothing.
if ($OriginalUser -and $OriginalUser -ne $env:USERNAME) {
  Write-Host ""
  Write-Host "STOP: this window runs as '$env:USERNAME', but '$OriginalUser' started the install." -ForegroundColor Red
  Write-Host "Claude would be installed for the wrong account. Ask Ido or IT to make '$OriginalUser' a local admin," -ForegroundColor Red
  Write-Host "or run the installer while logged in as an admin account you will use Claude from." -ForegroundColor Red
  Read-Host "Press Enter to close"
  exit 1
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
$DownloadDir = Join-Path $env:TEMP "claude-setup-downloads"
New-Item -ItemType Directory -Force -Path $DownloadDir | Out-Null

function Write-Step([string]$Text) {
  Write-Host ""
  Write-Host "==> $Text" -ForegroundColor Cyan
}

function Write-Ok([string]$Text)   { Write-Host "    [OK]   $Text" -ForegroundColor Green }
function Write-Warn([string]$Text) { Write-Host "    [WARN] $Text" -ForegroundColor Yellow }
function Write-Fail([string]$Text) { Write-Host "    [FAIL] $Text" -ForegroundColor Red }

# Runs an external program and returns its exit code. With ErrorActionPreference=Stop, PowerShell 5.1
# turns any stderr text from a native program (npm warnings, git progress) into a fatal error; this
# relaxes that for the one call and lets the exit code decide.
function Invoke-Native([scriptblock]$Command) {
  $previous = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { & $Command | Out-Host; return $LASTEXITCODE } finally { $ErrorActionPreference = $previous }
}

# First line of `<tool> --version`, or a note when it fails; never throws.
function Get-ToolVersion([string]$Name) {
  $previous = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { return [string](& $Name --version 2>&1 | Select-Object -First 1) } catch { return '(version check failed)' } finally { $ErrorActionPreference = $previous }
}

function Test-Command([string]$Name) {
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

# Rebuild the session PATH from the registry (Machine + User) so freshly installed tools resolve.
function Update-SessionPath {
  $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
  $user    = [Environment]::GetEnvironmentVariable('Path', 'User')
  $env:Path = ($machine, $user) -join ';'
}

# Persist a directory in the User PATH (registry) and in the current session.
function Add-ToUserPath([string]$Dir) {
  if (-not (Test-Path $Dir)) {
    Write-Warn "Not adding to PATH, folder does not exist: $Dir"
    return
  }
  $user  = [Environment]::GetEnvironmentVariable('Path', 'User')
  $parts = @()
  if ($user) { $parts = $user -split ';' | Where-Object { $_ -ne '' } }
  if ($parts -notcontains $Dir) {
    $newUser = (($parts + $Dir) -join ';')
    [Environment]::SetEnvironmentVariable('Path', $newUser, 'User')
    Write-Ok "Added to User PATH: $Dir"
  } else {
    Write-Ok "Already in User PATH: $Dir"
  }
  if (($env:Path -split ';') -notcontains $Dir) { $env:Path = "$env:Path;$Dir" }
}

function Get-File([string]$Url, [string]$OutFile) {
  Write-Host "    downloading $Url"
  Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing
  if (-not (Test-Path $OutFile) -or (Get-Item $OutFile).Length -lt 1024) {
    throw "Download failed or file is empty: $OutFile"
  }
}

# winget exists on most Windows 10/11 installs but is often broken on a fresh machine
# (App Installer not updated, no sources). Treat "present but not working" as absent.
function Test-Winget {
  if (-not (Test-Command 'winget')) { return $false }
  try {
    $null = & winget --version 2>&1
    return ($LASTEXITCODE -eq 0)
  } catch { return $false }
}

function Install-WithWinget([string]$Id) {
  Write-Host "    winget install $Id"
  $exitCode = Invoke-Native { & winget install --id $Id -e --silent --accept-package-agreements --accept-source-agreements }
  return ($exitCode -eq 0)
}

$HaveWinget = Test-Winget
if ($HaveWinget) { Write-Ok "winget is available" } else { Write-Warn "winget not available - will download installers directly" }

# ---------------------------------------------------------------------------
# 1. Git for Windows (provides Git Bash, which Claude Code uses for its Bash tool)
# ---------------------------------------------------------------------------
Write-Step "Git for Windows"
Update-SessionPath
if (Test-Command 'git') {
  Write-Ok "git already installed: $(Get-ToolVersion 'git')"
} else {
  $done = $false
  if ($HaveWinget) {
    try { $done = Install-WithWinget 'Git.Git' } catch { $done = $false }
    if (-not $done) { Write-Warn "winget install of Git failed, falling back to direct download" }
  }
  if (-not $done) {
    $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/git-for-windows/git/releases/latest' -UseBasicParsing
    $asset   = $release.assets | Where-Object { $_.name -like 'Git-*-64-bit.exe' } | Select-Object -First 1
    if (-not $asset) { throw "Could not find a 64-bit Git installer in the latest release" }
    $exe = Join-Path $DownloadDir $asset.name
    Get-File $asset.browser_download_url $exe
    # Inno Setup silent flags. PATHOPT=Cmd puts git on PATH (installer writes Machine PATH).
    $proc = Start-Process -FilePath $exe -ArgumentList '/VERYSILENT','/NORESTART','/NOCANCEL','/SP-','/CLOSEAPPLICATIONS','/RESTARTAPPLICATIONS','/o:PathOption=Cmd' -Wait -PassThru
    if ($proc.ExitCode -ne 0) { throw "Git installer exited with code $($proc.ExitCode)" }
  }
  Update-SessionPath
}

# Make sure Git is on the User PATH even if the installer did not write it.
$gitRoot = $null
foreach ($candidate in @("$env:ProgramFiles\Git", "${env:ProgramFiles(x86)}\Git", "$env:LOCALAPPDATA\Programs\Git")) {
  if (Test-Path (Join-Path $candidate 'bin\bash.exe')) { $gitRoot = $candidate; break }
}
if ($gitRoot) {
  Add-ToUserPath (Join-Path $gitRoot 'cmd')
  Add-ToUserPath (Join-Path $gitRoot 'bin')
  $GitBashPath = Join-Path $gitRoot 'bin\bash.exe'
  Write-Ok "Git Bash: $GitBashPath"
} else {
  Write-Warn "Git installed but bin\bash.exe was not found in the usual folders"
  $GitBashPath = $null
}

# ---------------------------------------------------------------------------
# 2. Node.js LTS (needed for npx -> GSD installer; also a fallback way to install Claude Code)
# ---------------------------------------------------------------------------
Write-Step "Node.js LTS"
Update-SessionPath
$nodeOk = $false
if (Test-Command 'node') {
  $v = (& node --version) -replace '^v',''
  $major = [int]($v -split '\.')[0]
  if ($major -ge 24) { $nodeOk = $true; Write-Ok "node already installed: v$v" }
  else { Write-Warn "node v$v is too old (need 24+), installing LTS" }
}
if (-not $nodeOk) {
  $done = $false
  if ($HaveWinget) {
    try { $done = Install-WithWinget 'OpenJS.NodeJS.LTS' } catch { $done = $false }
    if (-not $done) { Write-Warn "winget install of Node failed, falling back to direct download" }
  }
  if (-not $done) {
    $nodeArch = 'x64'
    if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { $nodeArch = 'arm64' }
    $index = Invoke-RestMethod -Uri 'https://nodejs.org/dist/index.json' -UseBasicParsing
    $lts   = $index | Where-Object { $_.lts } | Select-Object -First 1
    if (-not $lts) { throw "Could not determine the current Node LTS version" }
    $ver = $lts.version                         # e.g. v24.22.1
    $msi = Join-Path $DownloadDir "node-$ver-$nodeArch.msi"
    Get-File "https://nodejs.org/dist/$ver/node-$ver-$nodeArch.msi" $msi
    $proc = Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i',"`"$msi`"",'/qn','/norestart' -Wait -PassThru
    if ($proc.ExitCode -ne 0 -and $proc.ExitCode -ne 3010) { throw "Node MSI exited with code $($proc.ExitCode)" }
  }
  Update-SessionPath
}

# node.exe lives in Program Files\nodejs; globally installed npm packages (npx cache, claude if
# installed via npm, gsd) go to %APPDATA%\npm. Both must be on the User PATH.
$nodeRoot = Join-Path $env:ProgramFiles 'nodejs'
if (Test-Path $nodeRoot) { Add-ToUserPath $nodeRoot }
$npmGlobal = Join-Path $env:APPDATA 'npm'
New-Item -ItemType Directory -Force -Path $npmGlobal | Out-Null
Add-ToUserPath $npmGlobal

if (-not (Test-Command 'node')) { throw "node still not on PATH after install - open a new terminal and rerun" }
Write-Ok "node $(Get-ToolVersion 'node'), npm $(Get-ToolVersion 'npm.cmd')"

# ---------------------------------------------------------------------------
# 3. Claude Code
# ---------------------------------------------------------------------------
Write-Step "Claude Code"
Update-SessionPath
$claudeBin = Join-Path $env:USERPROFILE '.local\bin'   # where the native installer puts claude.exe
if (Test-Command 'claude') {
  Write-Ok "claude already installed: $(& claude --version)"
} else {
  $done = $false
  # (a) native installer - recommended by Anthropic, auto-updates in the background
  # Run it in its own PowerShell: install.ps1 calls `exit 1` on failure, which would end THIS script
  # if it ran here via Invoke-Expression, and the winget/npm fallbacks would never be reached.
  Write-Host "    running Anthropic's installer (irm https://claude.ai/install.ps1 | iex) - no progress output, be patient"
  $exitCode = Invoke-Native { & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "irm https://claude.ai/install.ps1 | iex" }
  if ($exitCode -ne 0) { Write-Warn "native installer exited with code $exitCode" }
  if (Test-Path $claudeBin) { Add-ToUserPath $claudeBin }
  $done = Test-Command 'claude'

  # (b) winget
  if (-not $done -and $HaveWinget) {
    try { $done = Install-WithWinget 'Anthropic.ClaudeCode' } catch { $done = $false }
    Update-SessionPath
    if ($done) { $done = Test-Command 'claude' }
    if (-not $done) { Write-Warn "winget install of Claude Code failed" }
  }
  # (c) npm
  if (-not $done) {
    Write-Host "    npm install -g @anthropic-ai/claude-code"
    $null = Invoke-Native { & npm.cmd install -g @anthropic-ai/claude-code }
    Update-SessionPath
    $done = Test-Command 'claude'
  }
  if (-not $done) { throw "Claude Code could not be installed by any method" }
}
if (Test-Path $claudeBin) { Add-ToUserPath $claudeBin }
Write-Ok "claude $(Get-ToolVersion 'claude')"

# ---------------------------------------------------------------------------
# 4. Tell Claude Code where Git Bash is (settings.json -> env.CLAUDE_CODE_GIT_BASH_PATH)
# ---------------------------------------------------------------------------
Write-Step "Claude Code settings"
$claudeHome   = Join-Path $env:USERPROFILE '.claude'
$settingsPath = Join-Path $claudeHome 'settings.json'
New-Item -ItemType Directory -Force -Path $claudeHome | Out-Null
if ($GitBashPath) {
  $settings = @{}
  if (Test-Path $settingsPath) {
    try { $settings = Get-Content -Raw $settingsPath | ConvertFrom-Json } catch { Write-Warn "settings.json unreadable, rewriting it" }
  }
  # ConvertFrom-Json gives PSCustomObject; copy into a hashtable we can edit freely.
  $table = @{}
  if ($settings -is [System.Management.Automation.PSCustomObject]) {
    foreach ($p in $settings.PSObject.Properties) { $table[$p.Name] = $p.Value }
  }
  $envTable = @{}
  if ($table.ContainsKey('env') -and $table['env']) {
    foreach ($p in $table['env'].PSObject.Properties) { $envTable[$p.Name] = $p.Value }
  }
  $envTable['CLAUDE_CODE_GIT_BASH_PATH'] = $GitBashPath
  $table['env'] = $envTable
  # Set-Content -Encoding UTF8 on PowerShell 5.1 writes a BOM, which Node's JSON.parse (GSD's installer) rejects.
  [IO.File]::WriteAllText($settingsPath, ($table | ConvertTo-Json -Depth 10), (New-Object Text.UTF8Encoding $false))
  Write-Ok "CLAUDE_CODE_GIT_BASH_PATH = $GitBashPath  ($settingsPath)"
} else {
  Write-Warn "Git Bash not found - Claude Code will fall back to its PowerShell tool"
}

# ---------------------------------------------------------------------------
# 5. GSD Core (@opengsd/gsd-core) - installed globally into %USERPROFILE%\.claude
# ---------------------------------------------------------------------------
if ($SkipGsd) {
  Write-Step "GSD skipped (-SkipGsd)"
} else {
  Write-Step "GSD Core (@opengsd/gsd-core) global install"
  Update-SessionPath
  # npx is npx.cmd on Windows; calling through cmd avoids PowerShell quoting surprises.
  $exitCode = Invoke-Native { & cmd.exe /c "npx -y --package=@opengsd/gsd-core@1.19.0 -- gsd-core --claude --global" }
  if ($exitCode -ne 0) {
    Write-Fail "GSD installer exited with code $exitCode. Rerun later with:"
    Write-Host "      npx -y --package=@opengsd/gsd-core@1.19.0 -- gsd-core --claude --global"
  } else {
    $gsdVersionFile = Join-Path $claudeHome 'gsd-core\VERSION'
    if (Test-Path $gsdVersionFile) { Write-Ok "GSD Core $(Get-Content $gsdVersionFile) installed in $claudeHome" }
    else { Write-Warn "GSD installer finished but $gsdVersionFile is missing - check the output above" }
  }
}

# ---------------------------------------------------------------------------
# 6. "Open Claude here" in the Explorer right-click menu (per user, no terminal needed)
# ---------------------------------------------------------------------------
Write-Step "Right-click menu: Open Claude here"
$launcher = Join-Path $claudeHome 'claude-here.ps1'
Copy-Item -Force (Join-Path $PSScriptRoot 'claude-here.ps1') $launcher
Unblock-File $launcher   # drop the downloaded-from-internet mark the ZIP gave it
$menuCommand = "powershell.exe -NoExit -NoProfile -ExecutionPolicy Bypass -File `"$launcher`""
# Background = right-click empty space inside a folder (%V); Directory = right-click a folder icon (%1).
foreach ($entry in @(@{ Key = 'Directory\Background\shell\ClaudeCode'; Arg = '%V' },
                     @{ Key = 'Directory\shell\ClaudeCode';            Arg = '%1' })) {
  $key = "HKCU:\Software\Classes\$($entry.Key)"
  New-Item -Force -Path "$key\command" | Out-Null
  Set-ItemProperty -Path $key -Name '(default)' -Value 'Open Claude here'
  Set-ItemProperty -Path "$key\command" -Name '(default)' -Value "$menuCommand `"$($entry.Arg)`""
}
Write-Ok "Right-click any folder (or empty space inside one) -> 'Open Claude here'"
Write-Host "    On Windows 11 it is under 'Show more options'."

# ---------------------------------------------------------------------------
# 7. Your own copy of the kit: a git clone (so "git pull" updates it) + a desktop shortcut
# ---------------------------------------------------------------------------
Write-Step "Your copy of claude-jumpstart"
Update-SessionPath

# Ask where to put it with a normal folder picker; the default is the user's home folder.
function Select-KitParentFolder {
  $default = $env:USERPROFILE
  try {
    Add-Type -AssemblyName System.Windows.Forms
    $owner  = New-Object System.Windows.Forms.Form -Property @{ TopMost = $true }  # keeps the dialog in front
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description  = "Choose where to put your claude-jumpstart folder (Cancel = $default)"
    $dialog.SelectedPath = $default
    if ($dialog.ShowDialog($owner) -eq [System.Windows.Forms.DialogResult]::OK) { return $dialog.SelectedPath }
  } catch {
    Write-Warn "folder picker unavailable, using $default"
  }
  return $default
}

$kitDir = Join-Path (Select-KitParentFolder) 'claude-jumpstart'
if (Test-Path (Join-Path $kitDir '.git')) {
  Write-Host "    already there, updating: $kitDir"
  $exitCode = Invoke-Native { & git -C $kitDir pull --ff-only }
  if ($exitCode -ne 0) { Write-Warn "could not update $kitDir (local changes?) - using it as it is" }
} elseif (Test-Path $kitDir) {
  Write-Warn "$kitDir exists but is not a git copy - leaving it alone"
} else {
  $exitCode = Invoke-Native { & git clone $KitRepoUrl $kitDir }
  if ($exitCode -ne 0) { Write-Warn "git clone failed (exit $exitCode) - you can keep using the ZIP folder" }
}
if (Test-Path (Join-Path $kitDir '.git')) {
  # This window runs elevated, so Windows records Administrators as the folder owner; git would then
  # refuse the folder later with "dubious ownership". Mark it safe for this user.
  $null = Invoke-Native { & git config --global --add safe.directory ($kitDir -replace '\\', '/') }
  Write-Ok "kit folder: $kitDir"
} else {
  $kitDir = Split-Path -Parent $PSScriptRoot   # fall back to the folder this installer runs from
}

$shortcutPath = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Claude setup.lnk'
$shell    = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath       = Join-Path $kitDir '2-START-CLAUDE-SETUP.cmd'
$shortcut.WorkingDirectory = $kitDir
$shortcut.Save()
Write-Ok "desktop shortcut: 'Claude setup'"

# ---------------------------------------------------------------------------
# 7. Summary
# ---------------------------------------------------------------------------
Write-Step "Summary"
Update-SessionPath
foreach ($tool in 'git','node','npm.cmd','claude') {
  if (Test-Command $tool) { Write-Ok ("{0,-7} {1}" -f $tool, (Get-ToolVersion $tool)) }
  else                    { Write-Fail "$tool not found on PATH" }
}
Write-Host ""
Write-Host "User PATH now contains:" -ForegroundColor Cyan
([Environment]::GetEnvironmentVariable('Path','User') -split ';') | Where-Object { $_ } | ForEach-Object { Write-Host "    $_" }
Write-Host ""
Write-Host "ALL DONE - NEXT STEPS" -ForegroundColor Cyan
Write-Host "  1. Close this window."
Write-Host "  2. Double-click 'Claude setup' on your desktop (or 2-START-CLAUDE-SETUP.cmd in $kitDir)."
Write-Host "     The first time, a browser opens: log in with your Claude account."
Write-Host "     Claude then walks you through the rest, one question at a time."
Write-Host "  3. Later, for your own work: right-click your project folder -> 'Open Claude here'."
Write-Host "  The ZIP you downloaded is no longer needed; you can delete it."
Write-Host ""
Read-Host "Press Enter to close this window"
exit 0
