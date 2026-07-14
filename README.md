# 🕹️ Pac-Man 256 Native iOS/macOS Port

<p align="center">
  <strong>A high-fidelity native Swift port of the Pac-Man 256 endless scrolling arcade game using SwiftUI, SpriteKit, and AVFoundation.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20macOS-blue?style=flat-square&logo=apple" alt="Platforms" />
  <img src="https://img.shields.io/badge/Language-Swift-orange?style=flat-square&logo=swift" alt="Swift" />
  <img src="https://img.shields.io/badge/Framework-SwiftUI-orange?style=flat-square&logo=swift" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/Graphics-SpriteKit-red?style=flat-square&logo=xcode" alt="SpriteKit" />
  <img src="https://img.shields.io/badge/Audio-AVFoundation-blue?style=flat-square&logo=apple" alt="AVFoundation" />
</p>

---

## 🌌 Overview

This repository contains a native iOS and macOS port of **Pac-Man 256**, the procedural endless-corridor arcade game. Written entirely in Swift, the game bypasses web-view engines and runs directly on metal via SpriteKit, featuring real-time generated synth chiptunes and responsive swipe controls.

---

## ✨ Features & Architecture

- ⚡ **SpriteKit Graphics Core (`SKScene`)** — High-performance 60/120 FPS rendering engine for corridor structures, dot layouts, laser sweeps, and ghost pathfinding
- 🎵 **Synthetic Audio Generator (`AVAudioEngine`)** — Generates retro chiptune sounds and laser frequency sweeps procedurally in real time on the device's audio chip
- 🗺️ **Procedural Maze Generator** — Endless scrolling isometric layouts generated dynamically as the player moves up
- 📱 **SwiftUI Overlay HUD** — Retro shop dashboards, multiplier indicators, and status overlays styled with native gradients
- 👆 **Swipe Controls** — Uses native swipe gesture recognizers to steer Pac-Man through grid intersections

---

## 🛠️ Codebase Structure

All native source files are located under [**PAC/PacMan256/**](file:///Users/YashB/seaus/PACMAN-256/PAC/PacMan256):

- [**AppMain.swift**](file:///Users/YashB/seaus/PACMAN-256/PAC/PacMan256/AppMain.swift) — The main application entryway
- [**ContentView.swift**](file:///Users/YashB/seaus/PACMAN-256/PAC/PacMan256/ContentView.swift) — Handles overlays, menus, shops, and houses the SpriteKit game view
- [**GameScene.swift**](file:///Users/YashB/seaus/PACMAN-256/PAC/PacMan256/GameScene.swift) — The main game loop, rendering pipelines, pathfinding, and collision handling
- [**MazeGenerator.swift**](file:///Users/YashB/seaus/PACMAN-256/PAC/PacMan256/MazeGenerator.swift) — The endless corridor procedural generation logic
- [**SoundManager.swift**](file:///Users/YashB/seaus/PACMAN-256/PAC/PacMan256/SoundManager.swift) — Real-time audio waveform synth oscillator using AVFoundation
- [**Models.swift**](file:///Users/YashB/seaus/PACMAN-256/PAC/PacMan256/Models.swift) — Data contracts, direction enums, and score configurations

---

## 🚀 Xcode Setup Quick Start

You can build and run the game on an iPhone, iPad, or Mac (via Catalyst or Apple Silicon) in under 5 minutes:

1. **Create an Xcode Project** — Create a new iOS App project named `PacMan256` with interface set to **SwiftUI** and language to **Swift**
2. **Add Files** — Drag and drop the 6 Swift source files from the `PAC/PacMan256` directory into your Xcode project hierarchy
3. **Compile & Run** — Connect your physical device or choose a simulator, and hit `Cmd + R` to compile and launch!

---

## 📸 Screenshots

![PacMan 256 Gameplay](screenshots/gameplay.png)

*(Screenshots coming soon)*

---

## 🎮 Controls

| Platform | Control |
|----------|---------|
| iOS | Swipe gestures to steer Pac-Man |
| macOS | Arrow keys or WASD |

---

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

---

## 📄 License

© 2026 Seaus Tech. All rights reserved.