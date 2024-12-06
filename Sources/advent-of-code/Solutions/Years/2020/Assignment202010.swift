struct Assignment202010: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let adapters = try await compactMapInput { Int($0) }.sorted()
        
        var jolts = 0
        var oneDiffCount = 0
        var threeDiffCount = 0
        
        for adapter in adapters {
            guard (1...3).contains(adapter - jolts) else {
                throw InputError(message: "Invalid input")
            }
            
            switch adapter - jolts {
            case 1:
                oneDiffCount += 1
            case 3:
                threeDiffCount += 1
            case 0, 2:
                break
            default:
                throw InputError(message: "Invalid input")
            }
            
            jolts = adapter
        }
        
        threeDiffCount += 1
        
        return oneDiffCount * threeDiffCount
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let adapters = try await compactMapInput { Int($0) }.sorted()
        var paths = [Path(adapter: 0, index: -1, count: 1)]
        
        while !paths.isEmpty {
            let path = paths.removeFirst()
            if path.index == adapters.count - 1 {
                return path.count
            }
            
            var j = 1
            while path.index + j < adapters.count && (1...3).contains(adapters[path.index + j] - path.adapter) {
                let adapter = adapters[path.index + j]
                if let index = paths.firstIndex(where: { $0.adapter == adapter }) {
                    paths[index].count += path.count
                } else {
                    paths.append(Path(
                        adapter: adapter,
                        index: path.index + j,
                        count: path.count
                    ))
                }
                
                j += 1
            }
        }
        
        throw InputError(message: "Invalid input")
    }
    
    // MARK: - Utils
    
    private struct Path {
        var adapter: Int
        var index: Int
        var count: UInt64
    }
}
