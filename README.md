# Miknatizale for macOS

A high-performance, pixel-perfect, native Swift & SwiftUI replica of the famous **Magnet** window manager for macOS, now packaged as **Miknatizale**.

![Miknatizale Icon](Miknatizale.app/Contents/Resources/Miknatizale.icns)

---

## 🌟 Key Features

### 1. Complete Suite of Window Snapping Commands
- **Halves**:
  - `Left Half` (`⌃⌥←`)
  - `Right Half` (`⌃⌥→`)
  - `Top Half` (`⌃⌥↑`)
  - `Bottom Half` (`⌃⌥↓`)
- **Corners / Quarters**:
  - `Top Left` (`⌃⌥U`)
  - `Top Right` (`⌃⌥I`)
  - `Bottom Left` (`⌃⌥J`)
  - `Bottom Right` (`⌃⌥K`)
- **Thirds**:
  - `Left Third` (`⌃⌥D`)
  - `Center Third` (`⌃⌥F`)
  - `Right Third` (`⌃⌥G`)
- **Two Thirds**:
  - `Left Two Thirds` (`⌃⌥E`)
  - `Center Two Thirds` (`⌃⌥R`)
  - `Right Two Thirds` (`⌃⌥T`)
- **Displays**:
  - `Next Display` (`⌃⌥⌘→`)
  - `Previous Display` (`⌃⌥⌘←`)
- **System & General**:
  - `Maximize` (`⌃⌥Return`)
  - `Almost Maximize` (`⌃⌥⇧Return`)
  - `Center Window` (`⌃⌥C`)
  - `Restore Previous Window Frame` (`⌃⌥⌫`)

### 2. Repeated Shortcut Press Cycling (Signature Feature)
- Pressing `Left Half` repeatedly cycles: **1/2 Screen ➔ 1/3 Screen ➔ 2/3 Screen ➔ 1/2 Screen**.
- Pressing `Right Half` repeatedly cycles: **1/2 Screen ➔ 1/3 Screen ➔ 2/3 Screen ➔ 1/2 Screen**.
- Pressing `Maximize` repeatedly cycles: **Full Screen ➔ Almost Maximize (comfort margin)**.

### 3. Edge Dragging & Translucent Snap Preview
- Drag any window by its title bar to screen edges or corners to see an animated, translucent blue frosted preview overlay.
- Releasing the mouse snaps the window into place.
- Supports individual toggles per trigger zone.

### 4. Immensely Customizable Preferences UI
- **Interactive Grid Visualizer**: 18x12 display grid showing the exact target position in glowing blue cells.
- **Custom Shortcut Recorder**: Click to record any combination of modifier keys and letters/arrows.
- **Trigger Area Preview & Toggle**: Visual display outline displaying the activation edge with individual enable/disable toggles.
- **Window Gaps & Margins**: Configurable spacing between tiled windows (from 0 px seamless to 30 px).
- **Sound Feedback**: Optional subtle snap click sound.
- **Launch at Login**: Optional background autostart.

### 5. Native Menu Bar Item
- High-resolution 3-pane vector icon in the macOS menu bar.
- Visual dropdown menu displaying all layout options, graphical preview icons, and hotkey hints.
- Quick toggles for Edge Snapping, Accessibility Status, Preferences, and Quit.

---

## 💿 Installation & DMG

### 1. Using the DMG Disk Image
Double-click `Miknatizale.dmg` or open it from terminal:
```bash
open Miknatizale.dmg
```
Drag **Miknatizale.app** into the **Applications** shortcut!

### 2. Direct Launch
```bash
open Miknatizale.app
```

### 3. Rebuilding the App & DMG
```bash
./build.sh
```

---

## 🔒 Permissions

macOS requires **Accessibility** permission to move and resize third-party application windows:
1. When launched, click **Grant Access** on the Preferences banner (or open **System Settings ➔ Privacy & Security ➔ Accessibility**).
2. Enable the toggle next to **Miknatizale**.
3. Miknatizale immediately recognizes the permission and begins managing windows with zero delay.
