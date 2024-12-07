struct Assignment202404: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let letters = try await mapInput(Array.init)
        
        let word = "XMAS"
        let reverseWord = word.reversed()
        
        let size = letters.count
        var count = 0
        for y in 0..<size {
            for x in 0..<size {
                for mode in SearchCollection.Mode.allCases {
                    let search = SearchCollection(
                        letters: letters,
                        x: x,
                        y: y,
                        word: word,
                        mode: mode
                    )
                    
                    if search.elementsEqual(word) || search.elementsEqual(reverseWord) {
                        count += 1
                    }
                }
            }
        }
        return count
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let letters = try await mapInput(Array.init)
        
        let word = "MAS"
        let reverseWord = word.reversed()
        
        let size = letters.count
        var count = 0
        for y in 0..<size {
            for x in 0..<size {
                let search1 = SearchCollection(
                    letters: letters,
                    x: x,
                    y: y,
                    word: word,
                    mode: .diagonalDown
                )
                
                guard search1.elementsEqual(word) || search1.elementsEqual(reverseWord) else {
                    continue
                }
                
                let search2 = SearchCollection(
                    letters: letters,
                    x: x,
                    y: y + word.count - 1,
                    word: word,
                    mode: .diagonalUp
                )
                
                if search2.elementsEqual(word) || search2.elementsEqual(reverseWord) {
                    count += 1
                }
            }
        }
        return String(count)
    }
    
    var isSlowInDebug: Bool {
        return true
    }
}

private struct SearchCollection: RandomAccessCollection {
    
    // MARK: - Types
    
    enum Mode: CaseIterable {
        case horizontal
        case vertical
        case diagonalUp
        case diagonalDown
    }
    
    // MARK: - Public Vars
    
    var letters: [[Character]]
    var x: Int
    var y: Int
    var word: String
    var mode: Mode
    
    // MARK: - Collection
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        switch mode {
        case .horizontal:
            return x <= letters.count - word.count ? word.count : 0
        case .vertical:
            return y <= letters.count - word.count ? word.count : 0
        case .diagonalUp:
            return x <= letters.count - word.count && y >= word.count - 1 ? word.count : 0
        case .diagonalDown:
            return x <= letters.count - word.count && y <= letters.count - word.count ? word.count : 0
        }
    }
    
    subscript(index: Int) -> Character {
        get {
            switch mode {
            case .horizontal:
                letters[y][x + index]
            case .vertical:
                letters[y + index][x]
            case .diagonalUp:
                letters[y - index][x + index]
            case .diagonalDown:
                letters[y + index][x + index]
            }
        }
    }
}
