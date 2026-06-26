//
//  GameScene.swift
//  PacMan256
//
//  Created for Pac-Man 256 iOS/iPadOS Xcode Project.
//  Core SpriteKit Game Loop rendering isometric gameplay, AI, and animations.
//

import SpriteKit
import Combine

class GameScene: SKScene {
    // Game loops & delegates
    var onScoreUpdated: ((Int) -> Void)?
    var onCoinsUpdated: ((Int) -> Void)?
    var onDotChainUpdated: ((Int, Int) -> Void)?
    var onMultiplierUpdated: ((Int) -> Void)?
    var onGameOver: ((Int, Int, Int) -> Void)?
    var onPowerupActivated: ((PowerupId, TimeInterval) -> Void)?
    
    // Core Constants
    let tileSize: CGFloat = 36.0
    let scaleX: CGFloat = 22.0
    let scaleY: CGFloat = 15.0 // steeper vertical isometric ratio for corridors visibility
    
    // Game variables
    private var isPausedGame = false
    private var gameState: GameState = .playing
    private var activeChunks: [Int: [[GridCell]]] = [:]
    private var maxChunkIndex = 0
    
    private var player = PlayerState(
        gridX: 8, gridY: 10,
        posX: 8 * 36.0 + 18.0,
        posY: 10 * 36.0 + 18.0,
        dir: .up, nextDir: nil,
        targetX: 8, targetY: 10,
        isMoving: false, score: 0,
        multiplier: 1, multiplierExpiry: 0,
        coinsCollected: 0, dotChain: 0,
        highestDotChain: 0, speed: 5.5,
        giantTimer: 0, laserTimer: 0,
        freezeTimer: 0, bombCharge: 0,
        activePowerup: nil, powerupTimer: 0
    )
    
    private var ghosts: [GhostStateObject] = []
    private var particles: [Particle] = []
    
    // Glitch and Camera tracker
    private var glitchAbsoluteRow: CGFloat = -6.0
    private var glitchSpeed: CGFloat = 1.0
    private var cameraY: CGFloat = 10 * 36.0 + 18.0
    private var screenShake: CGFloat = 0.0
    
    // Node container layers
    private let mapContainer = SKNode()
    private let hudContainer = SKNode()
    
    // Timing tracking
    private var lastUpdateTime: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = UIColor(red: 0.03, green: 0.03, blue: 0.07, alpha: 1.0)
        
        addChild(mapContainer)
        addChild(hudContainer)
        
