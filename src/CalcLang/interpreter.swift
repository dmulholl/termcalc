// -----------------------------------------------------------------------------
// The interpreter accepts a string containing a single expression, evaluates
// the expression, and returns the stringified result.
// -----------------------------------------------------------------------------

import Foundation


public class Interpreter {

    var precision = 9
    var count = 0

    var variables = [
        "pi": Double.pi,
        "e": M_E,
    ]

    let functions: [String:Function] = [

        // Angle conversions.
        "deg": Deg(),
        "rad": Rad(),

        // Trig.
        "cos": Cos(),
        "sin": Sin(),
        "tan": Tan(),

        "cosd": Cosd(),
        "sind": Sind(),
        "tand": Tand(),

        "cosr": Cos(),
        "sinr": Sin(),
        "tanr": Tan(),

        // Inverse Trig Shortform.
        "acos": Acos(),
        "asin": Asin(),
        "atan": Atan(),

        "acosd": Acosd(),
        "asind": Asind(),
        "atand": Atand(),

        "acosr": Acos(),
        "asinr": Asin(),
        "atanr": Atan(),

        // Inverse Trig Longform.
        "arccos": Acos(),
        "arcsin": Asin(),
        "arctan": Atan(),

        "arccosd": Acosd(),
        "arcsind": Asind(),
        "arctand": Atand(),

        "arccosr": Acos(),
        "arcsinr": Asin(),
        "arctanr": Atan(),

        // Roots.
        "cbrt": Cbrt(),
        "root": Root(),
        "sqrt": Sqrt(),

        // Logs.
        "ln": Ln(),
        "log": Log(),
        "log2": Log2(),
        "log10": Log10(),
    ]

    public init(precision: Int = 9) {
        self.precision = precision
    }

    public func interpret(source: String) throws -> String {
        let scanner = Scanner(source)
        let tokens = try scanner.scan()
        let parser = Parser(tokens)
        let expr = try parser.parse()
        let value = try eval(expr)
        count += 1
        variables["$\(count)"] = value
        variables["$"] = value
        return stringify(value)
    }

    private func stringify(_ value: Double) -> String {
        var string = String(format: "%.\(precision)f", value)
        if string.contains(".") {
            while string.hasSuffix("0") {
                _ = string.removeLast()
            }
            if string.hasSuffix(".") {
                _ = string.removeLast()
            }
        }
        return string == "-0" ? "0" : string
    }

    private func eval(_ expr: Expr) throws -> Double {
        if let literal = expr as? LiteralExpr {
            return literal.value
        } else if let grouping = expr as? GroupingExpr {
            return try eval(grouping.expr)
        } else if let binary = expr as? BinaryExpr {
            return try evalBinary(binary)
        } else if let unary = expr as? UnaryExpr {
            return try evalUnary(unary)
        } else if let variable = expr as? VariableExpr {
            return try evalVariable(variable)
        } else if let assignment = expr as? AssignExpr {
            return try evalAssign(assignment)
        } else if let call = expr as? CallExpr {
            return try evalCall(call)
        } else if let factorial = expr as? FactorialExpr {
            return try evalFactorial(factorial)
        }
        print("eval: unreachable")
        exit(1)
    }

    private func evalUnary(_ expr: UnaryExpr) throws -> Double {
        let value = try eval(expr.rightexpr)
        switch expr.optoken.type {
        case .plus:
            return value
        case .minus:
            return -value
        default:
            print("evalUnary: unreachable")
            exit(1)
        }
    }

