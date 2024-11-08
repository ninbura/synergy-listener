# Summary
**Currently this project is only suitable when the host machine is a windows machine.** 

synergy-listener listens for changes in a synergy 3 host's log file, parses the tail-end, and writes what computer is currently being controlled to a `.txt` file. You can then hook into this `.txt` file via other applications/processes to react based on which computer is currently being controlled. For example, the [advanced scene switcher plugin](https://github.com/WarmUpTill/SceneSwitcher) for [obs](https://obsproject.com/) can switch scenes based on the *contents of a text file*, *the coordinates of your mouse*, and more. I combine this with the obs [ndi plugin](https://github.com/obs-ndi/obs-ndi) to send a video feed from each PC in my setup to my capture pc. From there, I can automatically switch to whatever scene represents whichever display / section of a display on whichever computer I'm currently controlling with synergy. See the video below to witness this in action.

https://github.com/ninbura/synergy-listener/assets/58058942/a8c67747-cbfe-47ef-9c16-118d0a731814

# Setup

### 1. Install the Latest PowerShell & Git
Run the following command in powershell.
```powershell
winget install Microsoft.PowerShell Git.Git
```

### 2. Clone the synergy-listener Repository
Run the following command in PowerShell in the directory you desire (ie `cd ~/Documents`).
```PowerShell
git clone https://github.com/ninbura/synergy-listener
```

### 3. Create and Modify `config.json`
- Create `config.json` in the root of the repository you just cloned.
  - ```PowerShell
    New-Item -Type File -Name config.json
    ```
- Provide the `SynergryLogPath`, `OutputFileDirectory`, & `RetryOnFailure` within said configuraiton.
  - ```json
    {
      "SynergyLogPath": "C:/ProgramData/Synergy/logs/synergy.log",
      "OutputFileDirectory": "//192.168.1.4/a-sexy-capturer/Users/gabri/Documents",
      "RetryOnFailure": true
    }
    ```
- The `RetryOnFailure` option will make synergy-listener attempt to relocate the relevant files/paths set in the configuration if it can't find them. Useful if you're using network locations.

### 4. Install synergy-listener
Simply run `~install.bat` at the root of the repository **as administrator**. After this, the proccess should automatically startup with your computer. From now on, when you switch computers with Synergy, the `current-computer.txt` file should contain the computer currently being controlled by Synergy. `current-computer.txt` should be located within your specified `OutputFileDirectory`.

# Log Information
If you're running into issues, or it seems like synergy-listener isn't running; check the `synergry-listener.log` file in root where you cloned the repo.

# Stopping, Restarting, & Uninstalling synergy-listener
- Run `~stop.bat` as administrator to stop the schedule task.
- Run `~restart.bat` as administrator to restart the task if it's not working, or if you've updated the `config.json` file.
- Run `~uninstall.bat` as administrator to uninstall and remove the task, feel free to delete the repository after this.
