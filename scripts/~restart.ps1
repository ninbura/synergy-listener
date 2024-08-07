function Quit() {
  Write-Host "Synergy Listener has been restarted, press [enter] to exit."
  $Host.UI.ReadLine()

  exit
}

function Main() {
  Write-Host "Restarting Synergy Listener..."
  Write-Host "Stopping Synergy Listener..."

  Stop-ScheduledTask -TaskName "synergy-listener"

  Get-Process | Where-Object { $_.Path -like "*synergy-listener.ps1" } | Stop-Process -Force

  Write-Host "Synergy Listener stopped."
  Write-Host "Starting Synergy Listener..."

  Start-ScheduledTask -TaskName "synergy-listener"

  Write-Host "Synergy Listener started."

  Quit
}

main