enum TokenType {
    case left_paren, right_paren, comma, bang
    case plus, minus, star, slash, mod, caret, equal
    case plus_equal, minus_equal, star_equal, slash_equal, mod_equal, caret_equal
    case identifier, integer, float, dot_float
    case eof
}


struct Token {
    let type: TokenType
    let lexeme: String
    let offset: Int
}


extension Token: Equatable {
    static func ==(lhs: Token, rhs: Token) -> Bool {
        return
            lhs.type == rhs.type &&
            lhs.lexeme == rhs.lexeme &&
            lhs.offset == rhs.offset
    }
}


let keywords: [String:TokenType] = [:]
