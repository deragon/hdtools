#!/cygdrive/c/windows/System32/WindowsPowerShell/v1.0/powershell -File

# ─ Copyright Notice ───────────────────────────────────────────────────
#
# Copyright 2000-2024 Hans Deragon - AGPL 3.0 licence.
#
# Hans Deragon (hans@deragon.biz) owns the copyright of this work.  It is
# released under the GNU Affero General public Picense which can be found at:
#
#     https://www.gnu.org/licenses/agpl-3.0.en.html
#
# ─────────────────────────────────────────────────── Copyright Notice ─

# Read:  https://stackoverflow.com/questions/48216173/how-can-i-use-a-shebang-in-a-powershell-script

# From:  https://www.ucunleashed.com/3116
#
#   Enabling Mapped Drives in Elevated PowerShell Sessions
#
#   If you’ve worked with mapped drives in PowerShell sessions, you know it’s
#   problematic to access mapped drives from an elevated PowerShell session
#   when UAC is configured to prompt to prompt for credentials.


if (-not (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name EnableLinkedConnections)) {
2
  $null = New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name EnableLinkedConnections -Value 1 -PropertyType 'DWord'
3
}
