// -----------------------------------------------------------------------------
// A sample application demonstrating Janus in action.
// -----------------------------------------------------------------------------

import Janus
import CalcLang

let interpreter = Interpreter()

while true {
    print("> ", terminator: "")
    if let input = readLine() {
        if input == "q" || input == "quit" {
            break
        }
        do {
            let output = try interpreter.interpret(source: input)
            if !output.isEmpty{
                print("· \(output)")
            }
        } catch {
            print(error)
        }
    } else {
        break
    }
}
