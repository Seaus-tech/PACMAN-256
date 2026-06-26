//
//  ContentView.swift
//  PacMan256
//
//  Created for Pac-Man 256 iOS/iPadOS Xcode Project.
//  Beautiful Neon Arcade SwiftUI layout hosting SpriteKit.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    // Persistent stats
    @State private var coins: Int = 100
    @State private var highScore: Int = 0
    @State private var highScores: [Int] = []
    
    // Active HUD states
    @State private var currentScore: Int = 0
    @State private var currentCoins: Int = 0
    @State private var currentDotChain: Int = 0
    @State private var highestDotChain: Int = 0
    @State private var multiplier: Int = 1
    
    @State private var isMuted: Bool = false
    @State private var gameState: GameState = .mainMenu
    
    // Upgrades Shop State
    @State private var laserLevel = 1
    @State private var freezeLevel = 1
    @State private var bombLevel = 1
    @State private var giantLevel = 1
    
    // Active active weapons details
    private let upgradeMax = 8
    private let baseCost = 150
    
    // SpriteKit Scene Bindings
    @State private var sceneId = UUID()
    
    var body: some View {
        ZStack {
            // Background starry pattern
            Color(red: 0.03, green: 0.03, blue: 0.07)
                .edgesIgnoringSafeArea(.all)
            
            // STAR BACKGROUND
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                Path { path in
                    for _ in 0..<80 {
                        let rx = CGFloat.random(in: 0...w)
                        let ry = CGFloat.random(in: 0...h)
                        path.addEllipse(in: CGRect(x: rx, y: ry, width: 1.5, height: 1.5))
                    }
                }
                .fill(Color.white.opacity(0.12))
            }
            
            VStack(spacing: 0) {
                // ARCADE BAR HEADER
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow, radius: 4)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("PAC-MAN 256")
                                .font(.system(.headline, design: .monospaced))
                                .fontWeight(.black)
                                .foregroundColor(.yellow)
                            Text("ENDLESS GLITCH SWIFT PORT")
                                .font(.system(size: 8, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        // Coin Wallet
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.yellow)
                            Text("\(coins)")
                                .font(.system(.subheadline, design: .monospaced))
                                .fontWeight(.heavy)
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(red: 0.08, green: 0.08, blue: 0.18))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                        )
                        
                        // Volume trigger
                        Button(action: {
                            isMuted = SoundManager.shared.toggleMute()
                        }) {
                            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .foregroundColor(.gray)
                                .padding(6)
                                .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(red: 0.05, green: 0.05, blue: 0.11))
                
                // ROUTED WINDOW
                switch gameState {
                case .mainMenu:
                    mainMenuView
                case .loadout:
                    weaponsShopView
                case .playing:
                    gameViewportView
                case .gameOver:
                    gameOverView
                }
            }
        }
        .statusBar(hidden: true)
    }
    
    // MARK: - View Modules
    
    // 1. Main Menu View
    var mainMenuView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 6) {
                Text("HIPSTER WHALE CLONE")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                    .tracking(2.5)
                
                Text("PAC-MAN 256")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow, radius: 10)
                
                Text("SWIFT NATIVE EDITION")
                    .font(.system(size: 12, weight: .heavy, design: .monospaced))
                    .foregroundColor(.pink)
            }
            
            Button(action: {
                currentScore = 0
                currentCoins = 0
                currentDotChain = 0
                highestDotChain = 0
                multiplier = 1
                sceneId = UUID() // Refresh SpriteKit frame
                gameState = .playing
            }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.title)
                    Text("INSERT CHIP & PLAY")
                        .font(.system(.title3, design: .monospaced))
                        .fontWeight(.black)
                }
                .foregroundColor(.black)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(16)
                .shadow(color: .yellow.opacity(0.5), radius: 15)
            }
            .padding(.horizontal, 24)
            
            Button(action: {
                gameState = .loadout
            }) {
                HStack {
                    Image(systemName: "bag.fill")
                    Text("UPGRADES & WEAPONS")
                        .fontWeight(.bold)
                }
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.1, green: 0.1, blue: 0.28))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.blue.opacity(0.6), lineWidth: 1)
                )
            }
            .padding(.horizontal, 24)
            
            // Leaderboards
            VStack(alignment: .leading, spacing: 12) {
                Text("TOP ARCADE PILOTS")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(.gray)
                    .tracking(1.5)
                
                if highScores.isEmpty {
                    Text("No local records found. Write history!")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color(red: 0.05, green: 0.05, blue: 0.11))
                        .cornerRadius(8)
                } else {
                    ForEach(0..<min(3, highScores.count), id: \.self) { idx in
                        HStack {
                            Text("#0\(idx + 1)")
                                .fontWeight(.black)
                                .foregroundColor(.pink)
                            Spacer()
                            Text("\(highScores[idx]) PTS")
                                .fontWeight(.bold)
                                .foregroundColor(.cyan)
                        }
                        .font(.system(size: 13, design: .monospaced))
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
            .background(Color(red: 0.07, green: 0.07, blue: 0.16))
            .cornerRadius(14)
            .padding(.horizontal, 24)
            
            Spacer()
            
            Text("SWIPE SCREEN TO STEER PAC-MAN")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .padding(.bottom, 20)
        }
    }
    
    // 2. Weapons Upgrade Shop View
    var weaponsShopView: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: { gameState = .mainMenu }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                Spacer()
                Text("WEAPONS CACHE")
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Spacer().frame(width: 24)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            ScrollView {
                VStack(spacing: 16) {
                    weaponRow(name: "LASER BEAM", desc: "Zaps ghosts in direct sight pathways.", level: laserLevel, cost: laserLevel * baseCost, color: .cyan, upgradeAction: {
                        if coins >= laserLevel * baseCost && laserLevel < upgradeMax {
                            coins -= laserLevel * baseCost
                            laserLevel += 1
                        }
                    })
                    
                    weaponRow(name: "FREEZE BLIZZARD", desc: "Slows ghost speed across entire grid.", level: freezeLevel, cost: freezeLevel * baseCost, color: .blue, upgradeAction: {
                        if coins >= freezeLevel * baseCost && freezeLevel < upgradeMax {
                            coins -= freezeLevel * baseCost
                            freezeLevel += 1
                        }
                    })
                    
                    weaponRow(name: "BOMB DETONATOR", desc: "Deploys a wide shockwave clearing area.", level: bombLevel, cost: bombLevel * baseCost, color: .red, upgradeAction: {
                        if coins >= bombLevel * baseCost && bombLevel < upgradeMax {
                            coins -= bombLevel * baseCost
                            bombLevel += 1
                        }
                    })
                    
                    weaponRow(name: "GIANT PILL", desc: "Pac-man goes giant and crushes ghosts.", level: giantLevel, cost: giantLevel * baseCost, color: .yellow, upgradeAction: {
                        if coins >= giantLevel * baseCost && giantLevel < upgradeMax {
                            coins -= giantLevel * baseCost
                            giantLevel += 1
                        }
                    })
                }
                .padding()
            }
        }
    }
    
    func weaponRow(name: String, desc: String, level: Int, cost: Int, color: Color, upgradeAction: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(name)
                    .font(.system(.headline, design: .monospaced))
                    .fontWeight(.black)
                    .foregroundColor(color)
                Spacer()
                Text("LVL \(level)/\(upgradeMax)")
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text(desc)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.gray)
            
            HStack {
                // Progress Bar
                HStack(spacing: 3) {
                    ForEach(0..<upgradeMax, id: \.self) { idx in
                        Rectangle()
                            .fill(idx < level ? color : Color.gray.opacity(0.3))
                            .frame(height: 6)
                    }
                }
                
                Spacer()
                
                if level < upgradeMax {
                    Button(action: upgradeAction) {
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                            Text("\(cost)")
                        }
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(coins >= cost ? Color.yellow : Color.gray)
                        .cornerRadius(6)
                    }
                } else {
                    Text("MAXED")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(red: 0.08, green: 0.08, blue: 0.18))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    // 3. Gameplay Board View
    var gameViewportView: some View {
        ZStack {
            // SpriteView Engine Canvas
            SpriteView(scene: createGameScene())
                .id(sceneId)
                .edgesIgnoringSafeArea(.all)
            
            // Overlay HUD display
            VStack {
                // Top Score Indicators
                HStack {
                    VStack(alignment: .leading) {
                        Text("SCORE")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                        Text("\(currentScore)")
                            .font(.system(.title, design: .monospaced))
                            .fontWeight(.black)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    if multiplier > 1 {
                        Text("X\(multiplier)")
                            .font(.system(.title3, design: .monospaced))
                            .fontWeight(.black)
                            .foregroundColor(.pink)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.pink.opacity(0.2))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.pink, lineWidth: 1.5)
                            )
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("DOT CHAIN")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                        Text("\(currentDotChain)")
                            .font(.system(.title, design: .monospaced))
                            .fontWeight(.black)
                            .foregroundColor(.cyan)
                    }
                }
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]), startPoint: .top, endPoint: .bottom)
                )
                
                Spacer()
                
                // Bottom stats
                HStack {
                    Text("STEER BY SWIPING ON THE VIEW")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.8))
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    // 4. Game Over Screen View
    var gameOverView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 8) {
                Text("THE GLITCH CONSUMED YOU")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(.red)
                    .tracking(1.5)
                
                Text("GAME OVER")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .red, radius: 10)
            }
            
            VStack(spacing: 16) {
                HStack {
                    Text("FINAL SCORE:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(currentScore) PTS")
                        .fontWeight(.black)
                        .foregroundColor(.yellow)
                }
                
                HStack {
                    Text("COINS EATEN:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("+\(currentCoins)")
                        .fontWeight(.black)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("MAX CHAIN:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(highestDotChain) DOTS")
                        .fontWeight(.black)
                        .foregroundColor(.cyan)
                }
            }
            .font(.system(.body, design: .monospaced))
            .padding()
            .background(Color(red: 0.08, green: 0.08, blue: 0.18))
            .cornerRadius(12)
            .padding(.horizontal, 32)
            
            Button(action: {
                gameState = .mainMenu
            }) {
                Text("RETURN TO ARCADE")
                    .font(.system(.headline, design: .monospaced))
                    .fontWeight(.black)
                    .foregroundColor(.black)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
    
    // Setup SpriteKit Game Scene callback
    func createGameScene() -> GameScene {
        let scene = GameScene()
        scene.size = CGSize(width: 414, height: 896)
        scene.scaleMode = .resizeFill
        
        scene.onScoreUpdated = { score in
            self.currentScore = score
        }
        scene.onCoinsUpdated = { addedCoins in
            self.currentCoins = addedCoins
            self.coins += 1 // award coin to local persistent savings
        }
        scene.onDotChainUpdated = { chain, maxChain in
            self.currentDotChain = chain
            if maxChain > self.highestDotChain {
                self.highestDotChain = maxChain
            }
        }
        scene.onMultiplierUpdated = { mult in
            self.multiplier = mult
        }
        scene.onGameOver = { score, collectedCoins, maxChain in
            self.coins += collectedCoins
            self.currentCoins = collectedCoins
            self.highestDotChain = maxChain
            self.highScores.append(score)
            self.highScores.sort(by: >)
            
            // Save local storage
            if score > self.highScore {
                self.highScore = score
            }
            
            withAnimation {
                self.gameState = .gameOver
            }
        }
        return scene
    }
}
