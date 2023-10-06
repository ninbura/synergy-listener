# synergy-listener

### 1. install the latest powershell

- winget install microsoft.powershell

### 2. clone this repository into c:/repos

### 3. run the following command in the latest powershell

- ```powershell
  Register-ScheduledTask -TaskName "synergy-listener" -Trigger (New-ScheduledTaskTrigger -AtLogon) -Action (New-ScheduledTaskAction -Execute "pwsh" -Argument "-WindowStyle Hidden -Command `"& c:/repos/synergy-listener/synergy-listener.ps1`"") -RunLevel Highest -Force;
  ```
