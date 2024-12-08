struct Assignment201518: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var lightGridA = try await getLightGrid()
        var lightGridB = lightGridA
        
        (0..<100).forEach { _ in
            performAnimationStep(lightGridA, &lightGridB)
            swap(&lightGridA, &lightGridB)
        }
        
        return lightGridA.reduce(0) {
            $0 + $1.reduce(0) {
                $0 + ($1 ? 1 : 0)
            }
        }
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var lightGridA = try await getLightGrid()
        turnOnCornerLights()
        
        var lightGridB = lightGridA
        
        func turnOnCornerLights() {
            lightGridA[1][1] = true
            lightGridA[lightGridA.count - 2][1] = true
            lightGridA[1][lightGridA[0].count - 2] = true
            lightGridA[lightGridA.count - 2][lightGridA[0].count - 2] = true
        }
        
        (0..<100).forEach { _ in
            performAnimationStep(lightGridA, &lightGridB)
            swap(&lightGridA, &lightGridB)
            turnOnCornerLights()
        }
        
        return lightGridA.reduce(0) {
            $0 + $1.reduce(0) {
                $0 + ($1 ? 1 : 0)
            }
        }
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private let checkOffsets: [(Int, Int)] = [
        (-1, -1), (-1, 0), (-1, 1),
        (0, -1), (0, 1),
        (1, -1), (1, 0), (1, 1),
    ]
    
    private func performAnimationStep(
        _ source: [[Bool]],
        _ destination: inout [[Bool]]
    ) {
        for y in 1..<(source.count - 1) {
            for x in 1..<(source[y].count - 1) {
                let onNeighbors = checkOffsets.count { source[y + $0.1][x + $0.0] }
                if source[y][x] {
                    destination[y][x] = onNeighbors == 2 || onNeighbors == 3
                } else {
                    destination[y][x] = onNeighbors == 3
                }
            }
        }
    }
    
    private func getLightGrid() async throws -> [[Bool]] {
        let lightGrid = try await mapInput { line in
            [false] + line.map { $0 == "#" } + [false]
        }
        
        let offRow = Array(repeating: false, count: lightGrid[0].count)
        return [offRow] + lightGrid + [offRow]
    }
}
