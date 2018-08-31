// -----------------------------------------------------------------------------
// Interactive REPL mode.
// -----------------------------------------------------------------------------

import Foundation
import TermUtils
import Janus
import CalcLang


func repl(argparser: ArgParser) {
    guard let term = Terminal() else {
        let text = "interactive mode requires that stdout be a terminal"
        Terminal.writeErr("Error: \(text).\n")
        exit(1)
    }

    term.writeln("─", color: .brightBlack, times: term.width() ?? 80)
    term.write("  ││  ", color: .brightBlack)
    //term.write("      Terminal Calculator")
    term.write("Terminal Calculator")
    term.write("  ││", color: .brightBlack)

    term.write(" ", times: 18)
    term.writeln("Type 'q' or 'quit' to exit.", color: .brightBlack)
    term.writeln("─", color: .brightBlack, times: term.width() ?? 80)

    let interpreter = Interpreter(precision: argparser.getInt("precision"))

    while true {
        do {
            let input = try term.getLineNoise(
                prompt: "  >>  ",
                color: .brightBlack
            )
            print()
            if input.trimmingCharacters(in: .whitespaces).isEmpty {
                continue
            }
            if input == "q" || input == "quit" {
                term.writeln("─",
                    color: .brightBlack,
                    times: term.width() ?? 80
                )
                break
            }
            let output = try interpreter.interpret(source: input)
            if !output.isEmpty{
                term.write("  =>  ", color: .brightBlack)
                print("\(output)")
            }
        } catch CalcLangError.invalidCharacter(let offset, let char) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: invalid character '\(char)' in input.")
        } catch CalcLangError.unexpectedToken(let offset, let lexeme) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: unexpected input '\(lexeme)'.")
        } catch CalcLangError.illegalAssignment(let offset, let lexeme) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: only variables can be assigned values.")
        } catch CalcLangError.unparsableLiteral(let offset, let lexeme) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: cannot parse '\(lexeme)' as a number.")
        } catch CalcLangError.expectExpression(let offset, let lexeme) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            if lexeme.isEmpty {
                term.writeln("^", color: .red)
                term.write("  !>  ", color: .brightBlack)
                term.writeln("Error: expected an expression.")
            } else {
                term.writeln("^", color: .red, times: lexeme.count)
                term.write("  !>  ", color: .brightBlack)
                term.writeln("Error: expected an expression, found '\(lexeme)'.")
            }
        } catch CalcLangError.expectToken(let offset, let lexeme, let expect) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            if lexeme.isEmpty {
                term.writeln("^", color: .red)
                term.write("  !>  ", color: .brightBlack)
                term.writeln("Error: expected '\(expect)'.")
            } else {
                term.writeln("^", color: .red, times: lexeme.count)
                term.write("  !>  ", color: .brightBlack)
                term.writeln("Error: expected '\(expect)', found '\(lexeme)'.")
            }
        } catch CalcLangError.divByZero(let offset, let lexeme) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: cannot divide by zero.")
        } catch CalcLangError.undefinedVariable(let offset, let lexeme) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: undefined variable '\(lexeme)'.")
        } catch CalcLangError.undefinedFunction(let offset, let lexeme) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: undefined function '\(lexeme)'.")
        } catch CalcLangError.arityError(let offset, let lexeme, let message) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: \(message).")
        } catch CalcLangError.mathError(let offset, let lexeme, let message) {
            term.write("  !>  ", color: .brightBlack)
            term.write(" ", times: offset)
            term.writeln("^", color: .red, times: lexeme.count)
            term.write("  !>  ", color: .brightBlack)
            term.writeln("Error: \(message).")
        } catch TermUtilsError.eof {
            print()
            continue
        } catch TermUtilsError.ctrl_c {
            print()
            term.writeln("─", color: .brightBlack, times: term.width() ?? 80)
            break
        } catch TermUtilsError.linenoise(let message){
            term.write("  !>  ", color: .brightBlack)
            print("Error: \(message)")
        } catch {
            term.write("  !>  ", color: .brightBlack)
            print("Error: \(error)")
        }
    }
}
