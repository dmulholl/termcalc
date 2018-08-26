

enum Err: Error {
    case scanError(offset: Int, char: Character)
    case parseError(offset: Int, lexeme: String, message: String)
    case divByZero(offset: Int)
    case undefinedVariable(offset: Int, lexeme: String)
}
