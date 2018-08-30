

import TermUtils
import Foundation


guard let term = Terminal() else {
    exit(1)
}


term.writeln("foobar", color: .brightBlack)

term.setColor(.reset)


term.writeln("foobar", color: .black)
term.writeln("foobar", color: .red)
term.writeln("foobar", color: .green)
term.writeln("foobar", color: .yellow)
term.writeln("foobar", color: .blue)
term.writeln("foobar", color: .magenta)
term.writeln("foobar", color: .cyan)
term.writeln("foobar", color: .white)
term.writeln("foobar", color: .brightYellow)
