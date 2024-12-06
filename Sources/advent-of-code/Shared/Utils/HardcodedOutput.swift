struct HardcodedOutput: CustomStringConvertible {
    var output: any CustomStringConvertible
    
    init(_ output: any CustomStringConvertible) {
        self.output = output
    }
    
    var description: String {
        return "\(output.description) (hardcoded)"
    }
}