        setupGame()
        setupGestureRecognizers(view: view)
    }
    
    func setupGame() {
        gameState = .playing
        activeChunks.removeAll()
        ghosts.removeAll()
        particles.removeAll()
        
        // Generate first two maze chunks
        activeChunks[0] = MazeGenerator.generateMazeChunk(chunkIndex: 0)
        activeChunks[1] = MazeGenerator.generateMazeChunk(chunkIndex: 1)
        maxChunkIndex = 1
        
        // Clear starting safe area
        if var firstChunk = activeChunks[0] {
            MazeGenerator.sanitizeStartingGrid(grid: &firstChunk)
            activeChunks[0] = firstChunk
        }
        
        player = PlayerState(
            gridX: 8, gridY: 10,
            posX: 8 * tileSize + tileSize / 2,
            posY: 10 * tileSize + tileSize / 2,
            dir: .up, nextDir: nil,
            targetX: 8, targetY: 10,
            isMoving: false, score: 0,
            multiplier: 1, multiplierExpiry: 0,
            coinsCollected: 0, dotChain: 0,
            highestDotChain: 0, speed: 5.5,
            giantTimer: 0, laserTimer: 0,
            freezeTimer: 0, bombCharge: 0,
            activePowerup: nil, powerupTimer: 0
        )
        
        cameraY = player.posY
        glitchAbsoluteRow = -6.0
        glitchSpeed = 1.0
        
        // Spawn starting ghosts
        for i in 0..<4 {
            spawnGhost(targetAbsRow: player.gridY + 8 + i * 5)
        }
        
        SoundManager.shared.playPowerPellet()
    }
    
    private func spawnGhost(targetAbsRow: Int) {
        let types: [GhostType] = [.blinky, .pinky, .inky, .clyde, .sue, .glitchy]
        let ghostType = types[Int.random(in: 0..<types.count)]
        
        let gX = Int.random(in: 2...14)
        let gObj = GhostStateObject(
            id: UUID(),
            type: ghostType,
            gridX: gX,
            gridY: targetAbsRow,
            posX: CGFloat(gX) * tileSize + tileSize / 2,
            posY: CGFloat(targetAbsRow) * tileSize + tileSize / 2,
            targetX: gX,
            targetY: targetAbsRow,
            dir: .down,
            state: .chase,
            speed: CGFloat.random(in: 3.2...4.6),
            frightenedTimer: 0,
            chargeDirection: nil,
            visualGlitchTimer: 0
        )
        ghosts.append(gObj)
    }
    
    // MARK: - Gesture Controls (Swipe)
    private func setupGestureRecognizers(view: SKView) {
        let directions: [UISwipeGestureRecognizer.Direction] = [.up, .down, .left, .right]
        for direction in directions {
            let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            recognizer.direction = direction
            view.addGestureRecognizer(recognizer)
        }
    }
    
    @objc private func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        guard gameState == .playing && !isPausedGame else { return }
        
        switch sender.direction {
        case .up:
            player.nextDir = .up
        case .down:
            player.nextDir = .down
        case .left:
            player.nextDir = .left
        case .right:
            player.nextDir = .right
        default:
            break
        }
    }
    
    // MARK: - Isometric Projection Matrix
    private func project(col: CGFloat, row: CGFloat, height: CGFloat) -> CGPoint {
        let camRow = cameraY / tileSize
        let c = col
        let r = row - camRow
        
        let screenX = (c - r) * scaleX
        let screenY = -(c + r) * scaleY - height
        
        return CGPoint(x: screenX, y: screenY)
    }
    
    // MARK: - Core Gameplay Tick
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        guard gameState == .playing && !isPausedGame else { return }
        
        updateGame(dt: dt)
        drawGameScene()
    }
    
    private func updateGame(dt: TimeInterval) {
        // Increment glitch row
        glitchAbsoluteRow += glitchSpeed * CGFloat(dt)
        glitchSpeed = min(3.5, 1.0 + (CGFloat(player.score) / 4500.0) * 0.1)
        
        // 1. Move Player
        movePlayer(dt: dt)
        
        // 2. Move Ghosts
        moveGhosts(dt: dt)
        
        // 3. Update active timers
        updateTimers(dt: dt)
        
        // 4. Update particles
        updateParticles(dt: dt)
        
        // 5. Procedural map generation loading check
        let playerChunkIndex = Int(floor(CGFloat(player.gridY) / CGFloat(MazeGenerator.chunkRows)))
        if playerChunkIndex + 1 > maxChunkIndex {
            let nextIndex = playerChunkIndex + 1
            activeChunks[nextIndex] = MazeGenerator.generateMazeChunk(chunkIndex: nextIndex)
            maxChunkIndex = nextIndex
            
            // Clean up old chunks
            let clearThreshold = playerChunkIndex - 2
            if clearThreshold >= 0 {
                activeChunks.removeValue(forKey: clearThreshold)
            }
        }
        
        // 6. Camera smooth follow
        let targetCamY = player.posY
        let isGiantActive = player.giantTimer > 0
        let cameraLerp: CGFloat = isGiantActive ? 0.05 : 0.15
        cameraY += (targetCamY - cameraY) * cameraLerp
        
        // Glitch line gameover check
        let playerAbsoluteRow = CGFloat(player.gridY)
        if playerAbsoluteRow < glitchAbsoluteRow {
            triggerGameOver()
        }
    }
    
    private func getCellAt(row: Int, col: Int) -> GridCell? {
        guard col >= 0 && col < MazeGenerator.gridCols && row >= 0 else { return nil }
        let chunkIdx = row / MazeGenerator.chunkRows
        let chunkRow = row % MazeGenerator.chunkRows
        return activeChunks[chunkIdx]?[chunkRow][col]
    }
    
    private func setCellAt(row: Int, col: Int, cell: GridCell) {
        guard col >= 0 && col < MazeGenerator.gridCols && row >= 0 else { return }
        let chunkIdx = row / MazeGenerator.chunkRows
        let chunkRow = row % MazeGenerator.chunkRows
        activeChunks[chunkIdx]?[chunkRow][col] = cell
    }
    
    private func movePlayer(dt: TimeInterval) {
        if !player.isMoving {
            // Check next directions
            if let nextDir = player.nextDir {
                if canMoveInDirection(dir: nextDir) {
                    player.dir = nextDir
                    player.nextDir = nil
                    startMoving()
                } else if canMoveInDirection(dir: player.dir) {
                    startMoving()
                }
            } else if canMoveInDirection(dir: player.dir) {
                startMoving()
            }
        }
        
        if player.isMoving {
            let speedPixels = player.speed * tileSize
            var moveDist = speedPixels * CGFloat(dt)
            
            let targetPX = CGFloat(player.targetX) * tileSize + tileSize / 2
            let targetPY = CGFloat(player.targetY) * tileSize + tileSize / 2
            
            let dx = targetPX - player.posX
            let dy = targetPY - player.posY
            
            let dist = sqrt(dx*dx + dy*dy)
            
            if dist <= moveDist {
                player.posX = targetPX
                player.posY = targetPY
                player.gridX = player.targetX
                player.gridY = player.targetY
                player.isMoving = false
                
                // Eat items on cell landing
                eatItemAt(row: player.gridY, col: player.gridX)
            } else {
                player.posX += (dx / dist) * moveDist
                player.posY += (dy / dist) * moveDist
            }
        }
    }
    
    private func canMoveInDirection(dir: Direction) -> Bool {
        var nextX = player.gridX
        var nextY = player.gridY
        
        switch dir {
        case .up: nextY += 1
        case .down: nextY -= 1
        case .left: nextX -= 1
        case .right: nextX += 1
        }
        
        // Handle portal wrap-around
        if nextX < 0 || nextX >= MazeGenerator.gridCols {
            return true
        }
        
        if let cell = getCellAt(row: nextY, col: nextX) {
            return cell.tile == .path
        }
        return false
    }
    
    private func startMoving() {
        player.isMoving = true
        var nextX = player.gridX
        var nextY = player.gridY
        
        switch player.dir {
        case .up: nextY += 1
        case .down: nextY -= 1
        case .left: nextX -= 1
        case .right: nextX += 1
        }
        
        // Handle portals
        if nextX < 0 {
            player.targetX = MazeGenerator.gridCols - 1
            player.posX = CGFloat(player.targetX) * tileSize + tileSize / 2
            player.gridX = player.targetX
        } else if nextX >= MazeGenerator.gridCols {
            player.targetX = 0
            player.posX = CGFloat(player.targetX) * tileSize + tileSize / 2
            player.gridX = player.targetX
        } else {
            player.targetX = nextX
            player.targetY = nextY
        }
    }
    
    private func eatItemAt(row: Int, col: Int) {
        guard var cell = getCellAt(row: row, col: col) else { return }
        if cell.item == .none {
            player.dotChain = 0
            onDotChainUpdated?(0, player.highestDotChain)
            return
        }
        
        let multiplierFactor = (player.giantTimer > 0) ? 2 : 1
        let baseScore = cell.item.scoreValue * player.multiplier * multiplierFactor
        
        player.score += baseScore
        onScoreUpdated?(player.score)
        
        if cell.item == .dot {
            player.dotChain += 1
            if player.dotChain > player.highestDotChain {
                player.highestDotChain = player.dotChain
            }
            onDotChainUpdated?(player.dotChain, player.highestDotChain)
            SoundManager.shared.playChomp()
            
            // 256 dot chain blast blast
            if player.dotChain == 256 {
                triggerChainBlast()
            }
        } else if cell.item == .coin {
            player.coinsCollected += 1
            onCoinsUpdated?(player.coinsCollected)
            SoundManager.shared.playCoin()
        } else if cell.item == .powerPellet {
            player.dotChain = 0
            SoundManager.shared.playPowerPellet()
            activatePowerPellet()
        } else if cell.item == .powerupBox {
            triggerPowerupBox()
        } else if cell.item == .fruitCherry || cell.item == .fruitStrawberry || cell.item == .fruitMelon {
            let mult = (cell.item == .fruitCherry) ? 2 : (cell.item == .fruitStrawberry ? 3 : 5)
            player.multiplier = mult
            onMultiplierUpdated?(mult)
            SoundManager.shared.playCoin()
        }
        
        cell.item = .none
        setCellAt(row: row, col: col, cell: cell)
    }
    
    private func activatePowerPellet() {
        for idx in 0..<ghosts.count {
            ghosts[idx].state = .frightened
            ghosts[idx].frightenedTimer = 7.0
        }
    }
    
    private func triggerPowerupBox() {
        // Activate a random equipped power-up
        let list: [PowerupId] = [.laser, .freeze, .bomb, .giant]
        let selected = list.randomElement() ?? .laser
        
        player.activePowerup = selected
        player.powerupTimer = 6.0
        
        onPowerupActivated?(selected, 6.0)
        
        if selected == .laser {
            player.laserTimer = 6.0
            SoundManager.shared.playLaser()
        } else if selected == .freeze {
            player.freezeTimer = 6.0
        } else if selected == .bomb {
            player.bombCharge = 1
        } else if selected == .giant {
            player.giantTimer = 6.0
        }
        
        createExplosion(x: player.posX, y: player.posY, colorHex: "#ffff00", count: 12)
    }
    
    private func triggerChainBlast() {
        SoundManager.shared.playExplosion()
        screenShake = 16.0
        createExplosion(x: player.posX, y: player.posY, colorHex: "#00ffff", count: 40)
        
        // Wipe all ghosts within 15 blocks
        for i in 0..<ghosts.count {
            let dx = ghosts[i].posX - player.posX
            let dy = ghosts[i].posY - player.posY
            let dist = sqrt(dx*dx + dy*dy)
            if dist < tileSize * 15 {
                ghosts[i].state = .eaten
                player.score += 256
                onScoreUpdated?(player.score)
            }
        }
    }
    
    private func moveGhosts(dt: TimeInterval) {
        for i in 0..<ghosts.count {
            var ghost = ghosts[i]
            
            // Collision with Pac-man
            let gAbsX = ghost.posX
            let gAbsY = ghost.posY
            let pAbsX = player.posX
            let pAbsY = player.posY
            
            let dist = sqrt(pow(gAbsX - pAbsX, 2) + pow(gAbsY - pAbsY, 2))
            
            if dist < tileSize * 0.85 {
                if ghost.state == .frightened {
                    ghost.state = .eaten
                    player.score += 200
                    onScoreUpdated?(player.score)
                    SoundManager.shared.playCoin()
                    createExplosion(x: ghost.posX, y: ghost.posY, colorHex: "#ffffff", count: 12)
                    ghosts[i] = ghost
                    continue
                } else if ghost.state == .chase {
                    if player.giantTimer > 0 {
                        ghost.state = .eaten
                        player.score += 400
                        onScoreUpdated?(player.score)
                        SoundManager.shared.playExplosion()
                        createExplosion(x: ghost.posX, y: ghost.posY, colorHex: "#ff0000", count: 15)
                    } else {
                        triggerGameOver()
                        return
                    }
                }
            }
            
            // Chase mechanics
            if !isMoving(gState: ghost) {
                let directions: [Direction] = [.up, .down, .left, .right]
                var validDirections = [Direction]()
                
                for dir in directions {
                    if dir == ghost.dir.opposite { continue }
                    if canGhostMove(gObj: ghost, dir: dir) {
                        validDirections.append(dir)
                    }
                }
                
                if validDirections.isEmpty {
                    validDirections.append(ghost.dir.opposite)
                }
                
                // Smart Chase target depending on type
                let targetDir = findBestDirection(gObj: ghost, dirs: validDirections)
                ghost.dir = targetDir
                
                var nX = ghost.gridX
                var nY = ghost.gridY
                switch targetDir {
                case .up: nY += 1
                case .down: nY -= 1
                case .left: nX -= 1
                case .right: nX += 1
                }
                
                ghost.targetX = nX
                ghost.targetY = nY
            } else {
                let gSpeed = (ghost.state == .frightened) ? ghost.speed * 0.5 : ghost.speed
                let moveDist = gSpeed * tileSize * CGFloat(dt)
                
                let targetXPos = CGFloat(ghost.targetX) * tileSize + tileSize / 2
                let targetYPos = CGFloat(ghost.targetY) * tileSize + tileSize / 2
                
                let dx = targetXPos - ghost.posX
                let dy = targetYPos - ghost.posY
                let dist = sqrt(dx*dx + dy*dy)
                
                if dist <= moveDist {
                    ghost.posX = targetXPos
                    ghost.posY = targetYPos
                    ghost.gridX = ghost.targetX
                    ghost.gridY = ghost.targetY
                } else {
                    ghost.posX += (dx / dist) * moveDist
                    ghost.posY += (dy / dist) * moveDist
                }
            }
            ghosts[i] = ghost
        }
    }
    
    private func isMoving(gState: GhostStateObject) -> Bool {
        let absX = CGFloat(gState.gridX) * tileSize + tileSize / 2
        let absY = CGFloat(gState.gridY) * tileSize + tileSize / 2
        return absX != gState.posX || absY != gState.posY
    }
    
    private func canGhostMove(gObj: GhostStateObject, dir: Direction) -> Bool {
        var nX = gObj.gridX
        var nY = gObj.gridY
        switch dir {
        case .up: nY += 1
        case .down: nY -= 1
        case .left: nX -= 1
        case .right: nX += 1
        }
        if nX < 0 || nX >= MazeGenerator.gridCols { return false }
        if let cell = getCellAt(row: nY, col: nX) {
            return cell.tile == .path
        }
        return false
    }
    
    private func findBestDirection(gObj: GhostStateObject, dirs: [Direction]) -> Direction {
        if dirs.count == 1 { return dirs[0] }
        
        var targetX = player.gridX
        var targetY = player.gridY
        
        // Ghost AI personality offsets
        if gObj.type == .pinky {
            // Ambush
            switch player.dir {
            case .up: targetY += 4
            case .down: targetY -= 4
            case .left: targetX -= 4
            case .right: targetX += 4
            }
        } else if gObj.type == .inky {
            targetY += Int.random(in: -3...3)
        }
        
        var bestDir = dirs[0]
        var minDist = CGFloat.infinity
        
        for dir in dirs {
            var nextX = gObj.gridX
            var nextY = gObj.gridY
            switch dir {
            case .up: nextY += 1
            case .down: nextY -= 1
            case .left: nextX -= 1
            case .right: nextX += 1
            }
            
            let dx = CGFloat(nextX - targetX)
            let dy = CGFloat(nextY - targetY)
            let dist = dx*dx + dy*dy
            if dist < minDist {
                minDist = dist
                bestDir = dir
            }
        }
        return bestDir
    }
    
    private func updateTimers(dt: TimeInterval) {
        if player.laserTimer > 0 { player.laserTimer -= dt }
        if player.freezeTimer > 0 { player.freezeTimer -= dt }
        if player.giantTimer > 0 { player.giantTimer -= dt }
        if player.powerupTimer > 0 {
            player.powerupTimer -= dt
            if player.powerupTimer <= 0 {
                player.activePowerup = nil
            }
        }
        
        for idx in 0..<ghosts.count {
            if ghosts[idx].frightenedTimer > 0 {
                ghosts[idx].frightenedTimer -= dt
                if ghosts[idx].frightenedTimer <= 0 {
                    ghosts[idx].state = .chase
                }
            }
            // If ghost eaten, respawn them further ahead
            if ghosts[idx].state == .eaten {
                ghosts[idx].state = .chase
                ghosts[idx].gridY = player.gridY + 16
                ghosts[idx].posY = CGFloat(ghosts[idx].gridY) * tileSize + tileSize / 2
            }
        }
        
        if screenShake > 0 {
            screenShake -= CGFloat(dt) * 10.0
        }
    }
    
    private func updateParticles(dt: TimeInterval) {
        for idx in (0..<particles.count).reversed() {
            particles[idx].life -= dt
            if particles[idx].life <= 0 {
                particles.remove(at: idx)
            } else {
                particles[idx].x += particles[idx].vx * CGFloat(dt) * 60.0
                particles[idx].y += particles[idx].vy * CGFloat(dt) * 60.0
                particles[idx].alpha = CGFloat(particles[idx].life / particles[idx].maxLife)
            }
        }
    }
    
    private func createExplosion(x: CGFloat, y: CGFloat, colorHex: String, count: Int) {
        for _ in 0..<count {
            let angle = Double.random(in: 0...(Double.pi * 2))
            let speed = CGFloat.random(in: 1.5...4.5)
            let p = Particle(
                x: x, y: y,
                vx: CGFloat(cos(angle)) * speed,
                vy: CGFloat(sin(angle)) * speed,
                colorHex: colorHex,
                size: CGFloat.random(in: 3...7),
                alpha: 1.0,
                life: Double.random(in: 0.4...0.8),
                maxLife: 0.8
            )
            particles.append(p)
        }
    }
    
    private func triggerGameOver() {
        guard gameState == .playing else { return }
        gameState = .gameOver
        SoundManager.shared.playDeath()
        onGameOver?(player.score, player.coinsCollected, player.highestDotChain)
    }
    
    // MARK: - Core Graphic Scene Compositor
    private func drawGameScene() {
        mapContainer.removeAllChildren()
        
        let startR = max(0, Int(floor(cameraY / tileSize)) - 10)
        let endR = startR + 25
        
        // Render Iso walls and paths
        for r in startR...endR {
            for c in 0..<MazeGenerator.gridCols {
                guard let cell = getCellAt(row: r, col: c) else { continue }
                
                if cell.tile == .wall {
                    drawIsometricWall(row: r, col: c)
                } else {
                    drawIsometricFloor(row: r, col: c, item: cell.item)
                }
            }
        }
        
        // Render player
        drawIsometricPlayer()
        
        // Render ghosts
        drawIsometricGhosts()
        
        // Render particles
        drawIsometricParticles()
        
        // Apply camera shockwave shake
        if screenShake > 0 {
            let dx = CGFloat.random(in: -screenShake...screenShake)
            let dy = CGFloat.random(in: -screenShake...screenShake)
            mapContainer.position = CGPoint(x: dx, y: dy)
        } else {
            mapContainer.position = .zero
        }
    }
    
    private func drawIsometricWall(row: Int, col: Int) {
        let pt = project(col: CGFloat(col), row: CGFloat(row), height: 10.0)
        
        // Simplified shape building blocks for isometric corridors
        let wallNode = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: pt.x, y: pt.y - 8))
        path.addLine(to: CGPoint(x: pt.x + scaleX, y: pt.y))
        path.addLine(to: CGPoint(x: pt.x, y: pt.y + 8))
        path.addLine(to: CGPoint(x: pt.x - scaleX, y: pt.y))
        path.closeSubpath()
        
        wallNode.path = path
        wallNode.fillColor = UIColor(red: 0.04, green: 0.06, blue: 0.22, alpha: 1.0)
        wallNode.strokeColor = UIColor(red: 0.09, green: 0.24, blue: 0.79, alpha: 1.0)
        wallNode.lineWidth = 1.0
        mapContainer.addChild(wallNode)
    }
    
    private func drawIsometricFloor(row: Int, col: Int, item: ItemType) {
        guard item != .none else { return }
        let pt = project(col: CGFloat(col), row: CGFloat(row), height: 0.0)
        
        let itemNode = SKShapeNode(circleOfRadius: 3.5)
        itemNode.position = pt
        
        switch item {
        case .dot:
            itemNode.fillColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
            itemNode.strokeColor = .clear
        case .coin:
            itemNode.fillColor = .yellow
            itemNode.strokeColor = .orange
        case .powerPellet:
            itemNode.fillColor = .green
            itemNode.strokeColor = .white
        case .powerupBox:
            itemNode.fillColor = .red
            itemNode.strokeColor = .yellow
        default:
            itemNode.fillColor = .magenta
        }
        
        mapContainer.addChild(itemNode)
    }
    
    private func drawIsometricPlayer() {
        let isGiant = player.giantTimer > 0
        let pSize: CGFloat = isGiant ? 15.0 : 8.0
        
        let pPos = project(col: player.posX / tileSize, row: player.posY / tileSize, height: isGiant ? 6 : 2)
        
        let pacNode = SKShapeNode(circleOfRadius: pSize)
        pacNode.position = pPos
        pacNode.fillColor = .yellow
        pacNode.strokeColor = .orange
        pacNode.lineWidth = 1.5
        mapContainer.addChild(pacNode)
        
        // Active laser lines
        if player.laserTimer > 0 {
            let laserPath = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: pPos)
            
            // Draw a glowing neon cyan laser ahead
            var beamX = player.posX
            var beamY = player.posY
            switch player.dir {
            case .up: beamY += tileSize * 6
            case .down: beamY -= tileSize * 6
            case .left: beamX -= tileSize * 6
            case .right: beamX += tileSize * 6
            }
            
            let beamPt = project(col: beamX / tileSize, row: beamY / tileSize, height: 4)
            path.addLine(to: beamPt)
            
            laserPath.path = path
            laserPath.strokeColor = UIColor.cyan
            laserPath.lineWidth = 4.0
            mapContainer.addChild(laserPath)
        }
    }
    
    private func drawIsometricGhosts() {
        for ghost in ghosts {
            let pt = project(col: ghost.posX / tileSize, row: ghost.posY / tileSize, height: 8.0)
            
            let gNode = SKShapeNode(rectOf: CGSize(width: 14, height: 16), cornerRadius: 4)
            gNode.position = pt
            gNode.fillColor = (ghost.state == .frightened) ? .blue : (ghost.type == .blinky ? .red : .pink)
            gNode.strokeColor = .white
            gNode.lineWidth = 1.0
            mapContainer.addChild(gNode)
        }
    }
    
    private func drawIsometricParticles() {
        for p in particles {
            let pt = project(col: p.x / tileSize, row: p.y / tileSize, height: 2.0)
            let node = SKShapeNode(rectOf: CGSize(width: p.size, height: p.size))
            node.position = pt
            node.fillColor = .cyan
            node.strokeColor = .clear
            node.alpha = p.alpha
            mapContainer.addChild(node)
        }
    }
}
