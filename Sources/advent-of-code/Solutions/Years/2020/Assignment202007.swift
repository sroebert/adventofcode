struct Assignment202007: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        try await getBags().values.count { $0.containsShinyGold }
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        guard let bag = try await getBags()[Bag.shinyGoldId] else {
            throw InputError(message: "Invalid input")
        }
        
        var bagCount = 0
        bag.traverseChildren { bagCount += $1 }
        return bagCount
    }
    
    // MARK: - Utils
    
    private class BagWrapper {
        weak var bag: Bag?
        
        init(_ bag: Bag) {
            self.bag = bag
        }
    }
    
    private class Bag {
        static let shinyGoldId = "shiny gold"
        
        let id: String
        
        init(id: String) {
            self.id = id
        }
        
        private(set) var parents: [BagWrapper] = []
        private(set) var children: [(Bag, Int)] = []
        
        private(set) var containsShinyGold: Bool = false
        
        func traverseParents(_ process: (Bag) -> Void) {
            var stack: [BagWrapper] = parents
            while !stack.isEmpty {
                let parent = stack.removeFirst()
                stack.append(contentsOf: parent.bag?.parents ?? [])
                parent.bag.map { process($0) }
            }
        }
        
        func traverseChildren(_ process: (Bag, Int) -> Void) {
            var stack: [(Bag, Int)] = children
            while !stack.isEmpty {
                let child = stack.removeFirst()
                
                let multipliedChildren = child.0.children.map { ($0, $1 * child.1) }
                stack.append(contentsOf: multipliedChildren)
                
                process(child.0, child.1)
            }
        }
        
        func contains(_ bag: Bag, count: Int) {
            if bag.id == Bag.shinyGoldId || bag.containsShinyGold {
                containsShinyGold = true
                
                traverseParents { parent in
                    parent.containsShinyGold = true
                }
            }
            
            bag.parents.append(BagWrapper(self))
            children.append((bag, count))
        }
    }
    
    private func getBags() async throws -> [String:Bag] {
        let lineRegex = /(?<bagId>.+) bags contain (?<contains>.+)\./
        let containsRegex = /(?<bagCount>\d\d*) (?<bagId>[^\d]+) bags?/
        
        var bags: [String:Bag] = [:]
        try await getStreamedInput() { line in
            guard let match = line.wholeMatch(of: lineRegex) else {
                return
            }
            
            let bagId = String(match.output.bagId)
            let bag = bags[bagId] ?? Bag(id: bagId)
            bags[bagId] = bag
            
            let containsString = match.output.contains
            if containsString == "no other bags" {
                return
            }
            
            for containsMatch in containsString.matches(of: containsRegex) {
                let containsBagCount = Int(containsMatch.output.bagCount) ?? 0
                let containsBagId = String(containsMatch.output.bagId)
                
                let containsBag = bags[containsBagId] ?? Bag(id: containsBagId)
                bags[containsBagId] = containsBag
                
                bag.contains(containsBag, count: containsBagCount)
            }
        }
        return bags
    }
}
