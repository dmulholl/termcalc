
import Foundation


protocol Function {
    func call(token: Token, args: [Double]) throws -> Double
}


// Convert a value in radians to degrees.
class Deg: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw Err.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        return args[0] * 180 / Double.pi
    }
}


// Convert a value in degrees to radians.
class Rad: Function {
    func call(token: Token, args: [Double]) throws -> Double {
        guard args.count == 1 else {
            throw Err.arityError(
                offset: token.offset,
                lexeme: token.lexeme,
                message: "expected 1 argument, found \(args.count)"
            )
        }
        return args[0] * Double.pi / 180
    }
}
