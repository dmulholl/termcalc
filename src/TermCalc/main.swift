// -----------------------------------------------------------------------------
// TermCalc - a command line calculator.
// -----------------------------------------------------------------------------

import Foundation
import Janus
import CalcLang
import TermUtils


let version = "1.1.1"
let binary = (CommandLine.arguments[0] as NSString).lastPathComponent


let helptext = """
Usage: \(binary) [OPTIONS] [FLAGS]

  TermCalc is a command line calculator. All operations are performed using
  IEEE 754 64-bit floats.

  If stdin is connected to a terminal, TermCalc will run in interactive mode.
  If stdin is connected to a pipe or file, TermCalc will read in a single
  line of input, evaluate it, and print the output to stdout.

Options:
  -e, --eval <str>          Evaluate an expression and print the result.
  -p, --precision <int>     Set decimal precision of output (default: 9).

Flags:
  -h, --help                Print this help text and exit.
  -v, --version             Print the application's version number and exit.

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


let argparser = ArgParser(helptext: helptext, version: version)
argparser.newInt("precision p", fallback: 9)
argparser.newString("eval e")
argparser.parse()


if argparser.found("eval") {
    eval(argparser: argparser, source: argparser.getString("eval"))
} else if Terminal.isTermStdin() && Terminal.isTermStdout(){
    repl(argparser: argparser)
} else if let input = readLine() {
    eval(argparser: argparser, source: input)
}
