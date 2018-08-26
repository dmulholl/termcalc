
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
    let token: Token

    init(_ token: Token) {
        self.token = token
    }
}
