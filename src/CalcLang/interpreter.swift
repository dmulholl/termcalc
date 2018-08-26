
import Foundation

public class Interpreter {

    var precision = 9

    public init() {}

    let constants = [
        "pi": 3.14,
    ]

    public func interpret(source: String) throws -> String {
        let scanner = Scanner(source)
        let tokens = try scanner.scan()
        let parser = Parser(tokens)
        let expr = try parser.parse()
        let value = try eval(expr)
        return stringify(value)
    }

    func stringify(_ value: Double) -> String {
        var str = String(format: "%.\(precision)f", value)
        while str.count > 1 && (str.hasSuffix("0") || str.hasSuffix(".")) {
            _ = str.removeLast()
        }
        return str
    }

    func eval(_ expr: Expr) throws -> Double {
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

    // TODO: add overflow checking.
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
                throw Err.divByZero(offset: expr.optoken.offset)
            }
            return lvalue / rvalue
        default:
            print("evalBinary: unreachable")
            exit(1)
        }
    }

    private func evalVariable(_ expr: VariableExpr) throws -> Double {
        return 99
    }


}
