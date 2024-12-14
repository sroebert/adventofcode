import RegexBuilder

struct Assignment202414: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var robots = try await getRobots()
        for i in robots.indices {
            robots[i].move(seconds: 100, spaceSize: robotSpaceSize)
        }
        return safetyScore(forRobots: robots)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var robots = try await getRobots()
        
        let center = Point(
            x: robotSpaceSize.width / 2,
            y: robotSpaceSize.height / 2
        )
        
        let distanceToCenterSearchValue = robots.reduce(0) {
            $0 + $1.position.distance(to: center)
        } * 0.7
        var seconds = 0
        while true {
            for i in robots.indices {
                robots[i].move(seconds: 1, spaceSize: robotSpaceSize)
            }
            seconds += 1
            
            let totalDistanceToCenter = robots.reduce(0) {
                $0 + $1.position.distance(to: center)
            }
            if totalDistanceToCenter < distanceToCenterSearchValue {
                return seconds
            }
        }
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private let robotSpaceSize = Size(width: 101, height: 103)
    
    private func getQuadrants() -> [Rect] {
        let width = robotSpaceSize.width - 1
        let height = robotSpaceSize.height - 1
        let quadrantSize = Size(
            width: width / 2 - 1,
            height: height / 2 - 1
        )
        return [
            Rect(
                origin: .zero,
                size: quadrantSize
            ),
            Rect(
                origin: Point(
                    x: 0,
                    y: height - quadrantSize.height
                ),
                size: quadrantSize
            ),
            Rect(
                origin: Point(
                    x: width - quadrantSize.width,
                    y: 0
                ),
                size: quadrantSize
            ),
            Rect(
                origin: Point(
                    x: width - quadrantSize.width,
                    y: height - quadrantSize.height
                ),
                size: quadrantSize
            ),
        ]
    }
    
    private func safetyScore(forRobots robots: [Robot]) -> Int {
        return getQuadrants().map { quadrant in
            robots.count { quadrant.contains($0.position) }
        }.reduce(1, *)
    }
    
    private func printSpace(size: Size, robots: [Robot]) {
        (0..<size.height).forEach { y in
            print((0..<size.width).map { x in
                let count = robots.count { $0.position.x == x && $0.position.y == y }
                return count > 0 ? String(count) : "."
            }.joined())
        }
    }
    
    private struct Robot {
        var position: Point
        var velocity: Point
        
        mutating func move(seconds: Int, spaceSize: Size) {
            position.x = (position.x + velocity.x * seconds) % spaceSize.width
            if position.x < 0 {
                position.x += spaceSize.width
            }
            
            position.y = (position.y + velocity.y * seconds) % spaceSize.height
            if position.y < 0 {
                position.y += spaceSize.height
            }
        }
    }
    
    private func getRobots() async throws -> [Robot] {
        let pX = Reference(Int.self)
        let pY = Reference(Int.self)
        let vX = Reference(Int.self)
        let vY = Reference(Int.self)
        
        func captureInt(_ reference: Reference<Int>) -> TryCapture<(Substring, Int)> {
            TryCapture(as: reference) {
                Optionally {
                    "-"
                }
                OneOrMore(.digit)
            } transform: {
                Int($0)
            }
        }
        
        let regex = Regex {
            "p="
            captureInt(pX)
            ","
            captureInt(pY)
            " v="
            captureInt(vX)
            ","
            captureInt(vY)
        }
        
        return try await mapInput { line in
            guard let match = line.wholeMatch(of: regex) else {
                throw InputError(message: "Invalid input")
            }
            
            return Robot(
                position: Point(
                    x: match[pX],
                    y: match[pY]
                ),
                velocity: Point(
                    x: match[vX],
                    y: match[vY]
                )
            )
        }
    }
}
