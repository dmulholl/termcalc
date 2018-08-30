// -----------------------------------------------------------------------------
// The interpreter accepts a string containing a single expression, evaluates
// the expression, and returns the stringified result.
// -----------------------------------------------------------------------------

import Foundation


public class Interpreter {

    var precision = 9
    var variables = [String:Double]()

    let constants = [
        "pi": Double.pi,
        "e": M_E,
    ]

    let functions: [String:Function] = [
        "acos": Acos(),
        "acosd": Acosd(),
        "asin": Asin(),
        "asind": Asind(),
        "atan": Atan(),
        "atand": Atand(),
        "cbrt": Cbrt(),
        "cos": Cos(),
        "cosd": Cosd(),
        "deg": Deg(),
        "ln": Ln(),
        "log": Log(),
        "log2": Log2(),
        "log10": Log10(),
        "rad": Rad(),
        "root": Root(),
        "sin": Sin(),
        "sind": Sind(),
        "sqrt": Sqrt(),
        "tan": Tan(),
        "tand": Tand(),
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
        return expr is AssignExpr ? "" : stringify(value)
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
        let lvalue = try eval(expr.leftexpr)
        let rvalue = try eval(expr.rightexpr)
        switch expr.optoken.type {
        case .plus:
            return lvalue + rvalue
        case .minus:
            return lvalue - rvalue
        case .star:
            return lvalue * rvalue
        case .slash:
            if rvalue == 0 {
                throw CalcLangError.divByZero(
                    offset: expr.optoken.offset,
                    lexeme: expr.optoken.lexeme
                )
            }
            return lvalue / rvalue
        case .modulo:
            if rvalue == 0 {
                throw CalcLangError.divByZero(
                    offset: expr.optoken.offset,
                    lexeme: expr.optoken.lexeme
                )
            }
            return lvalue.truncatingRemainder(dividingBy: rvalue)
        case .caret:
            return pow(lvalue, rvalue)
        default:
            print("evalBinary: unreachable")
            exit(1)
        }
    }

    private func evalVariable(_ expr: VariableExpr) throws -> Double {
        if let value = variables[expr.name.lexeme] {
            return value
        }
        else if let value = constants[expr.name.lexeme] {
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

        return try callee.call(token: expr.callee.name, args: arguments)
    }
}
