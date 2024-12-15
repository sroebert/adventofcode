struct Assignment201603: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let triangles = try await getTriangles()
        return triangles.count(where: \.isValid)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let triangles = try await getTriangles()
        let realTriangles = stride(from: 0, to: triangles.count, by: 3).flatMap { index in
            [
                Triangle(
                    side1: triangles[index].side1,
                    side2: triangles[index+1].side1,
                    side3: triangles[index+2].side1
                ),
                Triangle(
                    side1: triangles[index].side2,
                    side2: triangles[index+1].side2,
                    side3: triangles[index+2].side2
                ),
                Triangle(
                    side1: triangles[index].side3,
                    side2: triangles[index+1].side3,
                    side3: triangles[index+2].side3
                ),
            ]
        }
        return realTriangles.count(where: \.isValid)
    }
    
    // MARK: - Utils
    
    private struct Triangle {
        var side1: Int
        var side2: Int
        var side3: Int
        
        var isValid: Bool {
            return (
                side1 + side2 > side3 &&
                side2 + side3 > side1 &&
                side1 + side3 > side2
            )
        }
    }
    
    private func getTriangles() async throws -> [Triangle] {
        try await mapInput { line in
            let numbers = line.split(whereSeparator: \.isWhitespace).compactMap { Int($0) }
            guard numbers.count == 3 else {
                throw InputError(message: "Invalid input")
            }
            return Triangle(
                side1: numbers[0],
                side2: numbers[1],
                side3: numbers[2]
            )
        }
    }
}
