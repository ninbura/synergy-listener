# summary
**currently this project is only suitable when the host machine is a windows machine.** 

synergy-listener listens for changes in a synergy 3 host's log file, parses the tail-end, and writes what computer is currently being controlled to a `txt` file. you can then hook into this `txt` file via other applications/processes to react based on which computer is currently being controlled. for example, the [advanced scene switcher plugin](https://github.com/WarmUpTill/SceneSwitcher) for [obs](https://obsproject.com/) can switch scenes based on the *contents of a text file*, *the coordinates of your mouse*, and more. I combine this with the obs [ndi plugin](https://github.com/obs-ndi/obs-ndi) to send a video feed from each PC in my setup to my capture pc. from there, I can automatically switch to whatever scene represents whichever display / section of a display on whichever computer I'm currently controlling with synergy. see the video below to witness this in action.

https://github.com/ninbura/synergy-listener/assets/58058942/a8c67747-cbfe-47ef-9c16-118d0a731814

# setup

### 1. install the latest powershell & git
run the following commands in powershell
```powershell
winget install microsoft.powershell
winget install git.git
```

### 2. clone the synergy-listener repository in the directory you desire
run the folling commands in powershell
```powershell
git clone https://github.com/ninbura/synergy-listener
```

### 3. create and modify `config.json`
- create `config.json` in the root of the repository you just cloned
  - ```PowerShell
    New-Item -Type File -Name config.json
    ```
- provide the `SynergryLogPath` & `OutputFileDirectory` within said configuraiton
  - ```json
    {
      "SynergyLogPath": "C:/ProgramData/Synergy/logs/synergy.log",
      "OutputFileDirectory": "//192.168.2.4/a-sexy-capturer/Users/gabri/Documents"
    }
    ```

### 4. install synergy-listener
Simply run `~install.bat` at the root of the repository **as administrator**. After this, the proccess should automatically startup with your computer.

# log information
If you're running into issues, or it seems like synergy-listener isn't running; check the `synergry-listener.log` file in root where you cloned the repo.

# restarting & uninstalling synergy-listener
- run `~restart.bat` to restart the task if it's not working
- Run `~uninstall.bat` to uninstall to remove the task, feel free to delete the repository after this.
