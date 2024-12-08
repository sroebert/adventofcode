struct Assignment201522: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let boss = try await getBoss()
        let game = Game(boss: boss, difficulty: .normal)
        return findLeastSpendManaToWinGame(game: game)
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let boss = try await getBoss()
        let game = Game(boss: boss, difficulty: .hard)
        return findLeastSpendManaToWinGame(game: game)
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    var isSlowInRelease: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private struct Game {
        init(boss: Person, difficulty: GameDifficulty) {
            self.boss = boss
            self.difficulty = difficulty
        }
        
        private var difficulty: GameDifficulty
        
        private var playerHitPoints = 50 {
            didSet {
                if playerHitPoints <= 0 {
                    state = .lost
                }
            }
        }
        
        private var playerMana: Int = 500 {
            didSet {
                if playerMana < Spell.lowestCost {
                    state = .lost
                }
            }
        }
        
        private var boss: Person {
            didSet {
                if boss.hitPoints <= 0 {
                    state = .won
                }
            }
        }
        
        private(set) var state: GameState = .pending
        
        private var shieldEffectDuration = 0
        private var poisonEffectDuration = 0
        private var rechargeEffectDuration = 0
        
        func canCast(_ spell: Spell) -> Bool {
            return (
                playerMana >= spell.cost &&
                (shieldEffectDuration <= 1 || spell != .shield) &&
                (poisonEffectDuration <= 1 || spell != .poison) &&
                (rechargeEffectDuration <= 1 || spell != .recharge)
            )
        }
        
        private mutating func startTurn() {
            if shieldEffectDuration > 0 {
                shieldEffectDuration -= 1
            }
            
            if poisonEffectDuration > 0 {
                boss.hitPoints -= 3
                poisonEffectDuration -= 1
            }
            
            if rechargeEffectDuration > 0 {
                playerMana += 101
                rechargeEffectDuration -= 1
            }
        }
        
        mutating func performTurns(spell: Spell) {
            // Start player turn
            if case .hard = difficulty {
                playerHitPoints -= 1
                guard case .pending = state else {
                    return
                }
            }
            
            startTurn()
            guard case .pending = state else {
                return
            }
            
            // Cast spell
            playerMana -= spell.cost
            switch spell {
            case .magicMissile:
                boss.hitPoints -= 4
                
            case .drain:
                playerHitPoints += 2
                boss.hitPoints -= 2
                
            case .shield:
                shieldEffectDuration = 6
                
            case .poison:
                poisonEffectDuration = 6
                
            case .recharge:
                rechargeEffectDuration = 5
            }
            
            guard case .pending = state else {
                return
            }
            
            // Start boss turn
            startTurn()
            guard case .pending = state else {
                return
            }
            
            // Receive damage
            playerHitPoints -= max(1, boss.damage - (shieldEffectDuration > 0 ? 7 : 0))
        }
    }
    
    private enum GameDifficulty {
        case normal
        case hard
    }
    
    private enum GameState {
        case pending
        case won
        case lost
    }
    
    private enum Spell: CaseIterable {
        case magicMissile
        case drain
        case shield
        case poison
        case recharge
        
        static let lowestCost = {
            Spell.allCases.map(\.cost).min() ?? 0
        }()
        
        var cost: Int {
            switch self {
            case .magicMissile: return 53
            case .drain: return 73
            case .shield: return 113
            case .poison: return 173
            case .recharge: return 229
            }
        }
    }
    
    private struct Person {
        var hitPoints: Int
        var damage: Int
    }
    
    private func getBoss() async throws -> Person {
        var boss = Person(hitPoints: 0, damage: 0)
        
        let regex = /(?<stat>Hit Points|Damage): (?<value>\d+)/
        try await getStreamedInput { line in
            guard
                let match = line.wholeMatch(of: regex),
                let statValue = Int(match.output.value)
            else {
                throw InputError(message: "Invalid input")
            }
            
            switch match.output.stat {
            case "Hit Points":
                boss.hitPoints = statValue
            case "Damage":
                boss.damage = statValue
            default:
                throw InputError(message: "Invalid input")
            }
        }
        
        return boss
    }
    
    private func findLeastSpendManaToWinGame(game: Game) -> Int {
        var stack = [(spendMana: 0, game: game)]
        
        while !stack.isEmpty {
            let (spendMana, game) = stack.removeLast()
            
            guard game.state == .pending else {
                guard game.state == .won else {
                    continue
                }
                return spendMana
            }
            
            Spell.allCases.forEach { spell in
                guard game.canCast(spell) else {
                    return
                }
                
                var gameBranch = game
                gameBranch.performTurns(spell: spell)
                
                let newSpendMana = spendMana + spell.cost
                let insertionIndex = stack.binarySearch { $0.spendMana > newSpendMana }
                
                stack.insert((spendMana + spell.cost, gameBranch), at: insertionIndex)
            }
        }
        
        return Int.max
    }
}
