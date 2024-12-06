struct Assignment202021: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let entries = try await getFoodEntries()
        let mapping = determineAllergenMapping(from: entries)
        return entries.reduce(0) { total, entry in
            return total + entry.ingredients.count { mapping.ingredientsWithoutAllergen.contains($0) }
        }
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let entries = try await getFoodEntries()
        let mapping = determineAllergenMapping(from: entries)
        return mapping.allergenIngredientMapping
            .sorted { $0.key < $1.key }
            .map { $0.value }
            .joined(separator: ",")
    }
    
    // MARK: - Utils
    
    private struct FoodEntry {
        var ingredients: Set<String>
        var allergens: Set<String>
    }
    
    private struct AllergenMapping {
        var allergenIngredientMapping: [String: String]
        var ingredientsWithoutAllergen: Set<String>
    }
    
    private func getFoodEntries() async throws -> [FoodEntry] {
        var entries: [FoodEntry] = []
        try await getStreamedInput { line in
            guard let allergensBracketIndex = line.firstIndex(of: "(") else {
                throw InputError(message: "Invalid input")
            }
            
            let allergensStartIndex = line.index(allergensBracketIndex, offsetBy: 10)
            let allergensEndIndex = line.index(before: line.endIndex)
            guard allergensStartIndex < allergensEndIndex else {
                throw InputError(message: "Invalid input")
            }
            
            let ingredients = line[line.startIndex..<allergensBracketIndex]
                .split(separator: " ")
                .map { String($0) }
            let allergens = line[allergensStartIndex..<allergensEndIndex]
                .components(separatedBy: ", ")
                .map { String($0) }
            
            entries.append(FoodEntry(
                ingredients: Set(ingredients),
                allergens: Set(allergens)
            ))
        }
        return entries
    }
    
    private func getIngredients(from entries: [FoodEntry]) -> Set<String> {
        var ingredients = Set<String>()
        entries.forEach { entry in
            entry.ingredients.forEach {
                ingredients.insert($0)
            }
        }
        return ingredients
    }
    
    private func getAllergens(from entries: [FoodEntry]) -> [String] {
        var allergens = Set<String>()
        entries.forEach { entry in
            entry.allergens.forEach {
                allergens.insert($0)
            }
        }
        return Array(allergens)
    }
    
    private func determineAllergenMapping(from entries: [FoodEntry]) -> AllergenMapping {
        var ingredients = getIngredients(from: entries)
        var allergens = getAllergens(from: entries)
        
        var allergenIngredientMapping: [String:String] = [:]
        
        var updated: Bool
        repeat {
            updated = false
            
            for (index, allergen) in allergens.enumerated() {
                var possibleIngredients = ingredients
                
                for i in 0..<entries.count {
                    if entries[i].allergens.contains(allergen) {
                        possibleIngredients.formIntersection(entries[i].ingredients)
                    }
                }
                
                if possibleIngredients.count == 1, let ingredient = possibleIngredients.first {
                    ingredients.remove(ingredient)
                    allergenIngredientMapping[allergen] = ingredient
                    allergens.remove(at: index)
                    updated = true
                    break
                }
            }
            
        } while updated
        
        return AllergenMapping(
            allergenIngredientMapping: allergenIngredientMapping,
            ingredientsWithoutAllergen: ingredients
        )
    }
}
