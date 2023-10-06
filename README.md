# setup task

### 1. install the latest powershell

```powershell
winget install microsoft.powershell
```

### 2. clone this repository into `c:/repos`

if you'd rather clone to a different location make sure to change the path in the `Register-ScheduledTask` command below.

### 3. change parameters in `synergy-listener.ps1`

- as can be seen in the default state of `synergy-listener.ps1` I'm using network locations
- simply change the path parameters to reflect
  1.  the location of the synergy log you're trying to read (host's log)
  2.  the location you'd like to output the `current-computer.txt` file to

### 4. run the following command in the latest version of powershell

```powershell
Register-ScheduledTask -TaskName "synergy-listener" -Trigger (New-ScheduledTaskTrigger -AtLogon) -Action (New-ScheduledTaskAction -Execute "pwsh" -Argument "-WindowStyle Hidden -Command `"& c:/repos/synergy-listener/synergy-listener.ps1`"") -RunLevel Highest -Force;
```

### 5. configure external functionality

Each computer in my setup uses [ndi](https://ndi.video/tools/) to pass display capture to an aggregated capture pc. I then use a combination of OBS & Advanced Scene switcher with the [ndi plugin](https://github.com/obs-ndi/obs-ndi) to display content relative to where my mouse is on any given PC.

# remove task

run the following command in the latest version of powershell

```powershell
Unregister-ScheduledTask -TaskName synergy-listener -Confirm:$false
```
