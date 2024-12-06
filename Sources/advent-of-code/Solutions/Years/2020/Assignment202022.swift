struct Assignment202022: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var state = try await getGameState()
        while !state.isFinished {
            state.playRound()
        }
        return state.score
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var state = try await getGameState()
        while !state.isFinished {
            try state.playRecursiveRound()
        }
        return state.score
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    var isSlowInRelease: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private struct Decks: Hashable {
        var deck1: [Int]
        var deck2: [Int]
    }
    
    private struct GameState {
        
        enum State {
            case running
            case finished(winner: Int)
        }
        
        private(set) var decks: Decks
        
        private(set) var previousDecks: Set<Decks> = Set()
        private(set) var state: State = .running
        
        mutating func playRound() {
            guard !isFinished else {
                return
            }
            
            previousDecks.insert(decks)
            
            let card1 = decks.deck1.removeFirst()
            let card2 = decks.deck2.removeFirst()
            
            if card1 > card2 {
                decks.deck1.append(card1)
                decks.deck1.append(card2)
            } else {
                decks.deck2.append(card2)
                decks.deck2.append(card1)
            }
            
            if decks.deck1.isEmpty {
                state = .finished(winner: 2)
            } else if decks.deck2.isEmpty {
                state = .finished(winner: 1)
            }
        }
        
        mutating func playRecursiveRound() throws {
            guard !isFinished else {
                return
            }
            
            guard !previousDecks.contains(decks) else {
                state = .finished(winner: 1)
                return
            }
            
            previousDecks.insert(decks)
            
            let card1 = decks.deck1.removeFirst()
            let card2 = decks.deck2.removeFirst()
            
            let winner: Int
            if decks.deck1.count >= card1 && decks.deck2.count >= card2 {
                var recursiveState = GameState(decks: Decks(
                    deck1: Array(decks.deck1[0..<card1]),
                    deck2: Array(decks.deck2[0..<card2])
                ))
                while !recursiveState.isFinished {
                    try recursiveState.playRecursiveRound()
                }
                
                switch recursiveState.state {
                case .running:
                    throw InputError(message: "Something went wrong")
                case .finished(winner: let recursiveWinner):
                    winner = recursiveWinner
                }
                
            } else if card1 > card2 {
                winner = 1
            } else {
                winner = 2
            }
            
            if winner == 1 {
                decks.deck1.append(card1)
                decks.deck1.append(card2)
            } else {
                decks.deck2.append(card2)
                decks.deck2.append(card1)
            }
            
            if decks.deck1.isEmpty {
                state = .finished(winner: 2)
            } else if decks.deck2.isEmpty {
                state = .finished(winner: 1)
            }
        }
        
        var isFinished: Bool {
            switch state {
            case .running:
                return false
            case .finished:
                return true
            }
        }
        
        var score: Int {
            guard case .finished(let winnerIndex) = state else {
                return 0
            }
            
            let deck: [Int]
            if winnerIndex == 1 {
                deck = decks.deck1
            } else {
                deck = decks.deck2
            }
            
            return deck.reversed().enumerated().reduce(0) { total, tuple in
                return total + (tuple.offset + 1) * tuple.element
            }
        }
    }
    
    private func getGameState() async throws -> GameState {
        let decks = try await getInput()
            .components(separatedBy: "\n\n")
            .map { string -> [Int] in
                var lines = string.split(separator: "\n")
                guard lines.count > 1 else {
                    throw InputError(message: "Invalid input")
                }
                
                lines.removeFirst()
                return lines.compactMap { Int($0) }
            }
        
        guard decks.count == 2 else {
            throw InputError(message: "Invalid input")
        }
        
        return GameState(decks: Decks(deck1: decks[0], deck2: decks[1]))
    }
}
