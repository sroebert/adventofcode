struct InputError: Error {
    var message: String
    
    static let invalid = InputError(message: "Invalid input")
}