    private func evalBinary(_ expr: BinaryExpr) throws -> Double {
        let result: Double
        let lvalue = try eval(expr.leftexpr)
        let rvalue = try eval(expr.rightexpr)
        switch expr.optoken.type {
        case .plus:
            result = lvalue + rvalue
        case .minus:
            result = lvalue - rvalue
        case .star:
            result = lvalue * rvalue
        case .slash:
            if rvalue == 0 {
                throw CalcLangError.divByZero(
                    offset: expr.optoken.offset,
                    lexeme: expr.optoken.lexeme
                )
            }
            result = lvalue / rvalue
        case .modulo:
            if rvalue == 0 {
                throw CalcLangError.divByZero(
                    offset: expr.optoken.offset,
                    lexeme: expr.optoken.lexeme
                )
            }
            result = lvalue.truncatingRemainder(dividingBy: rvalue)
        case .caret:
            result = pow(lvalue, rvalue)
        default:
            print("evalBinary: unreachable")
            exit(1)
        }
        if result.isInfinite {
            throw CalcLangError.mathError(
                offset: expr.optoken.offset,
                lexeme: expr.optoken.lexeme,
                message: "operation results in overflow"
            )
        } else if result.isNaN {
            throw CalcLangError.mathError(
                offset: expr.optoken.offset,
                lexeme: expr.optoken.lexeme,
                message: "result is not a number (NaN)"
            )
        }
        return result
    }

    private func evalVariable(_ expr: VariableExpr) throws -> Double {
        if let value = variables[expr.name.lexeme] {
            return value
        }
        throw CalcLangError.undefinedVariable(
            offset: expr.name.offset,
            lexeme: expr.name.lexeme
        )
    }

    private func evalAssign(_ expr: AssignExpr) throws -> Double {
        let rvalue = try eval(expr.value)

        if expr.optoken.type == .equal {
            variables[expr.name.lexeme] = rvalue
            return rvalue
        }

        guard let lvalue = variables[expr.name.lexeme] else {
            throw CalcLangError.undefinedVariable(
                offset: expr.name.offset,
                lexeme: expr.name.lexeme
            )
        }

        switch expr.optoken.type {
        case .plusequal:
            variables[expr.name.lexeme] = lvalue + rvalue
        case .minusequal:
            variables[expr.name.lexeme] = lvalue - rvalue
        case .starequal:
            variables[expr.name.lexeme] = lvalue * rvalue
        case .slashequal:
            if rvalue == 0 {
                throw CalcLangError.divByZero(
                    offset: expr.optoken.offset,
                    lexeme: expr.optoken.lexeme
                )
            }
            variables[expr.name.lexeme] = lvalue / rvalue
        case .moduloequal:
            if rvalue == 0 {
                throw CalcLangError.divByZero(
                    offset: expr.optoken.offset,
                    lexeme: expr.optoken.lexeme
                )
            }
            variables[expr.name.lexeme] = lvalue.truncatingRemainder(
                dividingBy: rvalue
            )
        case .caretequal:
            variables[expr.name.lexeme] = pow(lvalue, rvalue)
        default:
            print("evalAssign: unreachable")
            exit(1)
        }

        return variables[expr.name.lexeme]!
    }

    private func evalCall(_ expr: CallExpr) throws -> Double {
        guard let callee = functions[expr.callee.name.lexeme] else {
            throw CalcLangError.undefinedFunction(
                offset: expr.callee.name.offset,
                lexeme: expr.callee.name.lexeme
            )
        }

        var arguments = [Double]()
        for argument in expr.arguments {
            arguments.append(try eval(argument))
        }

        let result = try callee.call(token: expr.callee.name, args: arguments)

        if result.isInfinite {
            throw CalcLangError.mathError(
                offset: expr.callee.name.offset,
                lexeme: expr.callee.name.lexeme,
                message: "function call results in overflow"
            )
        } else if result.isNaN {
            throw CalcLangError.mathError(
                offset: expr.callee.name.offset,
                lexeme: expr.callee.name.lexeme,
                message: "result is not a number (NaN)"
            )
        }
        return result
    }

    private func evalFactorial(_ expr: FactorialExpr) throws -> Double {
        var n = try eval(expr.leftexpr)
        if n == 0 {
            return 1
        }

        guard n > 0 && n.truncatingRemainder(dividingBy: 1) == 0 else {
            throw CalcLangError.mathError(
                offset: expr.optoken.offset,
                lexeme: expr.optoken.lexeme,
                message: "factorials are defined for positive integers only"
            )
        }

        var result: Double = 1
        while n > 0 {
            result *= n
            n -= 1
            if result.isInfinite {
                throw CalcLangError.mathError(
                    offset: expr.optoken.offset,
                    lexeme: expr.optoken.lexeme,
                    message: "factorial results in overflow"
                )
            }
        }
        return result
    }
}
