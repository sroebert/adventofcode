struct Assignment202402: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        try await mapInput { line in
            line
                .split(whereSeparator: \.isWhitespace)
                .compactMap { Int($0) }
                .isReportSafe
        }.count {
            $0
        }
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        try await mapInput { line in
            line
                .split(whereSeparator: \.isWhitespace)
                .compactMap { Int($0) }
                .isReportSafeWithProblemDampener
        }.count {
            $0
        }
    }
}

private extension RandomAccessCollection where Element == Int, Index == Int {
    var isReportSafe: Bool {
        guard count >= 2 else {
            return false
        }
        
        let minChange = 1
        let maxChange = 3
        let direction = (self[1] - self[0]).signum()
        
        for i in 1..<count {
            let change = self[i] - self[i - 1]
            
            if change.signum() != direction {
                return false
            }
            
            if abs(change) < minChange || abs(change) > maxChange {
                return false
            }
        }
        
        return true
    }
    
    var isReportSafeWithProblemDampener: Bool {
        guard count >= 2 else {
            return false
        }
        
        return (0..<count).contains { skipIndex in
            ProblemDampenerCollection(report: self, skipIndex: skipIndex).isReportSafe
        }
    }
}

private struct ProblemDampenerCollection<T: RandomAccessCollection>: RandomAccessCollection where T.Element == Int, T.Index == Int {
    
    // MARK: - Public Vars
    
    var report: T
    var skipIndex: Int
    
    // MARK: - Collection
    
    var startIndex: T.Index {
        return report.startIndex
    }
    
    var endIndex: T.Index {
        return report.index(report.endIndex, offsetBy: -1)
    }
    
    subscript(index: T.Index) -> Int {
        get {
            if index >= report.index(report.startIndex, offsetBy: skipIndex) {
                return report[report.index(after: index)]
            }
            return report[index]
        }
    }
    
    func index(after i: T.Index) -> T.Index {
        let afterIndex = report.index(after: i)
        if afterIndex == report.index(report.startIndex, offsetBy: skipIndex) {
            return report.index(after: afterIndex)
        }
        return afterIndex
    }
}
