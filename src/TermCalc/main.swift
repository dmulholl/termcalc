// -----------------------------------------------------------------------------
// TermCalc - a command line calculator.
// -----------------------------------------------------------------------------

import Foundation
import Janus
import CalcLang
import TermUtils
import LineNoise

let version = "0.2.0"


let binary = (CommandLine.arguments[0] as NSString).lastPathComponent


let helptext = """
Usage: \(binary) [OPTIONS] [FLAGS]

  TermCalc is a command line calculator. All operations are performed using
  IEEE 754-2008 64-bit double-precision floats.

Options:
  -p, --precision <int>     Decimal precision of output (default: 9).

Flags:
  -h, --help                Print the application's help text and exit.
  -v, --version             Print the application's version number and exit.

Functions:
  acos(x)                   Inverse cosine of x; result in radians.
  acosd(x)                  Inverse cosine of x; result in degrees.
  asin(x)                   Inverse sine of x; result in radians.
  asind(x)                  Inverse sine of x; result in degrees.
  atan(x)                   Inverse tangent of x; result in radians.
  atan(x,y)                 Inverse tangent of y/x; result in radians, sign
                            determined by the quadrant of (x,y).
  atand(x)                  Inverse tangent of x; result in degrees.
  atand(x,y)                Inverse tangent of y/x; result in degrees, sign
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
  root(n,x)                 Calculate the n-th root of x.
  sin(x)                    Sine of x; x in radians.
  sind(x)                   Sine of x; x in degrees.
  sqrt(x)                   Square root of x.
  tan(x)                    Tangent of x; x in radians.
  tand(x)                   Tangent of x; x in degrees.
"""


let argparser = ArgParser(helptext: helptext, version: version)
argparser.newInt("precision p", fallback: 9)
argparser.parse()


guard let term = Terminal() else {
    Terminal.writeErr("Error: TermCalc requires an interactive terminal.\n")
    exit(1)
}


guard Terminal.isTerminalStdin() else {
    Terminal.writeErr("Error: TermCalc requires an interactive terminal.\n")
    exit(1)
}

term.writeln("─", color: .grey, times: term.width() ?? 80)
term.write(" · ", color: .grey)
term.write("Terminal Calculator")
term.write(" · ", color: .grey)
term.write(" ", times: 26)
term.writeln("Type 'q' or 'quit' to exit.", color: .grey)
term.writeln("─", color: .grey, times: term.width() ?? 80)


let interpreter = Interpreter(precision: argparser.getInt("precision"))


while true {
    do {
        let input = try term.getLineNoise(prompt: ">> ", color: .grey)
        print()
        if input.trimmingCharacters(in: .whitespaces).isEmpty {
            continue
        }
        if input == "q" || input == "quit" {
            term.writeln("─", color: .grey, times: term.width() ?? 80)
            break
        }
        let output = try interpreter.interpret(source: input)
        if !output.isEmpty{
            term.write("=> ", color: .grey)
            print("\(output)")
        }
    } catch CalcLangError.invalidCharacter(let offset, let char) {
        term.write("!> ", color: .grey)
        term.write(" ", times: offset)
        term.writeln("^", color: .red)
        term.write("!> ", color: .grey)
        term.writeln("Error: invalid character '\(char)' in input.")
    } catch CalcLangError.unexpectedToken(let offset, let lexeme) {
        term.write("!> ", color: .grey)
        term.write(" ", times: offset)
        term.writeln("^", color: .red, times: lexeme.count)
        term.write("!> ", color: .grey)
        term.writeln("Error: unexpected input '\(lexeme)'.")
    } catch CalcLangError.illegalAssignment(let offset, let lexeme) {
        term.write("!> ", color: .grey)
        term.write(" ", times: offset)
        term.writeln("^", color: .red, times: lexeme.count)
        term.write("!> ", color: .grey)
        term.writeln("Error: only variables can be assigned values.")
    } catch CalcLangError.unparsableLiteral(let offset, let lexeme) {
        term.write("!> ", color: .grey)
        term.write(" ", times: offset)
        term.writeln("^", color: .red, times: lexeme.count)
        term.write("!> ", color: .grey)
        term.writeln("Error: cannot parse '\(lexeme)' as a number.")
    } catch CalcLangError.expectExpression(let offset, let lexeme) {
        term.write("!> ", color: .grey)
        term.write(" ", times: offset)
        if lexeme.isEmpty {
            term.writeln("^", color: .red)
            term.write("!> ", color: .grey)
            term.writeln("Error: expected an expression.")
        } else {
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("!> ", color: .grey)
            term.writeln("Error: expected an expression, found '\(lexeme)'.")
        }
    } catch CalcLangError.expectToken(let offset, let lexeme, let expected) {
        term.write("!> ", color: .grey)
        term.write(" ", times: offset)
        if lexeme.isEmpty {
            term.writeln("^", color: .red)
            term.write("!> ", color: .grey)
            term.writeln("Error: expected '\(expected)'.")
        } else {
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("!> ", color: .grey)
            term.writeln("Error: expected '\(expected)', found '\(lexeme)'.")
        }
    } catch CalcLangError.divByZero(let offset, let lexeme) {
        term.write("!> ", color: .grey)
        term.write(" ", times: offset)
        term.writeln("^", color: .red, times: lexeme.count)
        term.write("!> ", color: .grey)
        term.writeln("Error: cannot divide by zero.")
    } catch CalcLangError.undefinedVariable(let offset, let lexeme) {
        term.write("!> ", color: .grey)
        term.write(" ", times: offset)
        term.writeln("^", color: .red, times: lexeme.count)
        term.write("!> ", color: .grey)
        term.writeln("Error: undefined variable '\(lexeme)'.")
    } catch CalcLangError.undefinedFunction(let offset, let lexeme) {
        term.write("!> ", color: .grey)
        term.write(" ", times: offset)
        term.writeln("^", color: .red, times: lexeme.count)
        term.write("!> ", color: .grey)
        term.writeln("Error: undefined function '\(lexeme)'.")
    } catch CalcLangError.arityError(let offset, let lexeme, let message) {
        term.write("!> ", color: .grey)
        term.write(" ", times: offset)
        term.writeln("^", color: .red, times: lexeme.count)
        term.write("!> ", color: .grey)
        term.writeln("Error: \(message).")
    } catch CalcLangError.mathError(let offset, let lexeme, let message) {
        term.write("!> ", color: .grey)
        term.write(" ", times: offset)
        term.writeln("^", color: .red, times: lexeme.count)
        term.write("!> ", color: .grey)
        term.writeln("Error: \(message).")
    } catch LinenoiseError.EOF {
        print()
        continue
    } catch LinenoiseError.CTRL_C {
        print()
        continue
    } catch {
        term.write("!> ", color: .grey)
        print(error)
    }
}
