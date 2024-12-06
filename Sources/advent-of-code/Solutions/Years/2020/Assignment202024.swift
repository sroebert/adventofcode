struct Assignment202024: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        try await getBlackTiles().count
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var blackTiles = try await getBlackTiles()
        for _ in 0..<100 {
            performDayRules(on: &blackTiles)
        }
        return blackTiles.count
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    var isSlowInRelease: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private struct Position: Equatable, Hashable {
        var x: Int
        var y: Int
        
        static let reference: Self = .init(x: 0, y: 0)
        
        mutating func move(in direction: Direction) {
            switch direction {
            case .east:
                x += 2
            case .west:
                x -= 2
            case .northEast:
                x += 1
                y -= 1
            case .southEast:
                x += 1
                y += 1
            case .northWest:
                x -= 1
                y -= 1
            case .southWest:
                x -= 1
                y += 1
            }
        }
        
        func enumerateAdjacentPositions(_ handler: (Position, inout Bool) -> Void) {
            var stop = false
            for direction in Direction.allCases {
                var position = self
                position.move(in: direction)
                handler(position, &stop)
                
                if stop {
                    break
                }
            }
        }
        
        var adjacentPositions: [Position] {
            return Direction.allCases.map {
                var position = self
                position.move(in: $0)
                return position
            }
        }
    }
    
    private enum Direction: String, CaseIterable {
        case east = "e"
        case west = "w"
        case northEast = "ne"
        case southEast = "se"
        case northWest = "nw"
        case southWest = "sw"
        
        static func parse<T: StringProtocol>(_ string: T) throws -> [Direction] {
            var startIndex = string.startIndex
            
            var directions: [Direction] = []
            outerLoop: while startIndex < string.endIndex {
                for direction in Direction.allCases {
                    if string[startIndex...].hasPrefix(direction.rawValue) {
                        directions.append(direction)
                        startIndex = string.index(startIndex, offsetBy: direction.rawValue.count)
                        continue outerLoop
                    }
                }
                
                throw InputError(message: "Invalid input")
            }
            
            return directions
        }
    }
    
    private func dailyBlackTilesToFlip(for blackTiles: Set<Position>) -> [Position] {
        var blackTilesToFlip: [Position] = []
        
        for tile in blackTiles {
            var adjacentCount = 0
            tile.enumerateAdjacentPositions { position, stop in
                if blackTiles.contains(position) {
                    adjacentCount += 1
                }
                
                if adjacentCount == 3 {
                    stop = true
                }
            }
            
            if adjacentCount == 0 || adjacentCount == 3 {
                blackTilesToFlip.append(tile)
            }
        }
        
        return blackTilesToFlip
    }
    
    private func dailyWhiteTilesToFlip(for blackTiles: Set<Position>) -> Set<Position> {
        var whiteTilesToFlip = Set<Position>()
        
        for tile in blackTiles {
            for adjacentTile in tile.adjacentPositions {
                guard !blackTiles.contains(adjacentTile) else {
                    continue
                }
                
                var adjacentCount = 0
                adjacentTile.enumerateAdjacentPositions { position, stop in
                    if tile == position || blackTiles.contains(position) {
                        adjacentCount += 1
                    }
                    
                    if adjacentCount > 2 {
                        stop = true
                    }
                }
                
                if adjacentCount == 2 {
                    whiteTilesToFlip.insert(adjacentTile)
                }
            }
        }
        
        return whiteTilesToFlip
    }
    
    private func performDayRules(on blackTiles: inout Set<Position>) {
        let blackTilesToFlip = dailyBlackTilesToFlip(for: blackTiles)
        let whiteTilesToFlip = dailyWhiteTilesToFlip(for: blackTiles)
        
        blackTiles.subtract(blackTilesToFlip)
        blackTiles.formUnion(whiteTilesToFlip)
    }
    
    private func enumerateInstructions(_ handler: ([Direction]) -> Void) async throws {
        try await getStreamedInput { line in
            let directions = try Direction.parse(line)
            handler(directions)
        }
    }
    
    private func getBlackTiles() async throws -> Set<Position> {
        var blackTiles = Set<Position>()
        
        try await enumerateInstructions { directions in
            var position = Position.reference
            for direction in directions {
                position.move(in: direction)
            }
            
            if blackTiles.remove(position) == nil {
                blackTiles.insert(position)
            }
        }
        
        return blackTiles
    }
}
