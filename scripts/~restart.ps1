function Quit() {
  Write-Host "Synergy Listener has been restarted, press [enter] to exit."
  $Host.UI.ReadLine()

  exit
}

function Main() {
  Write-Host "Restarting Synergy Listener..."
  Write-Host "Stopping Synergy Listener..."
  stop-scheduledtask -taskname "synergy-listener"
  Write-Host "Synergy Listener stopped."
  Write-Host "Starting Synergy Listener..."
  start-scheduledtask -taskname "synergy-listener"
  Write-Host "Synergy Listener started."

  Quit
}

main
