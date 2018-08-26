
struct ExprPrinter {

    func stringify(_ expr: Expr) -> String {
        if let binary = expr as? BinaryExpr {
            return parenthesize(
                binary.optoken.lexeme,
                binary.leftexpr,
                binary.rightexpr
            )
        } else if let grouping = expr as? GroupingExpr {
            return stringify(grouping.expr)
        } else if let literal = expr as? LiteralExpr {
            return String(literal.value)
        } else if let unary = expr as? UnaryExpr {
            return parenthesize(unary.optoken.lexeme, unary.rightexpr)
        } else if let variable = expr as? VariableExpr {
            return variable.name.lexeme
        } else {
            return "UNSUPPORTED EXPRESSION TYPE"
        }
    }

    private func parenthesize(_ name: String, _ exprs: Expr...) -> String {
        var output = "(\(name)"
        for expr in exprs {
            output += " "
            output += stringify(expr)
        }
        output += ")"
        return output
    }
}
