# Pac-Man 256 iOS Native Xcode Project Setup Guide

Welcome! This directory contains the complete, high-fidelity native Swift port of the Pac-Man 256 Endless Scrolling Arcade game. You can copy or export these files directly into an Xcode project to build and run the game on an iPhone, iPad, or Mac (via Catalyst or Apple Silicon).

## 📖 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Step 1: Create a New Xcode Project](#step-1-create-a-new-xcode-project)
- [Step 2: Add the Swift Source Files](#step-2-add-the-swift-source-files)
- [Step 3: Run the Application](#step-3-run-the-application)
- [Architecture Details](#architecture-details-ios-sdk-equivalents)

## Prerequisites

- Xcode 15.0 or later
- iOS 17.0+ deployment target (or macOS 14.0+ for Catalyst)
- Apple Silicon Mac or iOS device recommended

## Quick Start

Follow these simple steps to set up your iOS app in under 5 minutes:

## Step 1: Create a New Xcode Project

1. Open **Xcode** on your Mac.
2. Select **File** > **New** > **Project...** (or press `Cmd + Shift + N`).
3. Choose **iOS** and select the **App** template, then click **Next**.
4. Configure the project settings:
   - **Product Name**: `PacMan256`
   - **Organization Identifier**: e.g., `com.yourname`
   - **Interface**: `SwiftUI`
   - **Language**: `Swift`
5. Choose a folder on your Mac and click **Create**.

## Step 2: Add the Swift Source Files

Delete any default files or overwrite them, then add the following files from this directory:

| File | Description |
|------|-------------|
| `AppMain.swift` | Application entry point (rename to `PacMan256App.swift`) |
| `ContentView.swift` | Main UI and shop interfaces |
| `GameScene.swift` | SpriteKit game scene logic |
| `MazeGenerator.swift` | Endless procedural maze generator |
| `SoundManager.swift` | AVFoundation retro chiptune SFX synthetics |
| `Models.swift` | Game enums, structures, and metadata models |

> **Tip**: Drag and drop these files into your Xcode file organizer sidebar under the `PacMan256` group folder. Select "Copy items if needed" and "Create groups".

## Step 3: Run the Application

1. Select an iOS Simulator (e.g., iPhone 15 Pro) or connect your physical device
2. Click the **Run** button (or press `Cmd + R`)
3. Xcode will build and compile the game instantly!

## Architecture Details (iOS SDK equivalents)

| Web Concept | iOS SDK Equivalent | Description |
|-------------|-------------------|-------------|
| **Canvas** | **SpriteKit (`SKScene` & `SKShapeNode`)** | High performance 60/120 FPS frame updating logic handles drawing isometric corridors, items, lasers, and ghosts natively on Apple's graphics metal |
| **Tone Oscillator** | **AVFoundation (`AVAudioEngine` & `AVAudioSourceNode`)** | Generates true retro chiptunes and laser synth frequency sweeps procedurally in real time on the device's audio chip |
| **Web UI** | **SwiftUI (`ContentView`)** | Implements shop interfaces, multipliers, and retro layout overlays with high-contrast native gradients and smooth system level transitions |
| **Keyboard** | **UISwipeGestureRecognizer** | Translates swipe gestures into quick movement updates |

## Controls

| Platform | Control |
|----------|---------|
| iOS | Swipe gestures to steer Pac-Man |
| macOS | Arrow keys |

## Troubleshooting

If you encounter build errors:

1. Ensure SpriteKit and AVFoundation frameworks are linked
2. Check that all 6 Swift files are added to the target
3. Verify deployment target is iOS 17.0+

---

© 2026 Seaus Tech. All rights reserved.