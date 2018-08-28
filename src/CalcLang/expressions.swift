// -----------------------------------------------------------------------------
// Expressions are produced by the parser and consumed by the interpreter.
// -----------------------------------------------------------------------------


class Expr {}


class BinaryExpr: Expr {
    let leftexpr: Expr
    let optoken: Token
    let rightexpr: Expr

    init(_ leftexpr: Expr, _ optoken: Token, _ rightexpr: Expr) {
        self.leftexpr = leftexpr
        self.optoken = optoken
        self.rightexpr = rightexpr
    }
}


class UnaryExpr: Expr {
    let optoken: Token
    let rightexpr: Expr

    init(_ optoken: Token, _ rightexpr: Expr) {
        self.optoken = optoken
        self.rightexpr = rightexpr
    }
}


class GroupingExpr: Expr {
    let expr: Expr

    init(_ expr: Expr) {
        self.expr = expr
    }
}


class LiteralExpr: Expr {
    let value: Double

    init(_ value: Double) {
        self.value = value
    }
}


class VariableExpr: Expr {
    let name: Token

    init(_ name: Token) {
        self.name = name
    }
}


class AssignExpr: Expr {
    let name: Token
    let optoken: Token
    let value: Expr

    init(_ name: Token, _ optoken: Token, _ value: Expr) {
        self.name = name
        self.optoken = optoken
        self.value = value
    }
}


class CallExpr: Expr {
    let callee: VariableExpr
    let arguments: [Expr]

    init(_ callee: VariableExpr, _ arguments: [Expr]) {
        self.callee = callee
        self.arguments = arguments
    }
}
