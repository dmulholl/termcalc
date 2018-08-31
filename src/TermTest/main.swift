

import TermUtils
import Foundation


guard let term = Terminal() else {
    exit(1)
}


term.setColor(.red, .bgYellow)
term.writeln("hello world!")
