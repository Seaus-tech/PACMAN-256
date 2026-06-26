//
//  Models.swift
//  PacMan256
//
//  Created for Pac-Man 256 iOS/iPadOS Xcode Project.
//  Contains core data models, enums, and structures.
//

import Foundation
import CoreGraphics

enum GameState: String, Codable {
    case mainMenu = "MAIN_MENU"
    case loadout = "LOADOUT"
    case playing = "PLAYING"
    case gameOver = "GAME_OVER"
}

enum Direction: String, Codable, CaseIterable {
    case up = "UP"
    case down = "DOWN"
    case left = "LEFT"
    case right = "RIGHT"
    
    var opposite: Direction {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }
}

enum TileType: Int, Codable {
    case wall = 0
    case path = 1
}

enum ItemType: String, Codable {
    case none = "NONE"
    case dot = "DOT"
    case powerPellet = "POWER_PELLET"
    case coin = "COIN"
    case fruitCherry = "FRUIT_CHERRY"
    case fruitStrawberry = "FRUIT_STRAWBERRY"
    case fruitMelon = "FRUIT_MELON"
    case powerupBox = "POWERUP_BOX"
    
    var scoreValue: Int {
        switch self {
        case .none: return 0
        case .dot: return 1
        case .powerPellet: return 50
        case .coin: return 5
        case .fruitCherry: return 100
        case .fruitStrawberry: return 200
        case .fruitMelon: return 500
        case .powerupBox: return 10
        }
    }
}

enum PowerupId: String, Codable, CaseIterable, Identifiable {
    case laser = "LASER"
    case freeze = "FREEZE"
    case bomb = "BOMB"
    case giant = "GIANT"
    
    var id: String { self.rawValue }
}

struct PowerupDetails: Codable, Identifiable {
    let id: PowerupId
    var name: String
    var description: String
    var colorHex: String
    var iconName: String
    var unlocked: Bool
    var level: Int
    var maxLevel: Int
    var upgradeCost: Int
    var baseDuration: TimeInterval
}

struct HighScoreRecord: Codable, Identifiable {
    var id = UUID()
    let score: Int
    let coins: Int
    let maxChain: Int
    let date: String
}

struct GridCell: Codable {
    var tile: TileType
    var item: ItemType
    var glowing: Bool = false
}

enum GhostType: String, Codable, CaseIterable {
    case blinky = "BLINKY"   // Red: Chases Pac-Man directly
    case pinky = "PINKY"     // Pink: Ambush, charges down hallways when she sees Pac-Man
    case inky = "INKY"       // Cyan: Out-of-phase, patrols a local area
    case clyde = "CLYDE"     // Orange: Heavy and wanders upward randomly
    case sue = "SUE"         // Purple: Vertical/Horizontal line blocker
    case glitchy = "GLITCHY" // Rainbow: Randomly teleports around, leaves a temporary glitch trail
    
    var colorHex: String {
        switch self {
        case .blinky: return "#ff0000"
        case .pinky: return "#ff69b4"
        case .inky: return "#00ffff"
        case .clyde: return "#ff8c00"
        case .sue: return "#da70d6"
        case .glitchy: return "#9932cc"
        }
    }
}

enum GhostState: String, Codable {
    case chase = "CHASE"
    case frightened = "FRIGHTENED"
    case eaten = "EATEN"
}

struct GhostStateObject {
    let id: UUID
    let type: GhostType
    var gridX: Int
    var gridY: Int
    var posX: CGFloat
    var posY: CGFloat
    var targetX: Int
    var targetY: Int
    var dir: Direction
    var state: GhostState
    var speed: CGFloat
    var frightenedTimer: TimeInterval
    var chargeDirection: Direction?
    var visualGlitchTimer: TimeInterval
}

struct Particle {
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var colorHex: String
    var size: CGFloat
    var alpha: CGFloat
    var life: TimeInterval
    var maxLife: TimeInterval
    var isGlitch: Bool = false
}
