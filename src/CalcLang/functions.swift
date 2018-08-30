// -----------------------------------------------------------------------------
// Builtin functions.
// -----------------------------------------------------------------------------

import Foundation


protocol Function {
    func call(token: Token, args: [Double]) throws -> Double
}


// -----------------------------------------------------------------------------
// Trig functions.
// -----------------------------------------------------------------------------


// Convert an input value in radians to degrees.
class Deg: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        return args[0] * 180 / Double.pi
    }
}


// Convert an input value in degrees to radians.
class Rad: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        return args[0] * Double.pi / 180
    }
}


// Calculate the sine of an angle specified in radians.
class Sin: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        return sin(args[0])
    }
}


// Calculate the cosine of an angle specified in radians.
class Cos: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        return cos(args[0])
    }
}


// Calculate the tangent of an angle specified in radians.
class Tan: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        return tan(args[0])
    }
}

// Calculate the sine of an angle specified in degrees.
class Sind: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        let radians = args[0] * Double.pi / 180
        return sin(radians)
    }
}


// Calculate the cosine of an angle specified in degreed.
class Cosd: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        let radians = args[0] * Double.pi / 180
        return cos(radians)
    }
}


// Calculate the tangent of an angle specified in radians.
class Tand: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        let radians = args[0] * Double.pi / 180
        return tan(radians)
    }
}


// -----------------------------------------------------------------------------
// Inverse trig functions.
// -----------------------------------------------------------------------------


// Calculate inverse cosine of the specified value; result in radians.
class Acos: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        return acos(args[0])
    }
}


// Calculate inverse sine of the specified value; result in radians.
class Asin: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        return asin(args[0])
    }
}


// Calculate inverse tangent of the specified value; result in radians.
class Atan: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        if args.count == 1 {
            return atan(args[0])
        } else if args.count == 2 {
            let x = args[0]
            let y = args[1]
            return atan2(y, x)
        } else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 or 2 arguments, found \(args.count)"
            )
        }
    }
}


// Calculate inverse cosine of the specified value; result in degrees.
class Acosd: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        let radians = acos(args[0])
        return radians * 180 / Double.pi
    }
}



// Calculate inverse sine of the specified value; result in degrees.
class Asind: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        let radians = asin(args[0])
        return radians * 180 / Double.pi
    }
}


// Calculate inverse tangent of the specified value; result in degrees.
class Atand: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        if args.count == 1 {
            let radians = atan(args[0])
            return radians * 180 / Double.pi
        } else if args.count == 2 {
            let x = args[0]
            let y = args[1]
            let radians = atan2(y, x)
            return radians * 180 / Double.pi
        } else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 or 2 arguments, found \(args.count)"
            )
        }
    }
}


// -----------------------------------------------------------------------------
// Roots.
// -----------------------------------------------------------------------------


// Calculate the square root of the specified value.
class Sqrt: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        guard args[0] >= 0 else {
            throw CalcLangError.mathError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "sqrt() requires a positive argument"
            )
        }
        return sqrt(args[0])
    }
}


// Calculate the cube root of the specified value.
class Cbrt: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        return cbrt(args[0])
    }
}


// -----------------------------------------------------------------------------
// Logs.
// -----------------------------------------------------------------------------


// Calculate the natural log of the specified value.
class Ln: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        return log(args[0])
    }
}


// Calculate the base-2 log of the specified value.
class Log2: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        return log2(args[0])
    }
}


// Calculate the base-10 log of the specified value.
class Log10: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        return log10(args[0])
    }
}


// Calculate the base-n log of the specified value.
class Log: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 2 else {
            throw CalcLangError.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 2 arguments, found \(args.count)"
            )
        }

        let base = args[0]
        let operand = args[1]

        guard base > 0 else {
            throw CalcLangError.mathError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "log() requires a positive base"
            )
        }

        return log(operand) / log(base)
    }
}
