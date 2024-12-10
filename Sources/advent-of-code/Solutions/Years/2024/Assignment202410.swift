struct Assignment202410: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let map = try await getMap()
        let trails = findTrails(for: map)
        return trails.reduce(0) { $0 + $1.ends.count }
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let map = try await getMap()
        let trails = findTrails(for: map)
        return trails.reduce(0) { $0 + $1.rating }
    }
    
    // MARK: - Utils
    
    private typealias Map = [[Int]]
    
    private struct Trail {
        var head: Point
        var ends: Set<Point>
        var rating: Int
    }
    
    private func findTrails(for map: Map) -> [Trail] {
        var trails: [Trail] = []
        let rows = map.count
        let columns = map[0].count
        
        for y in 0..<rows {
            for x in 0..<columns {
                // Make sure this is a trailhead
                guard map[y][x] == 0 else {
                    continue
                }
                
                // Find trails
                let head = Point(x: x, y: y)
                var ends = Set<Point>()
                var rating: Int = 0
                
                var stack = [(height: 0, position: head)]
                
                while !stack.isEmpty {
                    let (height, position) = stack.removeLast()
                    
                    for nextPosition in position.cardinalNeighbors {
                        let nextHeight = map[nextPosition.y][nextPosition.x]
                        guard nextHeight - height == 1 else {
                            continue
                        }
                        
                        if nextHeight == 9 {
                            ends.insert(nextPosition)
                            rating += 1
                        }
                        
                        stack.append((nextHeight, nextPosition))
                    }
                }
                
                // Save
                trails.append(Trail(head: head, ends: ends, rating: rating))
            }
        }
        
        return trails
    }
    
    private func getMap() async throws -> Map {
        let map = try await mapInput {
            [Int.max] + $0.compactMap(\.wholeNumberValue) + [Int.max]
        }
        
        let border = Array(repeating: Int.max, count: map[0].count)
        return [border] + map + [border]
    }
}
