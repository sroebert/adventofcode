import Foundation

extension Collection {

    /// Returns the element at a given index in the collection if it exists
    ///
    /// - Parameter index: The index for which to retrieve the element.
    subscript(safe index: Self.Index) -> Self.Iterator.Element? {
        guard index >= startIndex else {
            return nil
        }

        guard index < endIndex else {
            return nil
        }

        return self[index]
    }

    /// Returns the elements at a given range in the collection if it exists
    ///
    /// - Parameter range: The range for which to retrieve the elements.
    subscript(safe range: Range<Self.Index>) ->  Self.SubSequence? {
        guard range.lowerBound >= startIndex else {
            return nil
        }

        guard range.upperBound <= endIndex else {
            return nil
        }

        return self[range]
    }
    
    /// Returns `self` if not empty, `nil` otherwise.
    var selfIfNotEmpty: Self? {
        guard !isEmpty else {
            return nil
        }
        return self
    }
}

extension Sequence where Self: Sendable {
    func concurrentMapAndReduce<T: Sendable>(
        _ initialResult: T,
        transform: @escaping @Sendable (Element) -> T,
        reduce: @escaping @Sendable (T, T) -> T
    ) async -> T {
        let batchCount = ProcessInfo.processInfo.activeProcessorCount - 2
        guard batchCount > 1 else {
            return self.reduce(initialResult) { reduce($0, transform($1)) }
        }
        
        return await withTaskGroup(of: T.self) { group in
            for taskIndex in 0..<batchCount {
                group.addTask {
                    return dropFirst(taskIndex).striding(by: batchCount).reduce(initialResult) {
                        reduce($0, transform($1))
                    }
                }
            }
            
            return await group.reduce(initialResult, reduce)
        }
    }
    
    func concurrentCount(_ calculate: @escaping @Sendable (Element) -> Int) async -> Int {
        await concurrentMapAndReduce(0, transform: calculate) {
            $0 + $1
        }
    }
    
    func concurrentMax(minimum: Int, _ calculate: @escaping @Sendable (Element) -> Int) async -> Int {
        await concurrentMapAndReduce(minimum, transform: calculate) {
            $0 > $1 ? $0 : $1
        }
    }
    
    func concurrentMin(maximum: Int, _ calculate: @escaping @Sendable (Element) -> Int) async -> Int {
        await concurrentMapAndReduce(maximum, transform: calculate) {
            $0 < $1 ? $0 : $1
        }
    }
}

extension RandomAccessCollection {
    func binarySearch(predicate: (Element) -> Bool) -> Index {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high) / 2)
            if predicate(self[mid]) {
                low = index(after: mid)
            } else {
                high = mid
            }
        }
        return low
    }
}
