
enum Err: Error, Equatable {

    // Scanner errors.
    case invalidCharacter(offset: Int, char: Character)

    // Parser errors.
    case unexpectedToken(offset: Int, lexeme: String)
    case illegalAssignment(offset: Int, lexeme: String)
    case unparsableLiteral(offset: Int, lexeme: String)
    case expectExpression(offset: Int, lexeme: String)
    case expectToken(offset: Int, lexeme: String, expected: String)

    // Interpreter errors.
    case divByZero(offset: Int, lexeme: String)
    case undefinedVariable(offset: Int, lexeme: String)
    case undefinedFunction(offset: Int, lexeme: String)
    case arityError(offset: Int, lexeme: String, message: String)
    case mathError(offset: Int, lexeme: String, message: String)

}
