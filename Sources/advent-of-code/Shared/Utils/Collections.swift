extension Collection {

    /// Returns the element at a given index in the collection if it exists
    ///
    /// - Parameter index: The index for which to retrieve the element.
    public subscript(safe index: Self.Index) -> Self.Iterator.Element? {
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
    public subscript(safe range: Range<Self.Index>) ->  Self.SubSequence? {
        guard range.lowerBound >= startIndex else {
            return nil
        }

        guard range.upperBound <= endIndex else {
            return nil
        }

        return self[range]
    }
    
    /// Returns `self` if not empty, `nil` otherwise.
    public var selfIfNotEmpty: Self? {
        guard !isEmpty else {
            return nil
        }
        return self
    }
}
