function Quit() {
  Write-Host "Install process complete, press [enter] to exit."
  $Host.UI.ReadLine()

  exit
}

function main() {
  Write-Host "Installing Synergy Listener..."

  $synergyListenerTask = Get-ScheduledTask -TaskName "synergy-listener" -ErrorAction SilentlyContinue

  if($synergyListenerTask) {
    Write-Host "Synergy Listener already installed."
    Quit
  }

  Register-ScheduledTask `
    -TaskName "synergy-listener" `
    -Trigger (New-ScheduledTaskTrigger -AtLogon) `
    -Action (New-ScheduledTaskAction -Execute "pwsh" -Argument "-WindowStyle Hidden -Command `"& $PSScriptRoot/synergy-listener.ps1`"") `
    -RunLevel Highest `
    -Force

  Write-Host "Synergy Listener installed."
  Write-Host "Starting Synergy Listener..."

  Start-ScheduledTask -TaskName "synergy-listener"

  Write-Host "Synergy Listener started."

  Quit
}

main
