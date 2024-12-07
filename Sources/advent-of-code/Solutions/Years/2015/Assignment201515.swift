@preconcurrency import Algorithms

struct Assignment201515: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let ingredients = try await getIngredients()
        return await findBestScore(for: ingredients, spoonCount: 100)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let ingredients = try await getIngredients()
        return await findBestScore(for: ingredients, spoonCount: 100, caloryCount: 500)
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    var isSlowInRelease: Bool {
        return true
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
    
    private func generateSelections(ingredientCount: Int, spoonCount: Int) -> [[Int]] {
        var selections: [[Int]] = []
        var stack: [(startIndex: Int, selection: [Int])] = [(0, [])]

        while !stack.isEmpty {
            let (startIndex, selection) = stack.removeLast()

            // If the selection is complete, add it as a result
            if selection.count == spoonCount {
                selections.append(selection)
                continue
            }

            // Iterate over all possible ingredients, allowing reuse
            (startIndex..<ingredientCount).forEach {
                stack.append(($0, selection + [$0]))
            }
        }

        return selections
    }
    
    private func findBestScore(
        for ingredients: [Ingredient],
        spoonCount: Int,
        caloryCount: Int? = nil
    ) async -> Int {
        await generateSelections(ingredientCount: ingredients.count, spoonCount: spoonCount).concurrentMax(minimum: 0) { selection in
            var capacity = 0
            var durability = 0
            var flavor = 0
            var texture = 0
            var calories = 0
            
            selection.forEach {
                capacity += ingredients[$0].capacity
                durability += ingredients[$0].durability
                flavor += ingredients[$0].flavor
                texture += ingredients[$0].texture
                calories += ingredients[$0].calories
            }
            
            if let caloryCount, calories != caloryCount {
                return 0
            }
            
            if capacity <= 0 || durability <= 0 || flavor <= 0 || texture <= 0 {
                return 0
            }
            
            return capacity * durability * flavor * texture
        }
    }
}
