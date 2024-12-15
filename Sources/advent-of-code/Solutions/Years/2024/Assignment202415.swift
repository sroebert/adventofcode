struct Assignment202415: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var (map, robotLocation, moves) = try await getWarehouse()
        for move in moves {
            move.executeOnRobot(from: &robotLocation, on: &map)
        }
        return summedGpsCoordinates(forBoxesOn: map)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let (map, robotLocation, moves) = try await getWarehouse()
        var wideMap = widenMap(map)
        var wideRobotLocation = Point(x: robotLocation.x * 2, y: robotLocation.y)
        
        for move in moves {
            move.executeOnRobot(from: &wideRobotLocation, on: &wideMap)
        }
        return summedGpsCoordinates(forBoxesOn: wideMap)
    }
    
    // MARK: - Utils
    
    private enum Element {
        case empty
        case box
        case wall
        case robot
    }
    
    private typealias Map = [[Element]]
    
    private enum WideMapElement {
        case empty
        case boxLeft
        case boxRight
        case wall
        case robot
    }
    
    private typealias WideMap = [[WideMapElement]]
    
    private func widenMap(_ map: Map) -> WideMap {
        return map.map { row in
            row.flatMap { element -> [WideMapElement] in
                switch element {
                case .empty: [.empty, .empty]
                case .box: [.boxLeft, .boxRight]
                case .wall: [.wall, .wall]
                case .robot: [.robot, .empty]
                }
            }
        }
    }
    
    private enum RobotMove {
        case up
        case down
        case left
        case right
        
        var direction: Point {
            switch self {
            case .up: return Point(x: 0, y: -1)
            case .down: return Point(x: 0, y: 1)
            case .left: return Point(x: -1, y: 0)
            case .right: return Point(x: 1, y: 0)
            }
        }
        
        func executeOnRobot(from location: inout Point, on map: inout Map) {
            let direction = direction
            
            var isMovingTowardsBox = false
            var nextLocation = location + direction
            while map[nextLocation.y][nextLocation.x] == .box {
                nextLocation += direction
                isMovingTowardsBox = true
            }
            
            guard map[nextLocation.y][nextLocation.x] == .empty else {
                return
            }
            
            if isMovingTowardsBox {
                map[nextLocation.y][nextLocation.x] = .box
            }
            
            map[location.y][location.x] = .empty
            location += direction
            map[location.y][location.x] = .robot
        }
        
        func executeOnRobot(from robotLocation: inout Point, on map: inout WideMap) {
            let direction = direction
            let isVertical = direction.y != 0
            
            var boxesBeingMoved: [Point] = []
            
            var locationsToCheck = [robotLocation + direction]
            while !locationsToCheck.isEmpty {
                var nextLocations: [Point] = []
                
                for location in locationsToCheck {
                    switch map[location.y][location.x] {
                    case .boxLeft:
                        boxesBeingMoved.append(location)
                        if isVertical {
                            nextLocations.append(location + direction)
                        }
                        nextLocations.append(Point(x: location.x + 1, y: location.y) + direction)
                        
                    case .boxRight:
                        let boxLeftLocation = Point(x: location.x - 1, y: location.y)
                        boxesBeingMoved.append(boxLeftLocation)
                        nextLocations.append(boxLeftLocation + direction)
                        if isVertical {
                            nextLocations.append(location + direction)
                        }
                        
                    case .wall:
                        // Cannot move
                        return
                        
                    default:
                        break
                    }
                }
                
                locationsToCheck = nextLocations
            }
            
            for boxLocation in boxesBeingMoved.reversed() {
                map[boxLocation.y][boxLocation.x] = .empty
                map[boxLocation.y][boxLocation.x + 1] = .empty
                
                let newBoxLocation = boxLocation + direction
                map[newBoxLocation.y][newBoxLocation.x] = .boxLeft
                map[newBoxLocation.y][newBoxLocation.x + 1] = .boxRight
            }
            
            map[robotLocation.y][robotLocation.x] = .empty
            robotLocation += direction
            map[robotLocation.y][robotLocation.x] = .robot
        }
    }
    
    private func summedGpsCoordinates(forBoxesOn map: Map) -> Int {
        var sum = 0
        for y in map.indices {
            for x in map[y].indices {
                if map[y][x] == .box {
                    sum += x + y * 100
                }
            }
        }
        return sum
    }
    
    private func summedGpsCoordinates(forBoxesOn map: WideMap) -> Int {
        var sum = 0
        for y in map.indices {
            for x in map[y].indices {
                if map[y][x] == .boxLeft {
                    sum += x + y * 100
                }
            }
        }
        return sum
    }
    
    private func printMap(_ map: Map) {
        print("")
        map.forEach { row in
            print(row.map { element in
                switch element {
                case .empty: "."
                case .box: "O"
                case .wall: "#"
                case .robot: "@"
                }
            }.joined())
        }
    }
    
    private func printMap(_ map: WideMap) {
        print("")
        map.forEach { row in
            print(row.map { element in
                switch element {
                case .empty: "."
                case .boxLeft: "["
                case .boxRight: "]"
                case .wall: "#"
                case .robot: "@"
                }
            }.joined())
        }
    }
    
    private func getWarehouse() async throws -> (map: Map, robotLocation: Point, moves: [RobotMove]) {
        let input = try await getInput()
        
        let parts = input.split(separator: "\n\n")
        guard parts.count == 2 else {
            throw InputError(message: "Invalid input")
        }
        
        var robotLocation: Point?
        
        let map: Map = try parts[0].split(separator: "\n").enumerated().map { y, line in
            try line.enumerated().map { x, character in
                switch character {
                case "#":
                    return .wall
                case "O":
                    return .box
                case "@":
                    robotLocation = Point(x: x, y: y)
                    return .robot
                case ".":
                    return .empty
                default:
                    throw InputError(message: "Invalid input")
                }
            }
        }
        
        guard let robotLocation else {
            throw InputError(message: "Invalid input")
        }
        
        let moves: [RobotMove] = try parts[1].split(separator: "\n").flatMap { line in
            try line.map {
                switch $0 {
                case "^": .up
                case "<": .left
                case ">": .right
                case "v": .down
                default: throw InputError(message: "Invalid input")
                }
            }
        }
        
        return (map, robotLocation, moves)
    }
}
