import Foundation
import CalcLang
import TermUtils
import ArgParser


let version = "2.0.0.dev"
let binary = (CommandLine.arguments[0] as NSString).lastPathComponent


let helptext = """
Usage: \(binary)

  TermCalc is an interactive command line calculator. All operations are
  performed using IEEE 754 64-bit floats.

Options:
  -d, --decimal <str>       Decimal separator (default '.').
  -k, --kilo <str>          Group separator for thousands (default: ',').
  -m, --milli <str>         Group separator for thousandths (default: ' ').
  -p, --precision <int>     Decimal precision of output (default: 9).

Flags:
  -h, --help                Print this help text and exit.
  -v, --version             Print the version number and exit.

Functions:
  arccos(x)                 Inverse cosine of x; result in radians.
  arccosd(x)                Inverse cosine of x; result in degrees.
  arcsin(x)                 Inverse sine of x; result in radians.
  arcsind(x)                Inverse sine of x; result in degrees.
  arctan(x)                 Inverse tangent of x; result in radians.
  arctan(x,y)               Inverse tangent of y/x; result in radians, sign
                            determined by the quadrant of (x,y).
  arctand(x)                Inverse tangent of x; result in degrees.
  arctand(x,y)              Inverse tangent of y/x; result in degrees, sign
                            determined by the quadrant of (x,y).
  cbrt(x)                   Cube root of x.
  cos(x)                    Cosine of x; x in radians.
  cosd(x)                   Cosine of x; x in degrees.
  deg(x)                    Convert x in radians to degrees.
  ln(x)                     Natural log of x.
  log(b,x)                  Base-b log of x.
  log2(x)                   Base-2 log of x.
  log10(x)                  Base-10 log of x.
  rad(x)                    Convert x in degrees to radians.
  root(n,x)                 Calculate the principal n-th root of x.
  sin(x)                    Sine of x; x in radians.
  sind(x)                   Sine of x; x in degrees.
  sqrt(x)                   Square root of x.
  tan(x)                    Tangent of x; x in radians.
  tand(x)                   Tangent of x; x in degrees.
"""


let argparser = ArgParser()
    .helptext(helptext)
    .version(version)
    .option("decimal d")
    .option("kilo k")
    .option("milli m")
    .option("precision p")

argparser.parse()

guard let precision = Int(argparser.value("precision") ?? "9") else {
    Terminal.writeError("Error: unparsable value for the '--precision' option.\n")
    exit(1);
}
guard precision >= 0 else {
    Terminal.writeError("Error: invalid value for the '--precision' option.\n")
    exit(1);
}

let interpreter = Interpreter()
interpreter.kiloSeparator = argparser.value("kilo") ?? ","
interpreter.milliSeparator = argparser.value("milli") ?? " "
interpreter.decimalSeparator = argparser.value("decimal") ?? "."
interpreter.precision = precision

var count = 0
let term = Terminal()
let cols = term.width() ?? 80

term.writeln("─", color: .brightBlack, times: cols)
term.write("  ··  ", color: .brightBlack)
term.write("Terminal Calculator")
term.write("  ··", color: .brightBlack)
term.write(" ", times: cols - 58)
term.writeln("Type 'q' or 'quit' to exit.", color: .brightBlack)
term.writeln("─", color: .brightBlack, times: cols)

while true {
    do {
        let input = try term.getLine(prompt: "  >>  ", color: .brightBlack)
        print()
        if input.trimmingCharacters(in: .whitespaces).isEmpty {
            continue
        }
        if input == "q" || input == "quit" {
            break
        }
        term.addHistoryItem(input)
        let output = try interpreter.interpret(source: input)
        if !output.isEmpty{
            count += 1
            let result = "\(output)"
            let resultID = "$\(count)"
            term.write("  =>  ", color: .brightBlack)
            term.write(result)
            let spaces = cols - 6 - result.count - resultID.count - 2
            term.write(" ", times: spaces <= 0 ? 1 : spaces)
            term.writeln(resultID, color: .brightBlack)
            term.writeln("")
        }
    } catch CalcLangError.syntaxError(let offset, let lexeme, let message) {
        term.write("  !>  ", color: .brightBlack)
        term.write(" ", times: offset)
        if lexeme.isEmpty {
            term.writeln("^", color: .red)
        } else {
            term.writeln("^", color: .red, times: lexeme.count)
        }
        term.write("  !>  ", color: .brightBlack)
        term.writeln("Error: \(message)\n")
    } catch CalcLangError.runtimeError(let offset, let lexeme, let message) {
        term.write("  !>  ", color: .brightBlack)
        term.write(" ", times: offset)
        term.writeln("^", color: .red, times: lexeme.count)
        term.write("  !>  ", color: .brightBlack)
        term.writeln("Error: \(message)\n")
    } catch TermUtilsError.eof {
        print()
        break
    } catch TermUtilsError.ctrl_c {
        print()
        break
    } catch {
        term.write("  !>  ", color: .brightBlack)
        print("Error: \(error)\n")
    }
}

term.writeln("─", color: .brightBlack, times: cols)

