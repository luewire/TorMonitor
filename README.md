# TorMonitor

A lightweight macOS menu bar system monitor. All metrics are combined into a single status bar item with minimal resource usage.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5-orange) ![License](https://img.shields.io/badge/License-Luewire-green)

---

## Screenshots

**Menu Bar**

![Menu Bar](screenshots/bar.png)

**Settings Panel**

![Settings Panel](screenshots/panel.png)

**Battery Detail**

![Battery Detail](screenshots/battery.png)

---

## Features

- **CPU Usage** — Real-time percentage display via `host_processor_info`
- **CPU Temperature** — Read from SMC (no root required)
- **Memory** — Used / Total with percentage; hover for quick details
- **Network Speed** — Upload & download in compact format with auto unit conversion
- **GPU Usage** — Supports multiple GPUs (integrated & discrete); shows max utilization in menu bar
- **GPU Temperature** — Read from IOAccelerator + SMC fallback
- **Battery / Charging Power** — Real-time adapter wattage; hover for battery health details

---

## Interactions

| Action | Result |
|---|---|
| **Hover** over any segment | Shows a simple inline tooltip (e.g. `Memory: 5.2GB/16.0GB (33%)`) |
| **Single click** on CPU/CPU Temp | Opens Activity Monitor → CPU tab |
| **Single click** on Memory | Opens Activity Monitor → Memory tab |
| **Single click** on Battery | Opens Activity Monitor → Energy tab |
| **Single click** on Network | Opens Activity Monitor → Network tab |
| **Two-finger tap (right-click)** | Opens / closes the Settings popover |

---

## Settings

- Toggle each module on/off — disabled modules are **not polled** and don't consume RAM
- Adjust refresh interval: **3s / 5s / 10s**
- Launch at Login toggle (via SMAppService)

---

## Requirements

- macOS 13.0+
- Intel (x86_64) or Apple Silicon (arm64)
- Xcode (for building from source)

---

## Build from Source

```bash
git clone https://github.com/luewire/tormonitor.git
cd tormonitor
xcodebuild -project MacState.xcodeproj -scheme MacState build
```

---

## Project Structure

```
MacState/
├── App/
│   └── MacStateApp.swift              # App entry point
├── Core/
│   ├── StatusBarController.swift      # Menu bar rendering & interaction
│   ├── MonitorManager.swift           # Data polling & refresh scheduling
│   ├── CPUService.swift               # CPU usage
│   ├── MemoryService.swift            # Memory stats
│   ├── NetworkService.swift           # Network speed
│   ├── BatteryService.swift           # Battery & charging power
│   ├── GPUService.swift               # GPU usage & temperature
│   ├── SMCService.swift               # SMC reads (temperature)
│   ├── IP2RegionService.swift         # Offline IP geo lookup (lazy-loaded)
│   ├── Localization.swift             # English string definitions
│   ├── LaunchAtLoginService.swift     # Launch at login
│   ├── CpuToggle.swift                # CPU usage toggle
│   ├── CpuTempToggle.swift            # CPU temp toggle
│   ├── MemoryToggle.swift             # Memory toggle
│   ├── NetworkToggle.swift            # Network toggle
│   ├── BatteryToggle.swift            # Battery toggle
│   ├── GpuToggle.swift                # GPU usage toggle
│   └── GpuTempToggle.swift            # GPU temp toggle
├── Views/
│   ├── SettingsView.swift             # Settings popover UI
│   └── PopoverView.swift              # Popover container
├── Resources/
│   ├── ip2region_v4.xdb               # Offline IP geo database
│   └── Info.plist
└── Assets.xcassets/
```

---

## Data Sources

| Metric | Source |
|---|---|
| CPU Usage | `host_processor_info` |
| CPU Temperature | IOKit SMC (`TC0P`) |
| Memory | `host_statistics64` |
| Network Speed | `sysctl NET_RT_IFLIST2` |
| Charging Power | IOKit `AppleSmartBattery` + SMC `PDTR` |
| GPU Usage | IOKit IOAccelerator `PerformanceStatistics` |
| GPU Temperature | IOAccelerator `Temperature(C)` + SMC fallback |
| Process Info | `libproc` (`proc_pidinfo`) |
| IP Geo Lookup | ip2region offline database |

---

## License

Copyright © 2025 luewire

Permission is hereby granted, free of charge, to any person to use, copy, modify, merge, and distribute this software freely, without restriction.

This software is provided "as is", without warranty of any kind.
