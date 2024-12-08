struct Assignment201517: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let buckets = try await getBuckets()
        return determineBucketCounts(forFillingBuckets: buckets, withEggNogLiters: 150).count
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let buckets = try await getBuckets()
        let bucketCounts = determineBucketCounts(forFillingBuckets: buckets, withEggNogLiters: 150)
        guard let min = bucketCounts.min() else {
            return 0
        }
        
        return bucketCounts.count { $0 == min }
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private func getBuckets() async throws -> [Int] {
        return try await mapInput {
            guard let bucket = Int($0) else {
                throw InputError(message: "Invalid input")
            }
            return bucket
        }
    }
    
    private func determineBucketCounts(
        forFillingBuckets allBuckets: [Int],
        withEggNogLiters expectedLiters: Int
    ) -> [Int] {
        var stack = [(liters: 0, bucketCount: 0, buckets: ArraySlice(allBuckets))]
        
        var bucketCounts: [Int] = []
        while !stack.isEmpty {
            let (liters, bucketCount, buckets) = stack.removeLast()
            
            guard liters < expectedLiters else {
                if liters == expectedLiters {
                    bucketCounts.append(bucketCount)
                }
                continue
            }
            
            buckets.enumerated().forEach { index, bucket in
                stack.append((liters + bucket, bucketCount + 1, buckets.suffix(from: buckets.startIndex + index + 1)))
            }
        }
        
        return bucketCounts
    }
}
