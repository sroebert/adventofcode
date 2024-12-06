struct Assignment202004: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        let passports = try await getPassports()
        return passports.count { $0.isValidPart1 }
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        let passports = try await getPassports()
        return passports.count { $0.isValidPart2 }
    }
    
    // MARK: - Utils
    
    private struct Passport {
        var fields: [PassportField: String]
        
        var isValidPart1: Bool {
            return !PassportField.requiredFields.contains { fields[$0] == nil }
        }
        
        var isValidPart2: Bool {
            return !PassportField.requiredFields.contains { requiredField in
                guard let value = fields[requiredField] else {
                    return true
                }
                return !requiredField.isValueValid(value)
            }
        }
    }
    
    private enum PassportField: String, Hashable {
        case birthYear = "byr"
        case issueYear = "iyr"
        case expirationYear = "eyr"
        case height = "hgt"
        case hairColor = "hcl"
        case eyeColor = "ecl"
        case passportId = "pid"
        case countryId = "cid"
        
        static let requiredFields: [PassportField] = [
            .birthYear,
            .issueYear,
            .expirationYear,
            .height,
            .hairColor,
            .eyeColor,
            .passportId
        ]
        
        private func isValue(_ value: String, matchingPattern regex: String) -> Bool {
            return value.range(of: "^\(regex)$", options: .regularExpression, range: nil, locale: nil) != nil
        }
        
        private func isValue(_ value: String, numberBetween min: Int, and max: Int) -> Bool {
            guard let number = Int(value) else {
                return false
            }
            return number >= min && number <= max
        }
        
        func isValueValid(_ value: String) -> Bool {
            switch self {
            case .birthYear:
                return isValue(value, numberBetween: 1920, and: 2002)
            case .issueYear:
                return isValue(value, numberBetween: 2010, and: 2020)
            case .expirationYear:
                return isValue(value, numberBetween: 2020, and: 2030)
            case .height:
                if value.hasSuffix("cm") {
                    return isValue(String(value.dropLast(2)), numberBetween: 150, and: 193)
                } else if value.hasSuffix("in") {
                    return isValue(String(value.dropLast(2)), numberBetween: 59, and: 76)
                } else {
                    return false
                }
            case .hairColor:
                return isValue(value, matchingPattern: "#[0-9a-f]{6}")
            case .eyeColor:
                return isValue(value, matchingPattern: "(amb|blu|brn|gry|grn|hzl|oth)")
            case .passportId:
                return isValue(value, matchingPattern: "[0-9]{9}")
            case .countryId:
                return true
            }
        }
    }
    
    private func getPassports() async throws -> [Passport] {
        return try await getInput()
            .split(separator: "\n\n")
            .map { passportString in
                var passport = Passport(fields: [:])
                
                passportString.split { $0 == " " || $0 == "\n" }.forEach { fieldString in
                    let parts = fieldString.split(separator: ":")
                    guard
                        parts.count == 2,
                        let field = PassportField(rawValue: String(parts[0]))
                    else {
                        return
                    }
                    
                    passport.fields[field] = String(parts[1])
                }
                
                return passport
            }
    }
}
