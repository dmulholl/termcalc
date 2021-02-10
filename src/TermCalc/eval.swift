// -----------------------------------------------------------------------------
// Non-interactive pipeline mode.
// -----------------------------------------------------------------------------

import Foundation
import TermUtils
import CalcLang


// func eval(argparser: ArgParser, source: String) {
//     let trimmed = source.trimmingCharacters(in: .whitespaces)
//     if trimmed.isEmpty {
//         return
//     }

//     let interpreter = Interpreter(precision: argparser.getInt("precision"))

//     do {
//         let output = try interpreter.interpret(source: trimmed)
//         print(output)
//     } catch {
//         Terminal.writeErr("TermCalc Error: \(error).\n")
//         exit(1)
//     }
// }
