

import TermUtils
import Foundation


let term = Terminal()

let output = try term.getLine(prompt: "> ", color: .red)
print()
print("output: \(output)")
