struct Assignment202406: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let (map, patrollingGuard) = try await parseInput()
        let (visitedSpaces, _, _) = map.determineGuardMovements(patrollingGuard)
        return visitedSpaces
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let (map, patrollingGuard) = try await parseInput()
        
        var count = 0
        map.determineGuardMovements(patrollingGuard) { updatedMap, patrollingGuard, nextPosition in
            var updatedMap = updatedMap
            updatedMap[nextPosition] = .blocked
            
            let (_, loop, _) = updatedMap.determineGuardMovements(patrollingGuard)
            if loop {
                count += 1
            }
        }
        
        return count
    }
    
    // MARK: - Utils
    
    private struct Map {
        var data: [[MapSpace]]
        
        subscript(_ position: Position) -> MapSpace {
            get {
                data[position.y][position.x]
            }
            mutating set {
                data[position.y][position.x] = newValue
            }
        }
        
        var rowCount: Int {
            return data.count
        }
        
        var columnCount: Int {
            return data[0].count
        }
        
        @discardableResult
        func determineGuardMovements(
            _ patrollingGuard: Guard,
            emptyStepHandler: ((_ map: Map, _ patrollingGuard: Guard, _ nextPosition: Position) -> Void) = { _, _, _ in }
        ) -> (visitedSpaces: Int, loop: Bool, updatedMap: Map) {
            var map = self
            var patrollingGuard = patrollingGuard
            
            var visitedSpaces = 1
            map[patrollingGuard.position] = .visited(directions: patrollingGuard.direction)
            
            while true {
                let nextPosition = patrollingGuard.nextPosition
                if nextPosition.isOutsideOfMap(map) {
                    return (visitedSpaces, false, map)
                }
                
                let space = map[nextPosition]
                switch space {
                case .empty:
                    visitedSpaces += 1
                    
                    emptyStepHandler(map, patrollingGuard, nextPosition)
                    
                    map[nextPosition] = .visited(directions: patrollingGuard.direction)
                    patrollingGuard.position = nextPosition
                    
                case .visited(var directions):
                    guard !directions.contains(patrollingGuard.direction) else {
                        return (visitedSpaces, true, map)
                    }
                    
                    directions.insert(patrollingGuard.direction)
                    
                    map[nextPosition] = .visited(directions: directions)
                    patrollingGuard.position = nextPosition
                    
                case .blocked:
                    patrollingGuard.rotate()
                    
                    if case .visited(var directions) = map[patrollingGuard.position] {
                        directions.insert(patrollingGuard.direction)
                        map[patrollingGuard.position] = .visited(directions: directions)
                    }
                }
            }
        }
    }
    
    private struct Guard {
        var position: Position
        var direction: Directions
        
        mutating func rotate() {
            switch direction {
            case .up:
                direction = .right
            case .left:
                direction = .up
            case .right:
                direction = .down
            case .down:
                direction = .left
            default:
                break
            }
        }
        
        var nextPosition: Position {
            var nextPosition = position
            switch direction {
            case .up:
                nextPosition.y -= 1
            case .left:
                nextPosition.x -= 1
            case .right:
                nextPosition.x += 1
            case .down:
                nextPosition.y += 1
            default:
                break
            }
            return nextPosition
        }
    }
    
    private struct Position: Equatable {
        var x: Int
        var y: Int
        
        func isOutsideOfMap(_ map: Map) -> Bool {
            return x < 0 || y < 0 || x >= map.columnCount || y >= map.rowCount
        }
    }
    
    private struct Directions: OptionSet {
        let rawValue: UInt8

        static let up       = Directions(rawValue: 1 << 0)
        static let left     = Directions(rawValue: 1 << 1)
        static let right    = Directions(rawValue: 1 << 2)
        static let down     = Directions(rawValue: 1 << 3)
        
        init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        init?(_ character: Character) {
            switch character {
            case "^": self = .up
            case "<": self = .left
            case ">": self = .right
            case "v": self = .down
            default: return nil
            }
        }
    }
    
    private enum MapSpace: Equatable {
        case empty
        case visited(directions: Directions)
        case blocked
        
        var isVisited: Bool {
            if case .visited = self {
                return true
            }
            return false
        }
    }
    
    private func parseInput() async throws -> (map: Map, guard: Guard) {
        let map = try await mapInput(Array.init)
        
        for (y, row) in map.enumerated() {
            for (x, character) in row.enumerated() {
                if let direction = Directions(character) {
                    return (
                        Map(data: map.map {
                            $0.map { $0 == "#" ? .blocked : .empty }
                        }),
                        Guard(
                            position: Position(x: x, y: y),
                            direction: direction
                        )
                    )
                }
            }
        }
        
        throw InputError(message: "Guard not found")
    }
}
