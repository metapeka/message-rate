```markdown
# Twitch Chat Statistics Monitor

![Version](https://img.shields.io/badge/version-2.4-blue.svg) ![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0-brightgreen.svg) ![License](https://img.shields.io/badge/license-MIT-yellow.svg)

Twitch Chat Statistics Monitor is an AutoHotkey v2 script designed to track and display real-time statistics of Twitch chat activity. It monitors messages typed in chat, calculates metrics such as words per minute, characters per minute, messages per minute, and provides additional metrics for activity within the last 60 seconds. The script includes a graphical interface, customizable settings, error logging, and hotkey controls for user interaction.

## Features

- **Real-Time Statistics**:
  - Words per minute
  - Characters per minute
  - Messages per minute
  - Words in the last 60 seconds
  - Messages in the last 60 seconds
- **Timer**: Displays time elapsed since the last message.
- **Automatic Reset**: Resets statistics after a configurable period of inactivity.
- **Customizable Settings**:
  - Update interval (100ms to 10s)
  - Inactivity timeout (5s to 5min)
- **Hotkey Controls**:
  - `F8`: Reload settings
  - `F9`: Open settings file
  - `F10`: Show diagnostics
  - `F11`: Open error log
  - `F12`: Reset statistics
- **Logging**:
  - Chat messages logged to `TwitchChatLog.txt`
  - Errors logged to `log_errors.txt`
- **Settings File**: Configurable via `setting_rate.ini`
- **Debug Mode**: Extensive error logging for troubleshooting

## Requirements

- [AutoHotkey v2.0](https://www.autohotkey.com/) or later
- Windows operating system
- Administrative privileges (recommended for reliable hotkey functionality)

## Installation

1. **Install AutoHotkey**:
   - Download and install AutoHotkey v2.0 from the [official website](https://www.autohotkey.com/).

2. **Download the Script**:
   - Clone this repository or download the script file (`TwitchChatStatsMonitor.ahk`).

3. **Run the Script**:
   - Double-click the `.ahk` file, or run it via AutoHotkey:
     ```bash
     autohotkey TwitchChatStatsMonitor.ahk
     ```

4. **Optional**: Place the script in your startup folder for automatic launch on system boot.

## Usage

1. **Launch the Script**:
   - Run the script, and a GUI window will appear displaying real-time chat statistics.

2. **Interact with Twitch Chat**:
   - Type messages in a Twitch chat input field and press `Enter`. The script captures the text and updates the statistics.

3. **Hotkeys**:
   - `F8`: Reload settings from `setting_rate.ini`.
   - `F9`: Open the settings file in the default text editor.
   - `F10`: Display diagnostic information (e.g., current settings and statistics).
   - `F11`: Open the error log file (`log_errors.txt`).
   - `F12`: Manually reset all statistics.

4. **Settings**:
   - Edit `setting_rate.ini` to adjust:
     - `UpdateInterval`: Time between statistic updates (in milliseconds, 100–10000).
     - `InactivityTimeout`: Time before statistics reset due to inactivity (in milliseconds, 5000–300000).
   - Example `setting_rate.ini`:
     ```ini
     [Settings]
     UpdateInterval=1000
     InactivityTimeout=30000
     ```

5. **Logs**:
   - Chat messages are saved in `TwitchChatLog.txt` with timestamps and window titles.
   - Errors are logged in `log_errors.txt` for debugging.

## File Structure

- `TwitchChatStatsMonitor.ahk`: Main script file.
- `setting_rate.ini`: Configuration file for settings (auto-generated if not present).
- `TwitchChatLog.txt`: Log file for chat messages.
- `log_errors.txt`: Log file for errors and debug information.

## Configuration

The script automatically creates `setting_rate.ini` with default settings if it doesn't exist. You can modify the following parameters:

- **UpdateInterval**: Controls how often the GUI updates (default: 1000ms = 1 second).
- **InactivityTimeout**: Time of inactivity before statistics reset (default: 30000ms = 30 seconds).

Example `setting_rate.ini`:
```ini
[Settings]
UpdateInterval=1000
InactivityTimeout=30000

; Настройки программы Twitch Chat Statistics Monitor
; UpdateInterval - интервал обновления статистики в миллисекундах (100-10000)
; 1000 мс = 1 секунда, 2000 мс = 2 секунды
; InactivityTimeout - время бездействия для автосброса в миллисекундах (5000-300000)
; 30000 мс = 30 секунд, 60000 мс = 1 минута, 300000 мс = 5 минут
```

## Debugging

- **Error Logging**: All errors are logged to `log_errors.txt` with timestamps and context.
- **Diagnostics**: Press `F10` to view current settings, statistics, and system status.
- **Verbose Logging**: The script logs initialization steps, setting changes, and errors for easy troubleshooting.

## Known Issues

- **Hotkey Conflicts**: If `Enter` or function keys (`F8`–`F12`) don't work, ensure no other applications are intercepting these keys.
- **GUI Issues**: If the GUI fails to display, check `log_errors.txt` for details. Common causes include AutoHotkey version mismatches or insufficient permissions.
- **Unicode Support**: Non-ASCII characters in chat messages are supported, but ensure your text editor displays them correctly when viewing logs.

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Make your changes and commit (`git commit -m "Add your feature"`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

Please include detailed descriptions of your changes and test thoroughly with AutoHotkey v2.0.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [AutoHotkey v2.0](https://www.autohotkey.com/).
- Inspired by the need for real-time Twitch chat analytics.

## Contact

For questions or support, open an issue on this repository or contact the maintainer via GitHub.

---

*Last updated: June 10, 2025*
``` 

This README provides a comprehensive overview of the script, including its purpose, features, installation steps, usage instructions, and configuration details. It follows GitHub Markdown conventions and includes badges for version, AutoHotkey dependency, and license. The structure is clear and concise, catering to both new users and developers. Let me know if you'd like any adjustments!
