# Microsoft Copilot Fixes

Makes the UI of Microsoft Copilot for Business less annoying.

## Development

Prerequisites:

* A Linux environment with Bash available
* An installation of the [Bun JavaScript runtime](https://bun.sh/), available inside your Linux environment (if you use WSL, make sure to install Bun *inside* your Linux distro, rather than using Bun's Windows version)

### Do these steps *once*

1. Clone this repository somewhere, e.g.:
   ```bash
   git clone 'https://github.com/SkyyySi/microsoft-copilot-fixes' ~/microsoft-copilot-fixes
   ```
2. Navigate to the cloned directory (e.g. `cd ~/microsoft-copilot-fixes`)
3. Run `watch.sh` to create an initial build, then press `Ctrl` + `C` to stop it
4. Open Google Chrome
5. Open <chrome://extensions>
6. Enable "Developer mode" (for Google Chrome specifically, it's a small toggle in the top-right corner)
7. Click **Load unpacked**
8. Pick the root directory of your local copy of this repository

### Do these steps *each time* you want to make changes

1. Navigate to the cloned directory (e.g. `cd ~/microsoft-copilot-fixes`)
2. Run `watch.sh` to start transpiling and bundling the TypeScript source files 
3. Open Google Chrome
4. Open <https://m365.cloud.microsoft/chat>
5. Open <chrome://extensions> in another tab or window
6. Press the reload button for the "Microsoft Copilot Fixes"-extension (a small ⟳ (circular arrow symbol), left to the extension's on/off-switch) and then reload Copliot. You'll have to do this for every minor change you make, there is no automatic reloading.
