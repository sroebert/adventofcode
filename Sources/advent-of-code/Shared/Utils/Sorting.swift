extension Sequence {
    func map<T: Comparable>(
        _ transform: (Element) throws -> T,
        andSortUsing areInIncreasingOrder: (T, T) -> Bool
    ) rethrows -> [T] {
        try reduce(into: []) { sortedList, element in
            let comparableValue = try transform(element)
            if let index = sortedList.firstIndex(where: { !areInIncreasingOrder($0, comparableValue) }) {
                sortedList.insert(comparableValue, at: index)
            } else {
                sortedList.append(comparableValue)
            }
        }
    }
    
    func mapAndSort<T: Comparable>(_ transform: (Element) throws -> T) rethrows -> [T] {
        try map(transform, andSortUsing: <)
    }
}
