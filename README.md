# setup task

### 1. install the latest powershell

run the following command in powershell or command prompt

```powershell
winget install microsoft.powershell
```

### 2. clone this repository into `c:/repos`

if you'd rather clone to a different location make sure to change the path in the `Register-ScheduledTask` command below

### 3. change parameters in `synergy-listener.ps1`

- as can be seen in the default state of `synergy-listener.ps1` I'm using network locations
- simply change the path parameters to reflect
  1.  the location of the synergy log you're trying to read (host's log)
  2.  the location you'd like to output the `current-computer.txt` file to

### 4. run the following command in the latest version of powershell

```powershell
Register-ScheduledTask -TaskName "synergy-listener" -Trigger (New-ScheduledTaskTrigger -AtLogon) -Action (New-ScheduledTaskAction -Execute "pwsh" -Argument "-WindowStyle Hidden -Command `"& c:/repos/synergy-listener/synergy-listener.ps1`"") -RunLevel Highest -Force;
```

### 5. restart your computer

### 6. verify that `current-computer.txt` is updating

- the path to `current-computer.txt` is found at the top of the `synergy-listener.ps1` file as a parameter
- as you switch PCs with synergy this file should update to reflect the name of the PC currently being controlled
- if `current-computer.txt` is not updating it's likely that you poorly configured `synergy-listener.ps1` or the `Reigster-ScheudledTask` command

### 7. configure external functionality

I use [obs](https://obsproject.com/) with the [advanced scene switcher](https://github.com/WarmUpTill/SceneSwitcher) & [ndi](https://github.com/obs-ndi/obs-ndi) plugins to display content relative to my mouse coordinates accross all PCs in my setup.

# remove task

run the following command in the latest version of powershell to remove the task if desired. **this will stop `current-computer.txt` from updating**.

```powershell
Unregister-ScheduledTask -TaskName "synergy-listener" -Confirm:$false
```
