Pac-Man 256 iOS Native Xcode Project Setup Guide

Welcome! This directory contains the complete, high-fidelity native Swift port of the Pac-Man 256 Endless Scrolling Arcade game. You can copy or export these files directly into an Xcode project to build and run the game on an iPhone, iPad, or Mac (via Catalyst or Apple Silicon).

## 🚀 Xcode Project Quick Start

```
Follow these simple steps to set up your iOS app in under 5 minutes:
```

### Step 1: Create a New Xcode Project
1. Open **Xcode** on your Mac.
2. Select **File** > **New** > **Project...** (or press `Cmd + Shift + N`).
3. Choose **iOS** and select the **App** template, then click **Next**.
4. Configure the project settings:
   - **Product Name**: `PacMan256`
   - **Organization Identifier**: e.g., `com.yourname`
   - **Interface**: `SwiftUI`
   - **Language**: `Swift`
5. Choose a folder on your Mac and click **Create**.

### Step 2: Add the Swift Source Files
Delete any default files or overwrite them, then add the following files from this `/swift` directory:
- `AppMain.swift` (Renamed or replacing the default `@main` file, e.g., `PacMan256App.swift`)
- `ContentView.swift` (Overwriting the default `ContentView.swift` template)
- `GameScene.swift` (The SpriteKit game scene logic)
- `MazeGenerator.swift` (The endless procedural generator)
- `SoundManager.swift` (AVFoundation retro chiptune SFX synthetics)
- `Models.swift` (Game enums, structures, and metadata models)

*Tip: You can simply drag and drop these 6 files into your Xcode file organizer sidebar under the `PacMan256` group folder. Select "Copy items if needed" and "Create groups".*

### Step 3: Run the Application!
1. Select an iOS Simulator (e.g., iPhone 15 Pro) or plug in your physical device in the target device picker bar.
2. Click the **Run** button (or press `Cmd + R`).
3. Xcode will build, link AVFoundation and SpriteKit libraries automatically, and compile the game instantly!
4. Swipe on the device screen or Simulator screen to steer Pac-Man through endless grids!

## 🛠️ Key Architectural Details (iOS SDK equivalents)

- **Canvas ➡️ SpriteKit (`SKScene` & `SKShapeNode`)**: High performance 60/120 FPS frame updating logic handles drawing isometric corridors, items, lasers, and ghosts natively on Apple's graphics metal.
- **Tone Oscillator ➡️ AVFoundation (`AVAudioEngine` & `AVAudioSourceNode`)**: Generates true retro chiptunes and laser synth frequency sweeps procedurally in real time on the device's audio chip.
- **Web UI ➡️ SwiftUI (`ContentView`)**: Implements shop interfaces, multipliers, and retro layout overlays with high-contrast native gradients and smooth system level transitions.
- **Keyboard ➡️ UISwipeGestureRecognizer**: Translates swipe gestures into quick movement updates.
