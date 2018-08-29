// -----------------------------------------------------------------------------
// A sample application demonstrating Janus in action.
// -----------------------------------------------------------------------------

import Foundation
import Janus
import CalcLang
import LineNoise
import TermUtils


let version = "0.1.0"


let binary = (CommandLine.arguments[0] as NSString).lastPathComponent


let helptext = """
Usage: \(binary) [FLAGS]

  TermCalc is a command line calculator. All operations are performed using
  IEEE 754-2008 64-bit double-precision floats.

Flags:
  -h, --help        Print the application's help text and exit.
  -v, --version     Print the application's version number and exit.

Functions:
  acos(x)           Calculate the inverse cosine of x; result in radians.
  acosd(x)          Calculate the inverse cosine of x; result in degrees.
  asin(x)           Calculate the inverse sine of x; result in radians.
  asind(x)          Calculate the inverse sine of x; result in degrees.
  atan(x)           Calculate the inverse tangent of x; result in radians.
  atan(x,y)         Calculate the inverse tangent of y/x; result in radians,
                    sign determined by the quadrant of (x,y).
  atand(x)          Calculate the inverse tangent of x; result in degrees.
  atand(x,y)        Calculate the inverse tangent of y/x; result in degrees,
                    sign determined by the quadrant of (x,y).
  cbrt(x)           Calculate the cube root of x.
  cos(x)            Calculate the cosine of x; x in radians.
  cosd(x)           Calculate the cosine of x; x in degrees.
  deg(x)            Convert x in radians to degrees.
  ln(x)             Calculate the natural log of x.
  log(b,x)          Calculate the base-b log of x.
  log2(x)           Calculate the base-2 log of x.
  log10(x)          Calculate the base-10 log of x.
  rad(x)            Convert x in degrees to radians.
  sin(x)            Calculate the sine of x; x in radians.
  sind(x)           Calculate the sine of x; x in degrees.
  sqrt(x)           Calculate the square root of x.
  tan(x)            Calculate the tangent of x; x in radians.
  tand(x)           Calculate the tangent of x; x in degrees.
"""


let argparser = ArgParser(helptext: helptext, version: version)
argparser.parse()


guard let term = Terminal() else {
    Terminal.writeErr("Error: TermCalc requires an interactive terminal.\n")
    exit(1)
}

term.writeln("─", color: .grey, times: term.width() ?? 80)
term.writeln(" · TermCalc ·")
term.writeln("─", color: .grey, times: term.width() ?? 80)


let interpreter = Interpreter()
let ln = LineNoise()

let prompt = "\u{001B}[30;1m>> \u{001B}[0m" // 11 extra characters

while true {
    do {
        let input = try ln.getLine(prompt: prompt)
        print()
        if input == "q" || input == "quit" {
            break
        }
        let output = try interpreter.interpret(source: input)
        if !output.isEmpty{
            term.write("=> ", color: .grey)
            print("\(output)")
        }
    } catch {
        term.write("!> ", color: .grey)
        print(error)
    }
}
