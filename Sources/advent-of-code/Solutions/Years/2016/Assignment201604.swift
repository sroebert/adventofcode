import RegexBuilder

struct Assignment201604: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let rooms = try await getRooms()
        return rooms.lazy.filter(\.isReal).reduce(0) {
            $0 + $1.name.sectorId
        }
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let rooms = try await getRooms()
        for room in rooms {
            guard room.isReal else {
                continue
            }
            
            if room.name.decryptedName == "northpole object storage" {
                return room.name.sectorId
            }
        }
        
        throw InputError(message: "Invalid input")
    }
    
    // MARK: - Utils
    
    private struct Room {
        var name: RoomName
        var checksum: [Character]
        
        var isReal: Bool {
            for i in 0..<5 {
                guard checksum[i] == name.letters[i].character else {
                    return false
                }
            }
            return true
        }
    }
    
    private struct RoomName {
        var encryptedName: String
        var letters: [Letter]
        var sectorId: Int
        
        struct Letter {
            var character: Character
            var count: Int
        }
        
        var decryptedName: String {
            encryptedName.map { character in
                guard character != "-" else {
                    return " "
                }
                
                let a: Character = "a"
                let number = character.asciiValue! - a.asciiValue!
                let decryptedNumber = UInt8((Int(number) + sectorId) % 26) + a.asciiValue!
                return String(UnicodeScalar(decryptedNumber))
            }.joined()
        }
    }
    
    private func getRooms() async throws -> [Room] {
        let letters = Reference((String, [RoomName.Letter]).self)
        let sectorId = Reference(Int.self)
        let checksum = Reference([Character].self)
        
        let regex = Regex {
            TryCapture(as: letters) {
                OneOrMore {
                    OneOrMore {
                        ("a"..."z")
                    }
                    "-"
                }
            } transform: {
                var letters: [Character: Int] = [:]
                $0.split(separator: "-").forEach { part in
                    part.forEach { letter in
                        letters[letter, default: 0] += 1
                    }
                }
                
                let sortedLetters = letters.map {
                    RoomName.Letter(
                        character: $0,
                        count: $1
                    )
                }.sorted { a, b in
                    guard a.count != b.count else {
                        return a.character < b.character
                    }
                    return a.count > b.count
                }
                return (String($0.dropLast()), sortedLetters)
            }
            TryCapture(as: sectorId) {
                OneOrMore(.digit)
            } transform: {
                Int($0)
            }
            "["
            TryCapture(as: checksum) {
                OneOrMore(("a"..."z"))
            } transform: {
                Array($0)
            }
            "]"
        }
        
        return try await mapInput { line in
            guard let match = line.wholeMatch(of: regex) else {
                throw InputError(message: "Invalid input")
            }
            
            let (encryptedName, letters) = match[letters]
            return Room(
                name: RoomName(
                    encryptedName: encryptedName,
                    letters: letters,
                    sectorId: match[sectorId]
                ),
                checksum: match[checksum]
            )
        }
    }
}
