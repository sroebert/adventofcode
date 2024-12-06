struct Assignment202003: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let input = try await getInput()
        return traverse(input, stepX: 3, stepY: 1)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let input = try await getInput()
        return [
            (1, 1),
            (3, 1),
            (5, 1),
            (7, 1),
            (1, 2)
        ].map {
            traverse(input, stepX: $0.0, stepY: $0.1)
        }.reduce(1, *)
    }
    
    // MARK: - Utils
    
    private func getInput() async throws -> [[Bool]] {
        let input = try await getInput()
            .split(separator: "\n")
            .map { line in
                return line.map { $0 == "#" }
            }
        
        guard input.count > 0 else {
            throw InputError(message: "Invalid input")
        }
        
        let width = input[0].count
        guard !input.contains(where: { $0.count != width }) else {
            throw InputError(message: "Invalid input")
        }
        
        return input
    }
    
    private func traverse(_ input: [[Bool]], stepX: Int, stepY: Int) -> Int {
        var x = 0
        var y = 0
        var counter = 0
        
        let width = input[0].count
        let height = input.count
        
        repeat {
            if input[y][x] {
                counter += 1
            }
            
            x = (x + stepX) % width
            y += stepY
        } while y >= 0 && y < height
        
        return counter
    }
}
