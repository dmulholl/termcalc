

class Parser {

    let tokens: [Token]
    var current = 0

    init(_ tokens: [Token]) {
        self.tokens = tokens
    }

    func parse() throws -> Expr {
        let expr = try expression()
        if !isAtEnd() {
            let token = next()
            throw Err.parseError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "unexpected input"
            )
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
        let expr = try addition()
        if match(.equal) {
            let optoken = next()
            let rightexpr = try assignment()
            if let leftexpr = expr as? VariableExpr {
                return AssignExpr(leftexpr.name, optoken, rightexpr)
            } else {
                throw Err.parseError(
                    offset: optoken.offset,
                    lexeme: optoken.lexeme,
                    message: "can only assign to a variable"
                )
            }
        }
        return expr
    }

    private func addition() throws -> Expr {
        var expr = try multiplication()
        while match(.plus, .minus) {
            let optoken = next()
            let rightexpr = try multiplication()
            expr = BinaryExpr(expr, optoken, rightexpr)
        }
        return expr
    }

    private func multiplication() throws -> Expr {
        var expr = try unary()
        while match(.star, .slash) {
            let optoken = next()
            let rightexpr = try unary()
            expr = BinaryExpr(expr, optoken, rightexpr)
        }
        return expr
    }

    private func unary() throws -> Expr {
        if match(.plus, .minus) {
            let optoken = next()
            let rightexpr = try unary()
            return UnaryExpr(optoken, rightexpr)
        }
        return try call()
    }

    private func call() throws -> Expr {
        let expr = try primary()
        // TODO: implement call expressions.
        return expr
    }

    private func primary() throws -> Expr {
        if match(.integer, .float) {
            let token = next()
            if let value = Double(token.lexeme) {
                return LiteralExpr(value)
            } else {
                throw Err.parseError(
                    offset: token.offset,
                    lexeme: token.lexeme,
                    message: "cannot parse as number"
                )
            }
        } else if match(.leftparen) {
            let _ = next()
            let expr = try expression()
            try consume(.rightparen, "expect ')'")
            return GroupingExpr(expr)
        } else if match(.identifier) {
            return VariableExpr(next())
        }
        let token = next()
        throw Err.parseError(
            offset: token.offset,
            lexeme: token.lexeme,
            message: "expect expression"
        )
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

    private func next() -> Token {
        if tokens[current].type == .eof {
            return tokens[current]
        } else {
            current += 1
            return tokens[current - 1]
        }
    }

    private func consume(_ type: TokenType, _ message: String) throws {
        if match(type) {
            _ = next()
        } else {
            let token = next()
            throw Err.parseError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: message
            )
        }
    }
}
