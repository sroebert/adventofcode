import Foundation

struct Assignment202020: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let tiles = try await getTiles()
        let grid = try determinGrid(for: tiles)

        return
            grid[0][0].id *
            grid[0][grid.count - 1].id *
            grid[grid.count - 1][0].id *
            grid[grid.count - 1][grid.count - 1].id
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let tiles = try await getTiles()
        let grid = try determinGrid(for: tiles)

        let tile = try joinGrid(grid)
        let pattern = getSeaMonsterPattern(gridSize: tile.image.count)

        // Find orientation where sea monsters can be found
        var orientedTile = tile
        tile.enumerateOrientations { tile, stop in
            var tile = tile
            tile.normalize()

            let singleLine = tile.image.reduce([]) { $0 + $1 }
            guard firstIndex(of: pattern, in: singleLine) != nil else {
                return
            }

            orientedTile = tile
            stop = true
        }

        // Hide sea monsters
        var singleLine = orientedTile.image.reduce([]) { $0 + $1 }
        while let offset = firstIndex(of: pattern, in: singleLine) {
            for i in 0..<pattern.count {
                if pattern[i] {
                    singleLine[offset + i] = false
                }
            }
        }

        // Determine water roughness
        return singleLine.reduce(0) { $0 + ($1 ? 1 : 0) }
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private enum CombineMethod: CaseIterable {
        case left
        case right
        case top
        case bottom
        
        var inverted: Self {
            switch self {
            case .left: return .right
            case .right: return .left
            case .top: return .bottom
            case .bottom: return .top
            }
        }
    }
    
    private enum SearchCriteria {
        case empty
        case anyTile
        case tile(Tile)
    }
    
    private struct Filter {
        var method: CombineMethod
        var criteria: SearchCriteria
    }
    
    private struct Tile: CustomStringConvertible {
        var id: UInt64
        var image: [[Bool]]
        
        var rotated: Int = 0
        var flipped: Bool = false
        
        var topBorder: [Bool]
        var leftBorder: [Bool]
        var bottomBorder: [Bool]
        var rightBorder: [Bool]
        
        init(id: UInt64, image: String) throws {
            let convertedImage = image
                .split(separator: "\n")
                .map {
                    $0.map { $0 == "#" }
                }
            
            try self.init(id: id, image: convertedImage)
        }
        
        init(id: UInt64, image: [[Bool]]) throws {
            self.id = id
            self.image = image
            
            guard
                !image.isEmpty,
                !image[0].isEmpty
            else {
                throw InputError(message: "Invalid input")
            }
            
            topBorder = image[0]
            bottomBorder = image[image.count - 1]
            leftBorder = image.map { $0[0] }
            rightBorder = image.map { $0[$0.count - 1] }
        }
        
        var description: String {
            return image
                .map { row in String(row.map { $0 ? "#" : "." }) }
                .joined(separator: "\n")
        }
        
        mutating func normalize() {
            switch rotated {
            case 1:
                image = (0..<image.count).map { i in
                    image.lazy.reversed().map { $0[i] }
                }
            case 2:
                for i in 0..<image.count {
                    image[i].reverse()
                }
                image.reverse()
            case 3:
                image = (0..<image.count).reversed().map { i in
                    image.map { $0[i] }
                }
            default:
                break
            }
            
            if flipped {
                for i in 0..<image.count {
                    image[i].reverse()
                }
            }
            
            rotated = 0
            flipped = false
        }
        
        mutating func rotate() {
            let tempBorder = topBorder
            
            topBorder = leftBorder
            topBorder.reverse()
            
            leftBorder = bottomBorder
            
            bottomBorder = rightBorder
            bottomBorder.reverse()
            
            rightBorder = tempBorder
            
            rotated = ((rotated + (flipped ? -1 : 1)) + 4) % 4
        }
        
        mutating func flip() {
            let tempBorder = leftBorder
            leftBorder = rightBorder
            rightBorder = tempBorder
            
            topBorder.reverse()
            bottomBorder.reverse()
            
            flipped.toggle()
        }
        
        func canCombine(with tile: Self, method: CombineMethod) -> Bool {
            guard id != tile.id else {
                return false
            }
            
            switch method {
            case .left:
                return tile.rightBorder == leftBorder
            case .right:
                return rightBorder == tile.leftBorder
            case .top:
                return tile.bottomBorder == topBorder
            case .bottom:
                return bottomBorder == tile.topBorder
            }
        }
        
        func enumerateOrientations(_ handler: (Tile, _ stop: inout Bool) -> Void) {
            var tile = self
            var stop: Bool = false
            
            for _ in 0..<4 {
                handler(tile, &stop)
                if stop {
                    break
                }
                tile.rotate()
            }
            
            tile.flip()
            
            for _ in 0..<4 {
                handler(tile, &stop)
                if stop {
                    break
                }
                tile.rotate()
            }
        }
        
        func findOrientation(for filters: [Filter], availableTiles: inout [Tile]) -> Tile? {
            var foundTile: Tile? = nil
            enumerateOrientations { tile, stop in
                if !filters.contains(where: { !tile.matches($0, availableTiles: &availableTiles) }) {
                    foundTile = tile
                    stop = true
                }
            }
            return foundTile
        }
        
        func matches(_ filter: Filter, availableTiles: inout [Tile]) -> Bool {
            switch filter.criteria {
            case .empty:
                let invertedFilter = Filter(method: filter.method.inverted, criteria: .tile(self))
                return !availableTiles.contains {
                    $0.findOrientation(for: [invertedFilter], availableTiles: &availableTiles) != nil
                }
                
            case .anyTile:
                let invertedFilter = Filter(method: filter.method.inverted, criteria: .tile(self))
                for tile in availableTiles {
                    if let orientedTile = tile.findOrientation(for: [invertedFilter], availableTiles: &availableTiles) {
                        // Make sure the found tile is put as the next possible available tile, making
                        // searching a lot faster.
                        if let index = availableTiles.firstIndex(where: { $0.id == tile.id }) {
                            availableTiles.remove(at: index)
                        }
                        availableTiles.insert(orientedTile, at: 0)
                        return true
                    }
                }
                return false
                
            case .tile(let tile):
                return canCombine(with: tile, method: filter.method)
            }
        }
    }
    
    private func getTiles() async throws -> [Tile] {
        var tiles: [Tile] = []
        try await getStreamedInput(delimiter: "\n\n") { string in
            guard let idStringEndIndex = string.firstIndex(of: "\n") else {
                throw InputError(message: "Invalid input")
            }
            
            let idString = string[..<idStringEndIndex]
            let idStartIndex = string.index(string.startIndex, offsetBy: 5)
            let idEndIndex = string.index(before: idStringEndIndex)
            
            guard
                idString.count > 6,
                let id = UInt64(string[idStartIndex..<idEndIndex])
            else {
                throw InputError(message: "Invalid input")
            }
            
            let imageStartIndex = string.index(after: idStringEndIndex)
            guard imageStartIndex < string.endIndex else {
                throw InputError(message: "Invalid input")
            }
            
            let image = String(string[imageStartIndex...])
            try tiles.append(Tile(id: id, image: image))
        }
        return tiles
    }
    
    private func findTile(in tiles: inout [Tile], for filters: [Filter]) throws -> Tile {
        for tile in tiles {
            if var orientedTile = tile.findOrientation(for: filters, availableTiles: &tiles) {
                orientedTile.normalize()
                return orientedTile
            }
        }
        
        throw InputError(message: "Invalid input")
    }
    
    private func determinGrid(for tiles: [Tile]) throws -> [[Tile]] {
        let gridSize = Int(sqrt(Double(tiles.count)))
        var grid: [[Tile]] = []
        var tiles = tiles
        
        for y in 0..<gridSize {
            var gridRow: [Tile] = []
            
            for x in 0..<gridSize {
                let tile = try findTile(in: &tiles, for: [
                    Filter(method: .top, criteria: y > 0 ? .tile(grid[y - 1][x]) : .empty),
                    Filter(method: .left, criteria: x > 0 ? .tile(gridRow[x - 1]) : .empty),
                    Filter(method: .bottom, criteria: y < gridSize - 1 ? .anyTile : .empty),
                    Filter(method: .right, criteria: x < gridSize - 1 ? .anyTile : .empty),
                ])
                
                gridRow.append(tile)
                if let index = tiles.firstIndex(where: { $0.id == tile.id }) {
                    tiles.remove(at: index)
                }
            }
            
            grid.append(gridRow)
        }
        
        return grid
    }
    
    private func joinGrid(_ grid: [[Tile]]) throws -> Tile {
        let tileSize = grid[0][0].image.count
        guard tileSize > 0 && grid[0][0].image[0].count == tileSize else {
            throw InputError(message: "Invalid input")
        }
        
        let tileRange = 1...(tileSize-2)
        let image = grid.reduce([]) { image, row in
            image + tileRange.map { index in
                row.reduce([]) { $0 + $1.image[index][tileRange] }
            }
        }
        return try Tile(id: 0, image: image)
    }
    
    private func getSeaMonsterPattern(gridSize: Int) -> [Bool] {
        let seaMonster =
        """
                          #
        #    ##    ##    ###
         #  #  #  #  #  #
        """
        
        var pattern: [Bool] = []
        seaMonster.components(separatedBy: "\n").forEach { line in
            pattern += line.map { $0 == "#" }
            if line.count < gridSize {
                pattern.append(contentsOf: Array<Bool>(repeating: false, count: gridSize - line.count))
            }
        }
        return pattern
    }
    
    private func firstIndex(of pattern: [Bool], in line: [Bool]) -> Int? {
        if pattern == line {
            return 0
        }
        
        guard line.count > pattern.count else {
            return nil
        }
        
        for i in 0..<(line.count - pattern.count) {
            var isMatch: Bool = true
            for j in i..<(i+pattern.count) {
                if pattern[j-i] && !line[j] {
                    isMatch = false
                    break
                }
            }
            
            if isMatch {
                return i
            }
        }
        
        return nil
    }
}
