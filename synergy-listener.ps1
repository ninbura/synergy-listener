param(
  [string]$logPath = "\\192.168.2.3\synergy-host-logs\synergy.log", # host's log path
  [string]$outputFilePath = "\\192.168.3.4\a-sexy-capturer\Users\$env:username\Documents"
)

function checkIfLogHasUpdated(){
  $logHasUpdated = $lastWriteTime -lt (Get-Item $logPath).LastWriteTime

  if($logHasUpdated) {
    $global:lastWriteTime = (Get-Item $logPath).LastWriteTime
  }

  return $logHasUpdated
}

function getEndOfSynergyLog(){
  if(test-path $logPath){
    $endOfSynergyLog = Get-Content -path $logPath -tail 5

    [array]::Reverse($endOfSynergyLog)
  }

  return $endOfSynergyLog
}

function extractComputerNameFromLogLine($line){
  $computer = [regex]::match($line, '(?<=to\s")[a-z0-9]+(?!>-)').value

  return $computer
}

function checkIfComputerHasChanged($currentComputer){
  if(test-path "$outputFilePath\current-computer.txt"){
    $previousComputer = Get-Content "$outputFilePath\current-computer.txt"
  }

  return $currentComputer -ne $previousComputer
}

function updateTxtIfComputerHasChanged($currentComputer){
  if(checkIfComputerHasChanged $currentComputer -and test-path $outputFilePath){
    Out-File -FilePath "$outputFilePath\current-computer.txt" -InputObject $currentComputer 
  }
}

function parseSynergyLog(){
  $endOfSynergyLog = getEndOfSynergyLog

  if($null -eq $endOfSynergyLog) { return }

  foreach($line in $endOfSynergyLog) {
    if($line -notmatch "switch from") { continue }
    
    $currentComputer = extractComputerNameFromLogLine $line

    updateTxtIfComputerHasChanged $currentComputer
      
    break
  } 
}

function listenForSynergyLogChanges(){
  $firstLoop = $true

  while($true){
    start-sleep -Milliseconds 50

    if(!(checkIfLogHasUpdated) -and !$firstLoop) { 
      continue 
    }

    $firstLoop = $false

    parseSynergyLog
  }
}

$lastWriteTime = (Get-Item $logPath).LastWriteTime
listenForSynergyLogChanges 
