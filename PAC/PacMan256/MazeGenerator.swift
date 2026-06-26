//
//  MazeGenerator.swift
//  PacMan256
//
//  Created for Pac-Man 256 iOS/iPadOS Xcode Project.
//  Implements endless vertical procedural generation.
//

import Foundation

class MazeGenerator {
    static let gridCols = 17
    static let chunkRows = 16
    static let pathwayConnectors = [2, 8, 14]
    
    // 0 = Wall, 1 = Path
    static let chunkTemplates: [[[Int]]] = [
        // Chunk Template A: Standard columns with vertical corridors
        [
            [0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0],
            [0,0,1,1,1,1,1,0,1,0,1,1,1,1,1,0,0],
            [0,0,1,0,0,0,1,0,1,0,1,0,0,0,1,0,0],
            [0,0,1,0,0,0,1,1,1,1,1,0,0,0,1,0,0],
            [0,0,1,1,1,0,0,0,1,0,0,0,1,1,1,0,0],
            [0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,0],
            [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], // Tunnel / wrap-around
            [0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,0],
            [0,0,1,1,1,1,1,0,1,0,1,1,1,1,1,0,0],
            [0,0,1,0,0,0,1,0,1,0,1,0,0,0,1,0,0],
            [0,0,1,1,1,0,1,1,1,1,1,0,1,1,1,0,0],
            [0,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0],
            [0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
            [0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0],
            [0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
            [0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0]
        ],
        // Chunk Template B: Big circular loops and double splits
        [
            [0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0],
            [0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
            [0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0],
            [0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
            [0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0],
            [0,0,1,1,1,0,1,1,1,1,1,0,1,1,1,0,0],
            [0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,0],
            [0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
            [1,1,1,0,0,0,1,0,0,0,1,0,0,0,1,1,1], // side wrap portals
            [0,0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,0],
            [0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0],
            [0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
            [0,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0],
            [0,0,1,1,1,0,1,1,1,1,1,0,1,1,1,0,0],
            [0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0],
            [0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0]
        ],
        // Chunk Template C: Dense grid grid with central power hub
        [
            [0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0],
            [0,0,1,1,1,0,1,1,1,1,1,0,1,1,1,0,0],
            [0,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0],
            [0,0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,0],
            [0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0],
            [0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
            [0,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0],
            [1,1,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1], // portals + crossroads
            [0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,0],
            [0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
            [0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0],
            [0,0,1,1,1,0,1,1,1,1,1,0,1,1,1,0,0],
            [0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,0],
            [0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
            [0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0],
            [0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0]
        ],
        // Chunk Template D: Zig-zag stairs and alternate paths
        [
            [0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0],
            [0,0,1,1,1,1,1,0,1,0,1,1,1,1,1,0,0],
            [0,0,0,0,0,0,1,0,1,0,1,0,0,0,0,0,0],
            [0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
            [0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0],
            [0,0,1,0,1,1,1,1,1,1,1,1,1,0,1,0,0],
            [0,0,1,0,1,0,0,0,1,0,0,0,1,0,1,0,0],
            [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], // cross hallway
            [0,0,1,0,1,0,0,0,1,0,0,0,1,0,1,0,0],
            [0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
            [0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0],
            [0,0,1,1,1,1,1,0,1,0,1,1,1,1,1,0,0],
            [0,0,1,0,0,0,1,0,1,0,1,0,0,0,1,0,0],
            [0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
            [0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0],
            [0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0]
        ]
    ]

    static func generateMazeChunk(chunkIndex: Int) -> [[GridCell]] {
        let templateIndex = chunkIndex == 0 ? 0 : Int.random(in: 0..<chunkTemplates.count)
        let template = chunkTemplates[templateIndex]
        
        var grid = [[GridCell]]()
        
        for r in 0..<chunkRows {
            var row = [GridCell]()
            for c in 0..<gridCols {
                let tileVal = template[r][c]
                var item = ItemType.none
                
                if tileVal == 1 {
                    let rand = Double.random(in: 0...1)
                    if rand < 0.72 {
                        item = .dot
                    } else if rand < 0.76 {
                        item = .coin
                    } else if rand < 0.785 {
                        item = .powerPellet
                    } else if rand < 0.80 {
                        let fruitRand = Double.random(in: 0...1)
                        if fruitRand < 0.5 {
                            item = .fruitCherry
                        } else if fruitRand < 0.8 {
                            item = .fruitStrawberry
                        } else {
                            item = .fruitMelon
                        }
                    } else if rand < 0.812 {
                        item = .powerupBox
                    }
                }
                
                var finalTile = (tileVal == 1) ? TileType.path : TileType.wall
                
                // Keep connectors clear/standard path
                if (r == 0 || r == chunkRows - 1) && pathwayConnectors.contains(c) {
                    finalTile = .path
                    if item == .powerupBox || item == .powerPellet {
                        item = .dot
                    }
                }
                
                // Protect side wrap portals
                if template[r][0] == 1 && c == 0 {
                    finalTile = .path
                    item = .none
                }
                if template[r][gridCols - 1] == 1 && c == gridCols - 1 {
                    finalTile = .path
                    item = .none
                }
                
                row.push(GridCell(tile: finalTile, item: item, glowing: false))
            }
            grid.append(row)
        }
        
        return grid
    }
    
    static func sanitizeStartingGrid(grid: inout [[GridCell]]) {
        let startRow = 12
        let startCol = 8
        
        for r in (startRow - 2)...(startRow + 2) {
            for c in (startCol - 2)...(startCol + 2) {
                if r >= 0 && r < grid.count && c >= 0 && c < gridCols {
                    grid[r][c].tile = .path
                    grid[r][c].item = .none
                }
            }
        }
        
        // Build starting dot paths
        grid[startRow][startCol - 3].item = .dot
        grid[startRow][startCol - 1].item = .dot
        grid[startRow][startCol + 1].item = .dot
        grid[startRow][startCol + 3].item = .dot
        
        for c in 2...14 {
            if c < gridCols && grid[startRow][c].tile == .path {
                grid[startRow][c].item = .dot
            }
        }
    }
}

// Helper extension for push-like behaviour
extension Array {
    mutating func push(_ element: Element) {
        self.append(element)
    }
}
