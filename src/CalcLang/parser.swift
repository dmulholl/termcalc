class Parser {
    let tokens: [Token]
    var current = 0

    init(_ tokens: [Token]) {
        self.tokens = tokens
    }

    func parse() throws -> Expr {
        let expr = try expression()
        if !isAtEnd() {
            let token = nextToken()
            throw CalcLangError.syntaxError(token.offset, token.lexeme, "Unexpected input.")
        }
        return expr
    }

    // ---------------------------------------------------------------------
    // Expression parsers.
    // ---------------------------------------------------------------------

    private func expression() throws -> Expr {
        return try assignment()
    }

    private func assignment() throws -> Expr {
        let expr = try additive()
        if match(.equal, .plus_equal, .minus_equal, .star_equal, .slash_equal, .mod_equal, .caret_equal) {
            let opToken = nextToken()
            var rightExpr = try assignment()
            if let leftexpr = expr as? VariableExpr {
                if opToken.type != .equal {
                    rightExpr = BinaryExpr(leftexpr, opToken, rightExpr)
                }
                return AssignExpr(leftexpr.name, opToken, rightExpr)
            } else {
                throw CalcLangError.syntaxError(
                    opToken.offset,
                    opToken.lexeme,
                    "Invalid assignment target."
                )
            }
        }
        return expr
    }

    private func additive() throws -> Expr {
        var expr = try multiplicative()
        while match(.plus, .minus) {
            let opToken = nextToken()
            let rightExpr = try multiplicative()
            expr = BinaryExpr(expr, opToken, rightExpr)
        }
        return expr
    }

    private func multiplicative() throws -> Expr {
        var expr = try exponential()
        while match(.star, .slash, .mod) {
            let opToken = nextToken()
            let rightExpr = try exponential()
            expr = BinaryExpr(expr, opToken, rightExpr)
        }
        return expr
    }

    private func exponential() throws -> Expr {
        var expr = try unary()
        while match(.caret) {
            let opToken = nextToken()
            let rightExpr = try unary()
            expr = BinaryExpr(expr, opToken, rightExpr)
        }
        return expr
    }

    private func unary() throws -> Expr {
        if match(.plus, .minus) {
            let opToken = nextToken()
            let expr = try factorial()
            return UnaryExpr(opToken, expr)
        }
        return try factorial()
    }

    private func factorial() throws -> Expr {
        var expr = try call()
        while match(.bang) {
            let opToken = nextToken()
            expr = FactorialExpr(expr, opToken)
        }
        return expr
    }

    private func call() throws -> Expr {
        let expr = try primary()
        if let variable = expr as? VariableExpr {
            if match(.left_paren) {
                nextToken()
                var arguments = [Expr]()
                if !match(.right_paren) {
                    while true {
                        arguments.append(try expression())
                        if match(.comma) {
                            nextToken()
                        } else {
                            break
                        }
                    }
                }
                try consume(.right_paren, "Expected ')'.")
                return CallExpr(variable, arguments)
            }
        }
        return expr
    }

    private func primary() throws -> Expr {
        if match(.float) {
            let token = nextToken()
            if let value = Double(token.lexeme) {
                return LiteralExpr(value)
            }
            let msg = "Cannot parse '\(token.lexeme)' as a number."
            throw CalcLangError.syntaxError(token.offset, token.lexeme, msg)
        }
        else if match(.dot_float) {
            let token = nextToken()
            if let value = Double("0" + token.lexeme) {
                return LiteralExpr(value)
            }
            let msg = "Cannot parse '\(token.lexeme)' as a number."
            throw CalcLangError.syntaxError(token.offset, token.lexeme, msg)
        } else if match(.integer) {
            let token = nextToken()
            if token.lexeme.starts(with: "0b") {
                let literal = String(token.lexeme.dropFirst(2))
                if let value = Int64(literal, radix: 2) {
                    return LiteralExpr(Double(value))
                }
            } else if token.lexeme.starts(with: "0o") {
                let literal = String(token.lexeme.dropFirst(2))
                if let value = Int64(literal, radix: 8) {
                    return LiteralExpr(Double(value))
                }
            } else if token.lexeme.starts(with: "0d") {
                let literal = String(token.lexeme.dropFirst(2))
                if let value = Int64(literal, radix: 10) {
                    return LiteralExpr(Double(value))
                }
            } else if token.lexeme.starts(with: "0x") {
                let literal = String(token.lexeme.dropFirst(2))
                if let value = Int64(literal, radix: 16) {
                    return LiteralExpr(Double(value))
                }
            } else {
                if let value = Int64(token.lexeme) {
                    return LiteralExpr(Double(value))
                }
            }
            let msg = "Cannot parse '\(token.lexeme)' as a number."
            throw CalcLangError.syntaxError(token.offset, token.lexeme, msg)
        } else if match(.left_paren) {
            nextToken()
            let expr = try expression()
            try consume(.right_paren, "Expected ')'.")
            return GroupingExpr(expr)
        } else if match(.identifier) {
            return VariableExpr(nextToken())
        }
        let token = nextToken()
        throw CalcLangError.syntaxError(token.offset, token.lexeme, "Expected an expression.")
    }

    // ---------------------------------------------------------------------
    // Helpers.
    // ---------------------------------------------------------------------

    private func match(_ types: TokenType...) -> Bool {
        if isAtEnd() {
            return false
        }
        for type in types {
            if peek().type == type {
                return true
            }
        }
        return false
    }

    private func isAtEnd() -> Bool {
        return tokens[current].type == .eof
    }

    private func peek() -> Token {
        return tokens[current]
    }

    @discardableResult private func nextToken() -> Token {
        if tokens[current].type == .eof {
            return tokens[current]
        } else {
            current += 1
            return tokens[current - 1]
        }
    }

    private func consume(_ type: TokenType, _ message: String) throws {
        if match(type) {
            nextToken()
        } else {
            let token = nextToken()
            throw CalcLangError.syntaxError(token.offset, token.lexeme, message)
        }
    }
}
