# summary
**currently this project is only suitable when the host machine is a windows machine.** 

synergy-listener listens for changes in the synergy 3 host's log file, parses the tail-end, and writes what computer is currently being controlled to a `txt` file. you can then hook into this `txt` file via other applications/processes to react based on which computer is currently being controlled. for example, the [advanced scene switcher plugin](https://github.com/WarmUpTill/SceneSwitcher) for [obs](https://obsproject.com/) can switch scenes based on the contents of a text file, or the coordinates of your mouse (and more). I combine this with the obs [ndi plugin](https://github.com/obs-ndi/obs-ndi) to send a video feed from each PC in my setup to my capture pc; from there I can automatically switch to whatever scene represents whichever display / section of a display that I'm currently controlling with synergy, across multiple computers. see the video below to witness this in action.

https://github.com/ninbura/synergy-listener/assets/58058942/a8c67747-cbfe-47ef-9c16-118d0a731814

# setup

### 1. install the latest powershell & git
run the following commands in powershell
```powershell
winget install microsoft.powershell
winget install git.git
```

### 2. clone the synergy-listener repository into `c:/repos`
run the folling commands in powershell
```powershell
new-item -path /repos
cd /repos
git clone https://github.com/ninbura/synergy-listener
```
if you'd rather clone to a different location, make sure to change the path in the `Register-ScheduledTask` command below

### 3. change parameters in `synergy-listener.ps1`
- aformention parameters, `$logPath` & `$outputFilePath`, can be found at the top of `synergy-listener.ps1`.
- as can be seen in the default state, I'm using network locations
- simply change the path parameters to reflect
  1.  the location of the synergy log you're trying to read (host's log)
  2.  the location you'd like to output the `current-computer.txt` file to

### 4. register a scheduled task that starts `synergy-listener.ps1` at logon
run the following command in powershell
```powershell
Register-ScheduledTask -TaskName "synergy-listener" -Trigger (New-ScheduledTaskTrigger -AtLogon) -Action (New-ScheduledTaskAction -Execute "pwsh" -Argument "-WindowStyle Hidden -Command `"& c:/repos/synergy-listener/synergy-listener.ps1`"") -RunLevel Highest -Force;
```

### 5. restart your computer
note that it may take some time for the script to start if you have a lot of startup processes on your computer, at most it should take a couple minutes.

### 6. verify that `current-computer.txt` is updating
- the path to `current-computer.txt` is found at the top of the `synergy-listener.ps1` file as a parameter
- as you switch PCs with synergy this file should update to reflect the name of the PC currently being controlled
- if `current-computer.txt` is not updating it's likely that you poorly configured `synergy-listener.ps1` or the `Reigster-ScheudledTask` command

### 7. configure external applications/processes to read `current-computer.txt` per your needs

# removal
run the following command in powershell, note that **this will stop `current-computer.txt` from updating**.
```powershell
Unregister-ScheduledTask -TaskName "synergy-listener" -Confirm:$false
```
delete repository files if desired.
