
public func runlib() throws {
    let input = "1 + - 2 * -3"

    let interpreter = Interpreter()

    let value = try interpreter.interpret(source: input)

    print(value)
}
