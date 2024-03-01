function Quit(){
  Write-Host "Install process complete, press [enter] to exit."
  $Host.UI.ReadLine()

  exit
}

function main() {
  Write-Host "Uninstalling Synergy Listener..."

  $synergyListenerTask = Get-ScheduledTask -TaskName "synergy-listener" -ErrorAction SilentlyContinue

  if(!$synergyListenerTask) {
    Write-Host "Synergy Listener not installed."
      Quit
  }

  Stop-ScheduledTask -TaskName "synergy-listener"
  Unregister-ScheduledTask -TaskName "synergy-listener" -Confirm:$false

  Write-Host "Synergy Listener uinstalled."

  Quit
}

main
