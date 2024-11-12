# beepamac - Mac Locator Alert Script

**beepamac** is a zsh script designed to help locate a Mac by playing an alert sound at maximum volume, especially useful in remote setups. The script has been developed with headless compatibility in mind but is primarily intended for **remote use**, where users may have partial system access but lack physical proximity to the Mac.

## Features

- Sets Mac’s output volume to maximum to ensure an effective alert
- Plays a continuous alert sound until manually stopped or a condition is met
- Uses a semaphore file for quick start-stop control
- Works in remote setups; compatible with headless use, though untested in strictly headless environments

## Requirements

- **zsh** shell (default on macOS)
- **macOS** system sound (`afplay` recommended for alert playback)
- Limited dependency on `osascript` for sound playback (optional) and volume control

## Installation

1. Clone **beepamac** to a directory of your choice:

   ```bash
   git clone https://github.com/galeep/scriptoolery.git
   cd scriptoolery/alpha/beepamac
   ```

2. Ensure the script has execution permissions:

   ```bash
   chmod +x beepamac.sh
   ```

## Usage

Run the script to start the alert:

```bash
./beepamac.sh
```

### Controls

- **Starting**: Executing `beepamac.sh` will set the volume to maximum and begin playing the alert sound in a loop.
- **Stopping**: To stop the alert, delete the semaphore file located in `/tmp`:

  ```bash
  rm /tmp/mac_beep_locator_stop.pid
  ```

### Configuration Options

Edit the script to adjust configuration variables as needed:

- **BEEP_METHOD**: Choose between `afplay` (recommended) or `osascript` for sound playback. For remote setups, `afplay` is generally more reliable.
- **ALERT_SOUND**: Modify the alert sound file location, if desired.
- **VERBOSE**: Set to `true` for detailed console logging.

## Remote Operation Notes

The **beepamac** script is designed to function in remote setups where you may not have GUI access but need to locate the Mac audibly. The script is compatible with headless setups as well but has undergone limited testing in strictly headless environments. 

- **Recommended for Remote Use**: Use `afplay` as the `BEEP_METHOD` for better compatibility.
- **Volume Reset**: Volume restoration on exit may vary depending on the connection type and system permissions. Manually adjust the volume if necessary in remote-only sessions.

## Troubleshooting

- **Script fails in headless mode**: If working in a headless-only setup, `afplay` is recommended as `osascript` may not function fully.
- **Volume Reset Issues**: If the volume is not restored upon exit, confirm permissions for `osascript`, or reset manually.

## License

Licensed under the BSD 2-Clause License. See LICENSE for details.
