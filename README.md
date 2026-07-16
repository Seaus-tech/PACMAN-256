# 🕹️ Pac-Man 256 Native iOS/macOS Port

<p align="center>
  <strong>A high-fidelity native Swift port of the Pac-Man 256 endless scrolling arcade game using SwiftUI, SpriteKit, and AVFoundation.</strong>
</p>

<p align="center>
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20macOS-blue?style=flat-square&logo=apple" alt="Platforms" />
  <img src="https://img.shields.io/badge/Language-Swift-F05138?style=flat-square&logo=swift" alt="Swift" />
  <img src="https://img.shields.io/badge/Framework-SwiftUI-F05138?style=flat-square&logo=swift" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/Graphics-SpriteKit-F05138?style=flat-square&logo=xcode" alt="SpriteKit" />
  <img src="https://img.shields.io/badge/Audio-AVFoundation-F05138?style=flat-square&logo=apple" alt="AVFoundation" />
</p>

---

## 📖 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running](#running)
- [Controls](#controls)
- [Architecture](#architecture)
- [Codebase Structure](#codebase-structure)
- [Troubleshooting](#troubleshooting)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

## Overview

This repository contains a native iOS and macOS port of **Pac-Man 256**, the procedural endless-corridor arcade game. Written entirely in Swift, the game bypasses web-view engines and runs directly on metal via SpriteKit, featuring real-time generated synth chiptunes and responsive swipe controls.

## Features

| Feature | Description |
|---------|-------------|
| ⚡ **SpriteKit Graphics Core** | High-performance 60/120 FPS rendering engine |
| 🎵 **Synthetic Audio Generator** | Real-time retro chiptune and laser sounds via AVAudioEngine |
| 🗺️ **Procedural Maze Generator** | Endless scrolling isometric layouts |
| 📱 **SwiftUI Overlay HUD** | Retro shop dashboards and multiplier indicators |
| 👆 **Swipe Controls** | Native gesture recognizers for intuitive play |

## Screenshots

![PacMan 256 Gameplay](screenshots/gameplay.png)

*(Screenshots coming soon)*

## Prerequisites

- Xcode 15.0 or later
- iOS 17.0+ / macOS 14.0+ deployment target
- Apple Silicon Mac or iOS device recommended

## Installation

1. Clone the repository:
```bash
git clone https://github.com/Seaus-tech/PACMAN-256.git
cd PACMAN-256
```

2. Open the Xcode project in `PAC/PacMan256/`

## Running

1. Create an Xcode project named `PacMan256` with SwiftUI interface
2. Drag and drop the 6 Swift source files from `PAC/PacMan256/` into your project
3. Select your target device and press `Cmd + R`

## Controls

| Platform | Control |
|----------|---------|
| iOS | Swipe gestures to steer Pac-Man |
| macOS | Arrow keys or WASD |

## Architecture

- **SpriteKit Engine** - `SKScene` and `SKShapeNode` for high-performance rendering
- **AVAudioEngine** - Procedural audio synthesis using `AVAudioSourceNode`
- **SwiftUI HUD** - Modern interface overlays with native gradients
- **Procedural Generation** - Dynamic maze creation as player ascends

## Codebase Structure

All native source files are located under `PAC/PacMan256/`:

| File | Description |
|------|-------------|
| `AppMain.swift` | Application entry point |
| `ContentView.swift` | Overlays, menus, shops, and SpriteKit view container |
| `GameScene.swift` | Main game loop, rendering, pathfinding, collision |
| `MazeGenerator.swift` | Procedural maze generation logic |
| `SoundManager.swift` | Real-time audio synthesis |
| `Models.swift` | Data contracts, enums, and configurations |

## Troubleshooting

If you encounter build errors:

1. Ensure SpriteKit and AVFoundation frameworks are linked
2. Check that all 6 Swift files are added to the target
3. Verify deployment target is iOS 17.0+ or macOS 14.0+

## Roadmap

- [ ] Add more power-ups from original Pac-Man 256
- [ ] Implement cloud save synchronization
- [ ] Add particle effects for visual polish

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

© 2026 Seaus Tech. All rights reserved.