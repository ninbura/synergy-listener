function CreateLogFileIfNotExists(){
  if(!(Test-Path "$(Split-Path $PSScriptRoot)/synergy-listener.log")) {
    New-Item -ItemType File -Path "$(Split-Path $PSScriptRoot)/synergy-listener.log" -Force
  }
}

function WriteToLog($append, $prepend = ""){
  $logMessage = "$prepend[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] $append"
  Add-Content -Path "$(Split-Path $PSScriptRoot)/synergy-listener.log" -Value $logMessage
}

function Quit(){
  WriteToLog("Synergy listener stopped.")
  exit
}

function ValidateConfigurationProperties($config){
  $synergyLogPath = $($config)?.SynergyLogPath
  $outputFileDirectory = $($config)?.OutputFileDirectory

  if(!$synergyLogPath) {
    WriteToLog("Synergy log path not specified in configuration file.")
    
    Quit
  }

  if(!$outputFileDirectory) {
    WriteToLog("Output file path not specified in configuration file.")
    
    Quit
  }

  if(!(Test-Path $synergyLogPath)) {
    WriteToLog("Provided synergy log path does not exist: $synergyLogPath")
    
    Quit
  }

  if(!(Test-Path $outputFileDirectory)) {
    WriteToLog("Provided output file path does not exist: $outputFileDirectory")
    
    Quit
  }
}

function ValidateAndGetConfiguration(){
  if(!(Test-Path "$(Split-Path $PSScriptRoot)/config.json")) {
    WriteToLog("Configuration file does not exist.")

    Quit
  }

  try {
    $config = Get-Content -Path "$(Split-Path $PSScriptRoot)/config.json" | ConvertFrom-Json
  } catch {
    WriteToLog("Error reading configuration file.")
    
    Quit
  }
  
  ValidateConfigurationProperties($config)

  return $config
}

function CreateOutputFileIfNotExists($outputFileDirectory){
  $outputFilePath = "$outputFileDirectory/current-computer.txt"

  if(!(Test-Path $outputFilePath)) {
    New-Item -ItemType File -Path $outputFilePath -Force

    WriteToLog("Output file created at $outputFilePath.")
  } 
  else {
    WriteToLog("Output file already exists at $outputFilePath.")
  }
}

function extractComputerNameFromLogLine($line){
  $computer = [regex]::match($line, '(?<=to\s")[a-z0-9]+(?!>-)').value

  return $computer
}

function GetCurrentComputerNameFromSynergyLog($synergyLogPath){
  $endOfSynergyLog = Get-Content -path $synergyLogPath -tail 5
  [array]::Reverse($endOfSynergyLog)

  if($null -eq $endOfSynergyLog) { 
    return 
  }

  $currentComputer = ""

  foreach($line in $endOfSynergyLog) {
    if($line.ToLower() -notmatch "switch from") { 
      continue 
    }
    
    $currentComputer = extractComputerNameFromLogLine $line
    
    break
  }

  return $currentComputer
}

function updateOutputFileIfComputerHasChanged($outputFileDirectory, $currentComputer){
  if($currentComputer -eq "") {
    return 
  }

  $outputFilePath = "$outputFileDirectory/current-computer.txt"
  $previousComputer = Get-Content -Path $outputFilePath
  $displayPreviousComputer = !$previousComputer ? "[none]" : $previousComputer

  if($currentComputer -ne $previousComputer){
    Out-File -FilePath $outputFilePath -InputObject $currentComputer 
    WriteToLog("Computer changed from $displayPreviousComputer to $currentComputer.")
  }
}

function ListenForSynergyLogChanges($config){
  $synergyLogPath = $config.SynergyLogPath
  $outputFileDirectory = $config.OutputFileDirectory
  $lastWriteTime = [DateTime]::MinValue

  while($true){
    start-sleep -Milliseconds 50

    $newWriteTime = (Get-Item $synergyLogPath).LastWriteTime

    if($lastWriteTime -eq $newWriteTime) { 
      continue 
    }

    $lastWriteTime = $newWriteTime

    $currentComputer = GetCurrentComputerNameFromSynergyLog $synergyLogPath
    updateOutputFileIfComputerHasChanged $outputFileDirectory $currentComputer
  }
}

function main() {
  CreateLogFileIfNotExists
  WriteToLog "Synergy listener started." "`n`n`n"
  $config = ValidateAndGetConfiguration
  CreateOutputFileIfNotExists $config.OutputFileDirectory
  ListenForSynergyLogChanges $config
}

main
