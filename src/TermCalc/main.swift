// -----------------------------------------------------------------------------
// A sample application demonstrating Janus in action.
// -----------------------------------------------------------------------------

import Janus
import CalcLang

let interpreter = Interpreter()

while true {
    print("> ", terminator: "")
    if let input = readLine() {
        do {
            let output = try interpreter.interpret(source: input)
            print(output)
        } catch {
            print(error)
        }
    } else {
        break
    }
}
