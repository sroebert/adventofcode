import Foundation

struct Assignment202014: Assignment {
    
    // MARK: - Assignment
    
    func solvePart1() async throws -> AssignmentOutput {
        var memory: [Int: UInt64] = [:]
        try await processInput { mask, address, value in
            memory[Int(address)] = mask.maskValue(value)
        }
        return memory.reduce(0) { $0 + $1.value }
    }
    
    func solvePart2() async throws -> AssignmentOutput {
        var memory: [Int: UInt64] = [:]
        try await processInput { mask, address, value in
            mask.maskAddress(address) { maskedAddress in
                memory[Int(maskedAddress)] = value
            }
        }
        return memory.reduce(0) { $0 + $1.value }
    }
    
    var isSlowInDebug: Bool {
        return true
    }
    
    // MARK: - Utils
    
    private struct Mask {
        var zeroMask: UInt64
        var oneMask: UInt64
        
        var memoryMaskBits: [Int] = []
        
        func maskValue(_ value: UInt64) -> UInt64 {
            return ((value | oneMask) & zeroMask)
        }
        
        func maskAddress(_ address: UInt64, process: (UInt64) -> Void) {
            var memoryMask = UInt64.max
            for addressBit in memoryMaskBits {
                memoryMask &= ~(1 << addressBit)
            }
            
            let addressMask = (address | oneMask) & memoryMask
            
            let memoryMaskCount = Int(pow(2, Double(memoryMaskBits.count)))
            for index in 0..<memoryMaskCount {
                var floatingMemoryMask: UInt64 = 0
                for (indexBit, addressBit) in memoryMaskBits.enumerated() {
                    let indexMask = 1 << (memoryMaskBits.count - 1 - indexBit)
                    if (index & indexMask) == indexMask {
                        floatingMemoryMask |= 1 << addressBit
                    }
                }
                
                process(addressMask | floatingMemoryMask)
            }
        }
    }
    
    private func mask(from string: Substring) throws -> Mask {
        let zeroString = string
            .replacingOccurrences(of: "X", with: "1")
        let oneString = string
            .replacingOccurrences(of: "X", with: "0")
        
        guard
            let zeroMask = UInt64(zeroString, radix: 2),
            let oneMask = UInt64(oneString, radix: 2)
        else {
            throw InputError(message: "Invalid input")
        }
        
        let memoryMaskBits = string.enumerated().compactMap { entry -> Int? in
            guard entry.element == "X" else {
                return nil
            }
            return 35 - entry.offset
        }
        
        return Mask(
            zeroMask: zeroMask,
            oneMask: oneMask,
            memoryMaskBits: memoryMaskBits
        )
    }
    
    private func processInput(_ process: (_ mask: Mask, _ address: UInt64, _ value: UInt64) -> Void) async throws {
        var mask = Mask(zeroMask: UInt64.max, oneMask: 0)
        
        let maskRegex = /mask = (?<mask>[10X]{36})/
        let memoryRegex = /mem\[(?<address>\d+)] = (?<value>\d+)/
        
        try await getStreamedInput { line in
            if let match = line.wholeMatch(of: maskRegex) {
                mask = try self.mask(from: match.output.mask)
                return
            }
            
            if let match = line.wholeMatch(of: memoryRegex) {
                let address = UInt64(match.output.address) ?? 0
                let value = UInt64(match.output.value) ?? 0
                process(mask, address, value)
                return
            }
            
            throw InputError(message: "Invalid input")
        }
    }
}
