import Foundation


protocol Expr {
    func eval(_ interpreter: Interpreter) throws -> Double
}


class BinaryExpr: Expr {
    let leftExpr: Expr
    let opToken: Token
    let rightExpr: Expr

    init(_ leftExpr: Expr, _ opToken: Token, _ rightExpr: Expr) {
        self.leftExpr = leftExpr
        self.opToken = opToken
        self.rightExpr = rightExpr
    }

    func eval(_ interpreter: Interpreter) throws -> Double {
        let result: Double
        let lvalue = try self.leftExpr.eval(interpreter)
        let rvalue = try self.rightExpr.eval(interpreter)

        switch self.opToken.type {
            case .plus, .plus_equal:
                result = lvalue + rvalue
            case .minus, .minus_equal:
                result = lvalue - rvalue
            case .star, .star_equal:
                result = lvalue * rvalue
            case .slash, .slash_equal:
                if rvalue == 0 {
                    let msg = "Division by zero."
                    throw CalcLangError.runtimeError(opToken.offset, opToken.lexeme, msg)
                }
                result = lvalue / rvalue
            case .mod, .mod_equal:
                if rvalue == 0 {
                    let msg = "Division by zero."
                    throw CalcLangError.runtimeError(opToken.offset, opToken.lexeme, msg)
                }
                result = lvalue.truncatingRemainder(dividingBy: rvalue)
            case .caret, .caret_equal:
                result = pow(lvalue, rvalue)
            default:
                let msg = "Invalid (unreachable) binary operator."
                throw CalcLangError.runtimeError(opToken.offset, opToken.lexeme, msg)
        }

        if result.isInfinite {
            let msg = "Operation results in overflow."
            throw CalcLangError.runtimeError(opToken.offset, opToken.lexeme, msg)
        } else if result.isNaN {
            let msg = "Result is not a number (NaN)."
            throw CalcLangError.runtimeError(opToken.offset, opToken.lexeme, msg)
        }
        return result
    }
}


class UnaryExpr: Expr {
    let opToken: Token
    let expr: Expr

    init(_ opToken: Token, _ expr: Expr) {
        self.opToken = opToken
        self.expr = expr
    }

    func eval(_ interpreter: Interpreter) throws -> Double {
        let value = try self.expr.eval(interpreter)
        switch self.opToken.type {
        case .plus:
            return value
        default:
            return -value
        }
    }
}


class GroupingExpr: Expr {
    let expr: Expr

    init(_ expr: Expr) {
        self.expr = expr
    }

    func eval(_ interpreter: Interpreter) throws -> Double {
        return try self.expr.eval(interpreter)
    }
}


class LiteralExpr: Expr {
    let value: Double

    init(_ value: Double) {
        self.value = value
    }

    func eval(_ interpreter: Interpreter) -> Double {
        return self.value
    }
}


class VariableExpr: Expr {
    let name: Token

    init(_ name: Token) {
        self.name = name
    }

    func eval(_ interpreter: Interpreter) throws -> Double {
        if let value = interpreter.variables[self.name.lexeme] {
            return value
        }
        throw CalcLangError.runtimeError(name.offset, name.lexeme, "Undefined variable name.")
    }
}


class AssignExpr: Expr {
    let name: Token
    let opToken: Token
    let value: Expr

    init(_ name: Token, _ opToken: Token, _ value: Expr) {
        self.name = name
        self.opToken = opToken
        self.value = value
    }

    func eval(_ interpreter: Interpreter) throws -> Double {
        let value = try self.value.eval(interpreter)
        interpreter.variables[self.name.lexeme] = value
        return value
    }
}


class CallExpr: Expr {
    let callee: VariableExpr
    let arguments: [Expr]

    init(_ callee: VariableExpr, _ arguments: [Expr]) {
        self.callee = callee
        self.arguments = arguments
    }

    func eval(_ interpreter: Interpreter) throws -> Double {
        let token = self.callee.name
        guard let callee = interpreter.functions[token.lexeme] else {
            let msg = "Undefined function name."
            throw CalcLangError.runtimeError(self.callee.name.offset, self.callee.name.lexeme, msg)
        }

        var argValues = [Double]()
        for argExpr in self.arguments {
            argValues.append(try argExpr.eval(interpreter))
        }

        let result = try callee.call(token: token, args: argValues)
        if result.isInfinite {
            let msg = "Function call results in overflow."
            throw CalcLangError.runtimeError(self.callee.name.offset, self.callee.name.lexeme, msg)
        } else if result.isNaN {
            let msg = "Result is not a number (NaN)."
            throw CalcLangError.runtimeError(self.callee.name.offset, self.callee.name.lexeme, msg)
        }
        return result
    }
}


class FactorialExpr: Expr {
    let opToken: Token
    let expr: Expr

    init(_ expr: Expr, _ opToken: Token) {
        self.expr = expr
        self.opToken = opToken
    }

    func eval(_ interpreter: Interpreter) throws -> Double {
        var value = try self.expr.eval(interpreter)
        if value == 0 {
            return 1
        }

        guard value > 0 && value.truncatingRemainder(dividingBy: 1) == 0 else {
            let msg = "Factorials are only defined for non-negative integers."
            throw CalcLangError.runtimeError(opToken.offset, opToken.lexeme, msg)
        }

        var result: Double = 1
        while value > 0 {
            result *= value
            value -= 1
            if result.isInfinite {
                let msg = "Factorial results in overflow."
                throw CalcLangError.runtimeError(opToken.offset, opToken.lexeme, msg)
            }
        }
        return result
    }
}
