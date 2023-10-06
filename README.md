# setup task

### 1. install the latest powershell

- ```powershell
  winget install microsoft.powershell
  ```

### 2. clone this repository into `c:/repos`

- if you'd rather clone to a different location make sure to change the path to reflect the correct location below.

### 3. run the following command in the latest powershell

- ```powershell
  Register-ScheduledTask -TaskName "synergy-listener" -Trigger (New-ScheduledTaskTrigger -AtLogon) -Action (New-ScheduledTaskAction -Execute "pwsh" -Argument "-WindowStyle Hidden -Command `"& c:/repos/synergy-listener/synergy-listener.ps1`"") -RunLevel Highest -Force;
  ```

# remove task

```powershell
Unregister-ScheduledTask -TaskName synergy-listener -Confirm:$false
```
