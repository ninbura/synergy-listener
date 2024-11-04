function CreateLogFileIfNotExists()
{
  if (!(Test-Path "$(Split-Path $PSScriptRoot)/synergy-listener.log"))
  {
    New-Item -ItemType File -Path "$(Split-Path $PSScriptRoot)/synergy-listener.log" -Force
  }
}

function WriteToLog($Append, $Prepend = "")
{
  $logMessage = "$Prepend[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] $Append"
  Add-Content -Path "$(Split-Path $PSScriptRoot)/synergy-listener.log" -Value $logMessage
}

function Quit()
{
  WriteToLog("Synergy listener stopped.")
  exit
}

function PrintUserConfiguration($Config)
{
  WriteToLog("----------- User configuration -----------")
  WriteToLog("Synergy log path: $($Config.SynergyLogPath)")
  WriteToLog("Output file directory: $($Config.OutputFileDirectory)")
  WriteToLog("Retry on failure: $($Config.RetryOnFailure)")
  WriteToLog("------- End of user configuration. -------")
}

function ValidateConfigurationProperties($Config, $SkipIrrelevantValidation = $false)
{
  $synergyLogPath = $($Config)?.SynergyLogPath
  $outputFileDirectory = $($Config)?.OutputFileDirectory
  $retryOnFailure = $($Config)?.RetryOnFailure

  if (!$SkipIrrelevantValidation)
  {
    if (!$synergyLogPath)
    {
      WriteToLog("Synergy log path not specified in configuration file.")
      
      Quit
    }
    elseif (!$outputFileDirectory)
    {
      WriteToLog("Output file path not specified in configuration file.")
      
      Quit
    }
  }

  while ($true)
  {
    if (!(Test-Path $synergyLogPath))
    {
      WriteToLog("Provided synergy log path does not exist: $synergyLogPath")
      
      if (!$retryOnFailure) { Quit }
    }
    elseif (!(Test-Path $outputFileDirectory))
    {
      WriteToLog("Provided output file path does not exist: $outputFileDirectory")
      
      if (!$retryOnFailure) { Quit }
    }
    else { break }

    if ($retryOnFailure)
    {
      WriteToLog("Retrying in 5 seconds...")
      Start-Sleep -Seconds 5
    }
  }
}

function ValidateAndGetConfiguration()
{
  if(!(Test-Path "$(Split-Path $PSScriptRoot)/config.json"))
  {
    WriteToLog("Configuration file does not exist.")

    Quit
  }

  try { $config = Get-Content -Path "$(Split-Path $PSScriptRoot)/config.json" | ConvertFrom-Json} 
  catch 
  {
    WriteToLog("Error reading configuration file.")
    
    Quit
  }
  
  ValidateConfigurationProperties $config

  return $config
}

function CreateOutputFileIfNotExists($OutputFileDirectory)
{
  $outputFilePath = "$OutputFileDirectory/current-computer.txt"

  if (!(Test-Path $outputFilePath))
  {
    New-Item -ItemType File -Path $outputFilePath -Force

    WriteToLog("Output file created at $outputFilePath.")
  } 
  else { WriteToLog("Output file already exists at $outputFilePath.") }
}

function extractComputerNameFromLogLine($Line)
{
  $computer = [regex]::match($Line, '(?<=to\s")[a-z0-9]+(?!>-)').value

  return $computer
}

function GetCurrentComputerNameFromSynergyLog($Config)
{
  $synergyLogPath = $Config.SynergyLogPath

  try { $endOfSynergyLog = Get-Content -Path $synergyLogPath -Tail 15 -ErrorAction Stop }
  catch
  {
    WriteToLog("Error reading synergy log file, revalidating configuration.")

    ValidateConfigurationProperties -Config $Config -SkipIrrelevantValidation $true
    
    return ""
  }

  [array]::Reverse($endOfSynergyLog)

  if ($null -eq $endOfSynergyLog) { return }

  $currentComputer = ""

  foreach($line in $endOfSynergyLog) 
  {
    if ($line.ToLower() -notmatch "switch from") { 
      continue 
    }
    
    $currentComputer = extractComputerNameFromLogLine $line
    
    break
  }

  return $currentComputer
}

function UpdateOutputFileIfComputerHasChanged($Config, $CurrentComputer)
{
  if ($CurrentComputer -eq "") { return }

  $outputFileDirectory = $Config.OutputFileDirectory
  $outputFilePath = "$outputFileDirectory/current-computer.txt"

  try { $previousComputer = Get-Content -Path $outputFilePath -ErrorAction Stop }
  catch
  {
    WriteToLog("Error reading output file, revalidating configuration.")

    ValidateConfigurationProperties -Config $Config -SkipIrrelevantValidation $true
    
    return
  }
  
  $displayPreviousComputer = !$previousComputer ? "[none]" : $previousComputer

  if ($CurrentComputer -ne $previousComputer){
    try { New-Item -ItemType File -Path $outputFilePath -Value $CurrentComputer -Force }
    catch 
    {
      WriteToLog("Error writing to output file, revalidating configuration.")

      ValidateConfigurationProperties -Config $Config -SkipIrrelevantValidation $true
      
      return
    }

    WriteToLog("Computer changed from $displayPreviousComputer to $CurrentComputer.")
  }
}

function ListenForSynergyLogChanges($config)
{
  $synergyLogPath = $config.SynergyLogPath
  $lastWriteTime = [DateTime]::MinValue

  while($true){
    Start-Sleep -Milliseconds 50

    try { $newWriteTime = (Get-Item $synergyLogPath).LastWriteTime }
    catch
    {
      WriteToLog("Error reading synergy log file, revalidating configuration.")

      ValidateConfigurationProperties -Config $config -SkipIrrelevantValidation $true
      
      continue
    }

    if ($lastWriteTime -eq $newWriteTime) { continue }

    $lastWriteTime = $newWriteTime

    $currentComputer = GetCurrentComputerNameFromSynergyLog $config
    UpdateOutputFileIfComputerHasChanged -Config $config -CurrentComputer $currentComputer
  }
}

function Main()
{
  CreateLogFileIfNotExists
  WriteToLog -Prepend "`n`n`n" -Append "Synergy listener started."
  $config = ValidateAndGetConfiguration
  PrintUserConfiguration $config
  CreateOutputFileIfNotExists $config.OutputFileDirectory
  ListenForSynergyLogChanges $config
}

Main