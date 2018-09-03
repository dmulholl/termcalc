

import TermUtils
import Foundation


guard let term = Terminal() else {
    exit(1)
}

let output = try term.getLine(prompt: "> ", color: .red)
print()
print("output: \(output)")
