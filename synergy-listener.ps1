param(
  [string]$logPath = "\\192.168.2.3\a-sexy-desktop\ProgramData\Synergy\logs\synergy.log",
  [string]$outputFilePath = "\\192.168.2.4\a-sexy-capturer\Users\gabri\Documents"
)

function checkIfLogHasUpdated(){
  $logHasUpdated = $lastWriteTime -lt (Get-Item $logPath).LastWriteTime

  if($logHasUpdated) {
    $global:lastWriteTime = (Get-Item $logPath).LastWriteTime
  }

  return $logHasUpdated
}

function getEndOfSynergyLog(){
  $logFileExists = test-path $logPath

  if($logFileExists){
    $endOfSynergyLog = Get-Content $logPath | Select-Object -Last 5

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

function listenForSynergyLogChanges(){
  $firstLoop = $true

  while($true){
    start-sleep -Milliseconds 50

    if(!(checkIfLogHasUpdated) -and !$firstLoop) { 
      continue 
    }

    $firstLoop = $false

    $endOfSynergyLog = getEndOfSynergyLog

    if($null -eq $endOfSynergyLog) { continue }
  
    :inner
    foreach($line in $endOfSynergyLog) {
      if($line -match "switch from") {
        $currentComputer = extractComputerNameFromLogLine $line

        if(checkIfComputerHasChanged $currentComputer){
          Out-File -FilePath "$outputFilePath\current-computer.txt" -InputObject $currentComputer 
        }
        
        break inner
      }
    }
  }
}

$lastWriteTime = (Get-Item $logPath).LastWriteTime
listenForSynergyLogChanges 