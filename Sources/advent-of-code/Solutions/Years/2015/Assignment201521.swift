struct Assignment201521: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let boss = try await getBoss()
        
        var leastGold = Int.max
        enumeratePossiblePlayers { player, calculateCost in
            if player.defeats(boss) {
                let gold = calculateCost()
                if gold < leastGold {
                    leastGold = gold
                }
            }
        }
        
        return leastGold
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let boss = try await getBoss()
        
        var mostGold = 0
        enumeratePossiblePlayers { player, calculateCost in
            if !player.defeats(boss) {
                let gold = calculateCost()
                if gold > mostGold {
                    mostGold = gold
                }
            }
        }
        
        return mostGold
    }
    
    // MARK: - Utils
    
    private enum Weapon: CaseIterable {
        case dagger
        case shortsword
        case warhammer
        case longsword
        case greataxe
        
        var cost: Int {
            switch self {
            case .dagger: 8
            case .shortsword: 10
            case .warhammer: 25
            case .longsword: 40
            case .greataxe: 74
            }
        }
        
        var damage: Int {
            switch self {
            case .dagger: 4
            case .shortsword: 5
            case .warhammer: 6
            case .longsword: 7
            case .greataxe: 8
            }
        }
    }
    
    private enum Armor: CaseIterable {
        case none
        case leather
        case chainmail
        case splintmail
        case bandedmail
        case platemail
        
        var cost: Int {
            switch self {
            case .none: 0
            case .leather: 13
            case .chainmail: 31
            case .splintmail: 53
            case .bandedmail: 75
            case .platemail: 102
            }
        }
        
        var armor: Int {
            switch self {
            case .none: 0
            case .leather: 1
            case .chainmail: 2
            case .splintmail: 3
            case .bandedmail: 4
            case .platemail: 5
            }
        }
    }
    
    private enum Ring: CaseIterable {
        case damage1
        case damage2
        case damage3
        case armor1
        case armor2
        case armor3
        
        var cost: Int {
            switch self {
            case .damage1: 25
            case .damage2: 50
            case .damage3: 100
            case .armor1: 20
            case .armor2: 40
            case .armor3: 80
            }
        }
        
        var damage: Int {
            switch self {
            case .damage1: 1
            case .damage2: 2
            case .damage3: 3
            case .armor1: 0
            case .armor2: 0
            case .armor3: 0
            }
        }
        
        var armor: Int {
            switch self {
            case .damage1: 0
            case .damage2: 0
            case .damage3: 0
            case .armor1: 1
            case .armor2: 2
            case .armor3: 3
            }
        }
    }
    
    private struct Person {
        var hitPoints: Int
        var damage: Int
        var armor: Int
        
        func defeats(_ other: Person) -> Bool {
            let damageDealt = max(1, damage - other.armor)
            let damageReceived = max(1, other.damage - armor)
            
            let turnsToDefeat = (other.hitPoints / damageDealt) + (other.hitPoints % damageDealt > 0 ? 1 : 0)
            let turnsToLose = (hitPoints / damageReceived) + (hitPoints % damageReceived > 0 ? 1 : 0)
            return turnsToDefeat <= turnsToLose
        }
    }
    
    private func enumeratePossiblePlayers(_ action: (_ player: Person, _ cost: () -> Int) -> Void) {
        let weaponOptions = Weapon.allCases
        let armorOptions = Armor.allCases
        let ringOptions = Ring.allCases.combinations(ofCount: ...2)
        
        for weapon in weaponOptions {
            for armor in armorOptions {
                for rings in ringOptions {
                    let player = Person(
                        hitPoints: 100,
                        damage: weapon.damage + rings.reduce(0) { $0 + $1.damage },
                        armor: armor.armor + rings.reduce(0) { $0 + $1.armor }
                    )
                    
                    action(player) {
                        weapon.cost + armor.cost + rings.reduce(0) { $0 + $1.cost }
                    }
                }
            }
        }
    }
    
    private func getBoss() async throws -> Person {
        let numbers = try await compactMapInput { line in
            line.split(separator: ": ").last.flatMap { Int($0) }
        }
        
        guard numbers.count == 3 else {
            throw InputError(message: "Invalid input")
        }
        
        return Person(hitPoints: numbers[0], damage: numbers[1], armor: numbers[2])
    }
}
