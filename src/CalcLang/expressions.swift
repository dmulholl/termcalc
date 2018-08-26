
public class Expr {}


public class BinaryExpr: Expr {
    let leftexpr: Expr
    let optoken: Token
    let rightexpr: Expr

    init(_ leftexpr: Expr, _ optoken: Token, _ rightexpr: Expr) {
        self.leftexpr = leftexpr
        self.optoken = optoken
        self.rightexpr = rightexpr
    }
}


public class UnaryExpr: Expr {
    let optoken: Token
    let rightexpr: Expr

    init(_ optoken: Token, _ rightexpr: Expr) {
        self.optoken = optoken
        self.rightexpr = rightexpr
    }
}


public class GroupingExpr: Expr {
    let expr: Expr

    init(_ expr: Expr) {
        self.expr = expr
    }
}



public class LiteralExpr: Expr {
    let value: Double

    init(_ value: Double) {
        self.value = value
    }
}


public class VariableExpr: Expr {
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
