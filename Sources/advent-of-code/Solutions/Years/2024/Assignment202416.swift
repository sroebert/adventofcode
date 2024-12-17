import Collections

struct Assignment202416: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let maze = try await getMaze()
        return findOptimalRoutes(through: maze)?.score ?? Int.max
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let maze = try await getMaze()
        return findOptimalRoutes(through: maze)?.visitedLocations.count ?? 0
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    var isSlowInRelease: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private func findOptimalRoutes(through maze: Maze) -> (visitedLocations: Set<Point>, score: Int)? {
        let initialEntry = PathStackEntry(position: maze.startTile, visitedPositions: [maze.startTile])
        var stack = [initialEntry]
        var visitedScores = [
            VisitedKey(position: initialEntry.position, direction: initialEntry.direction): initialEntry.score
        ]
        
        var bestScore = Int.max
        var bestVisitedLocations: Set<Point> = []
        
        while !stack.isEmpty {
            let entry = stack.removeFirst()
            guard entry.position != maze.endTile else {
                guard bestVisitedLocations.isEmpty || entry.score == bestScore else {
                    return (bestVisitedLocations, bestScore)
                }
                
                bestScore = entry.score
                bestVisitedLocations.formUnion(entry.visitedPositions)
                continue
            }
            
            Step.allCases.forEach { step in
                var nextEntry = entry
                
                switch step {
                case .forward:
                    break
                    
                case .rotateLeft:
                    nextEntry.direction.rotateLeft()
                    nextEntry.steps.append(step)
                    nextEntry.score += step.score
                    
                case .rotateRight:
                    nextEntry.direction.rotateRight()
                    nextEntry.steps.append(step)
                    nextEntry.score += step.score
                }
                
                nextEntry.position += nextEntry.direction.step
                nextEntry.steps.append(.forward)
                nextEntry.score += Step.forward.score
                
                let visitedKey = VisitedKey(position: nextEntry.position, direction: nextEntry.direction)
                guard
                    maze.layout[nextEntry.position.y][nextEntry.position.x] == .empty,
                    nextEntry.visitedPositions.insert(nextEntry.position).inserted,
                    visitedScores[visitedKey, default: Int.max] >= nextEntry.score
                else {
                    return
                }
                
                visitedScores[visitedKey] = nextEntry.score
                nextEntry.estimatedScore = nextEntry.score + estimatedAdditionalScore(
                    from: nextEntry.position,
                    in: nextEntry.direction,
                    to: maze.endTile
                )
                
                let insertionIndex = stack.binarySearch {
                    $0.estimatedScore < nextEntry.estimatedScore
                }
                stack.insert(nextEntry, at: insertionIndex)
            }
        }
        
        return nil
    }
    
    private func estimatedAdditionalScore(from: Point, in direction: CardinalDirection, to: Point) -> Int {
        let horizontalDistance = to.x - from.y
        let verticalDistance = to.y - from.y
        
        let step = direction.step
        
        let horizontalDirection = step.x
        if horizontalDistance.signum() == horizontalDirection.signum() {
            return abs(horizontalDistance) + abs(verticalDistance) + Step.rotationScore
        }
        
        let verticalDirection = step.y
        if verticalDirection.signum() == verticalDirection.signum() {
            return abs(horizontalDistance) + abs(verticalDistance) + Step.rotationScore
        }
        
        return abs(horizontalDistance) + abs(verticalDistance) + Step.rotationScore * 2
    }
    
    private struct PathStackEntry {
        var position: Point
        var direction: CardinalDirection = .east
        
        var steps: [Step] = []
        var score: Int = 0
        var estimatedScore: Int = 0
        
        var visitedPositions: Set<Point>
    }
    
    private struct VisitedKey: Hashable {
        var position: Point
        var direction: CardinalDirection
    }
    
    private enum Step: CaseIterable {
        case forward
        case rotateLeft
        case rotateRight
        
        var score: Int {
            switch self {
            case .forward:
                return 1
            case .rotateLeft, .rotateRight:
                return Self.rotationScore
            }
        }
        
        static let rotationScore = 1000
    }
    
    private enum MazeElement {
        case empty
        case wall
    }
    
    private struct Maze {
        var layout: [[MazeElement]]
        var startTile: Point
        var endTile: Point
    }
    
    private func getMaze() async throws -> Maze {
        let input = try await getInput()
        
        var startTile: Point = .zero
        var endTile: Point = .zero
        
        let layout: [[MazeElement]] = try input.split(separator: "\n").enumerated().map { y, line in
            try line.enumerated().map { x, character in
                switch character {
                case "#":
                    return .wall
                case ".":
                    return .empty
                case "S":
                    startTile = Point(x: x, y: y)
                    return .empty
                case "E":
                    endTile = Point(x: x, y: y)
                    return .empty
                default:
                    throw InputError.invalid
                }
            }
        }
        
        return Maze(layout: layout, startTile: startTile, endTile: endTile)
    }
}
