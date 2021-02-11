import Foundation


public class Interpreter {
    public var milliSeparator = ""
    public var kiloSeparator = ""
    public var decimalSeparator = "."
    public var precision = 9
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

    public init() {}

    public func interpret(source: String) throws -> String {
        let scanner = Scanner(source)
        let tokens = try scanner.scan()
        let parser = Parser(tokens)
        let expr = try parser.parse()
        let value = try expr.eval(self)
        count += 1
        variables["$\(count)"] = value
        variables["$"] = value
        return stringify(value)
    }

    private func stringify(_ value: Double) -> String {
        var formatted = String(format: "%.\(precision)f", value)
        if formatted.contains(".") {
            while formatted.hasSuffix("0") {
                formatted.removeLast()
            }
            if formatted.hasSuffix(".") {
                formatted.removeLast()
            }
        }

        if formatted == "-0" {
            return "0"
        }

        let parts = formatted.components(separatedBy: ".")
        let integralPart = parts[0]
        let decimalPart = parts.count > 1 ? parts[1] : ""

        var newIntegralPart = ""
        for i in 0 ..< integralPart.count {
            newIntegralPart = integralPart[integralPart.count - i - 1] + newIntegralPart
            if i % 3 == 2 && i < integralPart.count - 1 {
                newIntegralPart = self.kiloSeparator + newIntegralPart
            }
        }

        var newDecimalPart = ""
        for i in 0 ..< decimalPart.count {
            newDecimalPart += decimalPart[i]
            if i % 3 == 2 && i < decimalPart.count - 1 {
                newDecimalPart += self.milliSeparator
            }
        }

        if newDecimalPart.isEmpty {
            return newIntegralPart
        } else {
            return "\(newIntegralPart)\(self.decimalSeparator)\(newDecimalPart)"
        }
    }
}

