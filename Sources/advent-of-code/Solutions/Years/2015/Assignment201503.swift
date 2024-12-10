struct Assignment201503: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var point = Point(x: 0, y: 0)
        
        var set = Set<Point>()
        set.insert(point)
        
        for character in try await getInput() {
            point = point + offset(for: character)
            set.insert(point)
        }
        
        return set.count
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var point1 = Point(x: 0, y: 0)
        var point2 = Point(x: 0, y: 0)
        
        var set = Set<Point>()
        set.insert(point1)
        
        var index = 1
        for character in try await getInput() {
            if index == 1 {
                point1 = point1 + offset(for: character)
                set.insert(point1)
            } else {
                point2 = point2 + offset(for: character)
                set.insert(point2)
            }
            index = 3 - index
        }
        
        return set.count
    }
    
    // MARK: - Utils
    
    private func offset(for character: Character) -> Point {
        switch character {
        case ">":
            return Point(x: 1, y: 0)
        case "<":
            return Point(x: -1, y: 0)
        case "v":
            return Point(x: 0, y: 1)
        default:
            return Point(x: 0, y: -1)
        }
    }
}
