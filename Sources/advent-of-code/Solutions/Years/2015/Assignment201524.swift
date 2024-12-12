struct Assignment201524: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let boxes = try await getBoxes()
        return determineBestQuantumEntanglement(forBoxes: boxes, groupCount: 3)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let boxes = try await getBoxes()
        return determineBestQuantumEntanglement(forBoxes: boxes, groupCount: 4)
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    var isSlowInRelease: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private struct GroupConfiguration {
        var weight: Int = 0
        var boxesOffset: Int = 0
        var boxes: [Int] = []
    }
    
    private struct SearchStackEntry {
        var configurations: [GroupConfiguration]
        var boxesUsed: [Bool]
        var weightLeft: Int
    }
    
    private func determineBestQuantumEntanglement(forBoxes boxes: [Int], groupCount: Int) -> Int {
        let desiredGroupWeight = boxes.reduce(0, +) / groupCount
        
        var validConfigs: [[GroupConfiguration]] = []
        
        var stack = [(groups: Array(repeating: GroupConfiguration(), count: groupCount), boxes: boxes)]
        var minimumBoxes = Int.max
        
        while !stack.isEmpty {
            var (groups, boxes) = stack.removeLast()
            
            guard !boxes.isEmpty else {
                if !groups.contains(where: { $0.weight != desiredGroupWeight }) {
                    groups.sort(by: { $0.boxes.count < $1.boxes.count })
                    if groups[0].boxes.count < minimumBoxes {
                        minimumBoxes = groups[0].boxes.count
                        validConfigs = [groups]
                    } else if groups[0].boxes.count == minimumBoxes {
                        validConfigs.append(groups)
                    }
                }
                continue
            }
            
            let box = boxes.removeLast()
            
            for groupIndex in 0..<groupCount {
                guard
                    (groupIndex == 0 || groups[groupIndex].boxes.count > 0 || groups[groupIndex].boxes.count < groups[groupIndex - 1].boxes.count),
                    groups[groupIndex].weight + box <= desiredGroupWeight
                else {
                    continue
                }
                
                var nextGroups = groups
                nextGroups[groupIndex].boxes.append(box)
                nextGroups[groupIndex].weight += box
                stack.append((nextGroups, boxes))
            }
        }
        
        let sortedConfigs = validConfigs.compactMap { $0 }.map { configs -> (configs: [GroupConfiguration], quantumEntanglement: Int) in
            (configs: configs, quantumEntanglement: configs[0].boxes.reduce(1, *))
        }.sorted { a, b in
            guard a.configs[0].boxes.count != b.configs[0].boxes.count else {
                return a.quantumEntanglement < b.quantumEntanglement
            }
            return a.configs[0].boxes.count < b.configs[0].boxes.count
        }
        
        return sortedConfigs[0].quantumEntanglement
    }
    
    private func getBoxes() async throws -> [Int] {
        try await compactMapInput {
            Int($0)
        }.sorted(by: >)
    }
}
