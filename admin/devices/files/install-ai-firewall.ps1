<#
.SYNOPSIS
  Installs the AI Firewall agent on Windows and joins the computer to your workspace.

.DESCRIPTION
  Run as administrator, or as the system account (a startup script, Intune, or another deployment tool).
  It does nothing if AI Firewall is already installed.

  NOT YET TESTED ON A PILOT COMPUTER. Try it on one computer before you deploy it widely.

.PARAMETER InstallerPath
  Full path of AI-Firewall-<version>-x64.exe (a local path or a share the computer account can read).

.PARAMETER FleetUrl
  The address of your server. Must start with https://

.PARAMETER EnrollmentKey
  The device enrolment key from your server setup. Keep this script where only computer accounts can read it.

.EXAMPLE
  .\install-ai-firewall.ps1 -InstallerPath C:\Temp\AI-Firewall-2.2.7-x64.exe -FleetUrl https://ai-firewall.example.com -EnrollmentKey <key>

.NOTES
  Exit code 0: installed, or already installed. Exit code 1: failed.
  The installer's own code 3 (installed, with a warning) is treated as success and is reported.
#>
param(
  [Parameter(Mandatory = $true)][string]$InstallerPath,
  [Parameter(Mandatory = $true)][string]$FleetUrl,
  [Parameter(Mandatory = $true)][string]$EnrollmentKey
)

$ErrorActionPreference = 'Stop'
# A 32-bit PowerShell sees Program Files (x86) in ProgramFiles. ProgramW6432 is the 64-bit folder.
$programFiles = if ($env:ProgramW6432) { $env:ProgramW6432 } else { $env:ProgramFiles }
$installedExe = Join-Path $programFiles 'AI Firewall\AI Firewall.exe'

if (Test-Path $installedExe) {
  Write-Output 'AI Firewall is already installed. Nothing to do.'
  exit 0
}

if ($FleetUrl -notmatch '^https://[^\s"]+$') {
  Write-Error 'FleetUrl must be a full address that starts with https://'
  exit 1
}
if ($EnrollmentKey -match '[\s"]') {
  Write-Error 'EnrollmentKey must not contain spaces or quotes.'
  exit 1
}
if (-not (Test-Path $InstallerPath)) {
  Write-Error "Installer not found: $InstallerPath"
  exit 1
}

# Both switches are needed. If only one is given, the installer ignores both.
$arguments = @('/S', "/FLEET_URL=`"$FleetUrl`"", "/ENROLL_TOKEN=`"$EnrollmentKey`"")

$process = Start-Process -FilePath $InstallerPath -ArgumentList $arguments -Wait -PassThru -WindowStyle Hidden
$code = $process.ExitCode

switch ($code) {
  0 { Write-Output 'AI Firewall installed.'; exit 0 }
  3 { Write-Warning 'AI Firewall installed, but the install folder was not locked down (installer code 3). Reinstall into the default folder.'; exit 0 }
  default { Write-Error "The installer returned code $code."; exit 1 }
}
