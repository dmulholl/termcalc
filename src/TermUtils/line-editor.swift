
import Foundation


class LineEditor {

    var originalTermios = termios()
    var lineBuffer = ""
    var cursorPosition = 0
    var prompt = ""
    var promptCount = 0

    var cursorIndex: String.Index {
        return lineBuffer.index(lineBuffer.startIndex, offsetBy: cursorPosition)
    }

    init(prompt: String, color: Terminal.Color? = nil) {
        if color == nil {
            self.prompt = prompt
        } else {
            let reset = Terminal.Color.standard
            self.prompt = "\(color!.string)\(prompt)\(reset.string)"
        }
        self.promptCount = prompt.count
    }

    private func insert(char: Character) {
        lineBuffer.insert(char, at: cursorIndex)
        cursorPosition += 1
    }

    private func readMultibyteChar(_ firstByte: UInt8) -> Character {
        var buffer = [UInt8]()
        buffer.append(firstByte)
        return Character("?")
    }

    private func handleControlChar(_ byte: UInt8) throws {
        switch byte {

        // Ctrl-A: move the cursor to the beginning of the line.
        case 1:
            cursorPosition = 0

        // Ctrl-B: move back.
        case 2:
            if cursorPosition > 0 {
                cursorPosition -= 1
            }

        // Ctrl-C:
        case 3:
            throw TermUtilsError.ctrl_c

        // Ctrl-D: if there is a character to the right, delete it; otherwise
        // signal EOF.
        case 4:
            if cursorPosition < lineBuffer.count {
                lineBuffer.remove(at: cursorIndex)
            } else {
                throw TermUtilsError.eof
            }

        // Ctrl-E: move the cursor to the end of the line.
        case 5:
            cursorPosition = lineBuffer.count

        // Ctrl-F: move forward.
        case 6:
            if cursorPosition < lineBuffer.count {
                cursorPosition += 1
            }

        // Ctrl-H (8) or backspace (127): if there is a character to the left,
        // delete it.
        case 8, 127:
            if cursorPosition > 0 {
                let location = lineBuffer.index(before: cursorIndex)
                lineBuffer.remove(at: location)
                cursorPosition -= 1
            }

        // Ctrl-K: delete all to the right.
        case 11:
            if cursorPosition < lineBuffer.count {
                lineBuffer.removeLast(lineBuffer.count - cursorPosition)
            }



        // Ctrl-P: previous history.
        // Ctrl-N: next history.
        // Ctrl-L: clear screen.
        // Ctrl-T: swap character with previous.
        // Ctrl-U: delete all to the left.
        // Ctrl-W: delete previous word.
        // Backspace. 127
        // Escape: 27.
        default:
            break
        }
    }

    private func refresh() {
        var output = "\r"
        output += prompt
        output += lineBuffer
        output += "\u{001B}[0K"
        output += "\r"
        output += "\u{001B}[\(promptCount + cursorPosition)C"
        print(output, terminator: "")
        fflush(stdout)
    }

    func getLine() throws -> String {
        let inRaw = enterRawMode()
        defer {
            if inRaw {
                _ = exitRawMode()
            }
        }

        lineBuffer = ""
        cursorPosition = 0
        refresh()

        while true {
            guard let byte = readByte() else {
                break
            }

            // Return key.
            if byte == 13 {
                break
            }

            // Control characters.
            else if byte < 32 {
                try handleControlChar(byte)
            }

            // Simple ascii characters.
            else if byte < 127 {
                let char = Character(UnicodeScalar(byte))
                insert(char: char)
            }

            // Backspace.
            else if byte == 127 {
                try handleControlChar(byte)
            }

            // The byte must be the first of a multibyte utf8 character.
            else {
                let char = readMultibyteChar(byte)
                insert(char: char)
            }

            refresh()
        }

        return lineBuffer
    }

    private func enterRawMode() -> Bool {
        if tcgetattr(fileno(stdin), &originalTermios) == -1 {
            return false
        }
        var termios = originalTermios

        #if os(Linux) || os(FreeBSD)
            termios.c_iflag &= ~UInt32(BRKINT | ICRNL | INPCK | ISTRIP | IXON)
            termios.c_oflag &= ~UInt32(OPOST)
            termios.c_cflag |=  UInt32(CS8)
            termios.c_lflag &= ~UInt32(ECHO | ICANON | IEXTEN | ISIG)
        #else
            termios.c_iflag &= ~UInt(BRKINT | ICRNL | INPCK | ISTRIP | IXON)
            termios.c_oflag &= ~UInt(OPOST)
            termios.c_cflag |=  UInt(CS8)
            termios.c_lflag &= ~UInt(ECHO | ICANON | IEXTEN | ISIG)
        #endif

        if tcsetattr(fileno(stdin), TCSAFLUSH, &termios) == -1 {
            return false
        }
        return true
    }

    private func exitRawMode() -> Bool {
        if tcsetattr(fileno(stdin), TCSAFLUSH, &originalTermios) == -1 {
            return false
        }
        return true
    }

    private func readByte() -> UInt8? {
        var byte: UInt8 = 0
        let count = read(fileno(stdin), &byte, 1)
        return count == 0 ? nil : byte
    }



}
