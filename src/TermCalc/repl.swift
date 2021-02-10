import Foundation
import TermUtils
import CalcLang


func repl(precision: Int) {
    let term = Terminal()
    let cols = term.width() ?? 80

    term.writeln("─", color: .brightBlack, times: cols)
    term.write("  ··  ", color: .brightBlack)
    term.write("Terminal Calculator")
    term.write("  ··", color: .brightBlack)
    term.write(" ", times: cols - 58)
    term.writeln("Type 'q' or 'quit' to exit.", color: .brightBlack)
    term.writeln("─", color: .brightBlack, times: cols)

    let interpreter = Interpreter(precision: precision)
    var count = 0

    while true {
        do {
            let input = try term.getLine(prompt: "  >>  ", color: .brightBlack)
            print()
            if input.trimmingCharacters(in: .whitespaces).isEmpty {
                continue
            }
            if input == "q" || input == "quit" {
                term.writeln("─", color: .brightBlack, times: cols)
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
        } catch CalcLangError.invalidCharacter(let offset, let char) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: invalid character '\(char)' in input.\n")
        } catch CalcLangError.unexpectedToken(let offset, let lexeme) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: unexpected input '\(lexeme)'.\n")
        } catch CalcLangError.illegalAssignment(let offset, let lexeme) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: only variables can be assigned values.\n")
        } catch CalcLangError.unparsableLiteral(let offset, let lexeme) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: cannot parse '\(lexeme)' as a number.\n")
        } catch CalcLangError.expectExpression(let offset, let lexeme) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            if lexeme.isEmpty {
                term.writeln("^", color: .red)
                term.write("  !>  ", color: .brightBlack)
                term.writeln("Error: expected expression.\n")
            } else {
                term.writeln("^", color: .red, times: lexeme.count)
                term.write("  !>  ", color: .brightBlack)
                term.writeln("Error: expected expression, found '\(lexeme)'.\n")
            }
        } catch CalcLangError.expectToken(let offset, let lexeme, let expect) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            if lexeme.isEmpty {
                term.writeln("^", color: .red)
                term.write("  !>  ", color: .brightBlack)
                term.writeln("Error: expected '\(expect)'.\n")
            } else {
                term.writeln("^", color: .red, times: lexeme.count)
                term.write("  !>  ", color: .brightBlack)
                term.writeln("Error: expected '\(expect)', found '\(lexeme)'.\n")
            }
        } catch CalcLangError.divByZero(let offset, let lexeme) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: cannot divide by zero.\n")
        } catch CalcLangError.undefinedVariable(let offset, let lexeme) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: undefined variable '\(lexeme)'.\n")
        } catch CalcLangError.undefinedFunction(let offset, let lexeme) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: undefined function '\(lexeme)'.\n")
        } catch CalcLangError.arityError(let offset, let lexeme, let message) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: \(message).\n")
        } catch CalcLangError.mathError(let offset, let lexeme, let message) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: \(message).\n")
        } catch TermUtilsError.eof {
            print()
            term.writeln("─", color: .brightBlack, times: cols)
            break
        } catch TermUtilsError.ctrl_c {
            print()
            term.writeln("─", color: .brightBlack, times: cols)
            break
        } catch {
            term.write("  !>  ", color: .brightBlack)
            print("Error: \(error)\n")
        }
    }
}
