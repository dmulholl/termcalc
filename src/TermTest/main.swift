

import TermUtils
import Foundation


guard let term = Terminal() else {
    exit(1)
}


term.writeln("foobar", color: .red)
term.writeln("foobar", color: .brightRed)
