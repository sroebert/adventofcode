struct Assignment201515: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let ingredients = try await getIngredients()
        return ""
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        return ""
    }
    
    // MARK: - Utils
    
    private struct Ingredient {
        var capacity: Int
        var durability: Int
        var flavor: Int
        var texture: Int
        var calories: Int
    }
    
    private func getIngredients() async throws -> [Ingredient] {
        let regex = /\w+: capacity (?<capacity>-?\d+), durability (?<durability>-?\d+), flavor (?<flavor>-?\d+), texture (?<texture>-?\d+), calories (?<calories>-?\d+)/
        return try await mapInput() { line in
            guard let match = line.wholeMatch(of: regex) else {
                throw InputError(message: "Invalid input")
            }
            
            return Ingredient(
                capacity: Int(match.output.capacity) ?? 0,
                durability: Int(match.output.durability) ?? 0,
                flavor: Int(match.output.flavor) ?? 0,
                texture: Int(match.output.texture) ?? 0,
                calories: Int(match.output.calories) ?? 0
            )
        }
    }
}
