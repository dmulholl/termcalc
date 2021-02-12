import Foundation


class LineEditor {
    var originalTermios = termios()
    var lineBuffer = ""
    var cursorOffset = 0
    var prompt = ""
    var promptLength = 0
    var history: History

    var cursorIndex: String.Index {
        return lineBuffer.index(lineBuffer.startIndex, offsetBy: cursorOffset)
    }

    init(prompt: String, color: Terminal.Color? = nil, history: History) {
        if color == nil {
            self.prompt = prompt
        } else {
            let reset = Terminal.Color.standard
            self.prompt = "\(color!.string)\(prompt)\(reset.string)"
        }
        self.promptLength = prompt.count
        self.history = history
    }

    func getLine() throws -> String {
        let inRawMode = enterRawMode()
        defer {
            if inRawMode {
                _ = exitRawMode()
            }
        }

        lineBuffer = ""
        cursorOffset = 0
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

            // Printable ascii characters.
            else if byte < 127 {
                let char = Character(UnicodeScalar(byte))
                insert(char: char)
            }

            // Backspace key.
            else if byte == 127 {
                try handleControlChar(byte)
            }

            // The byte must be the first of a multibyte utf8 character.
            else {
                let string = readMultiByteUtf8(firstByte: byte)
                insert(string: string)
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

    private func insert(char: Character) {
        lineBuffer.insert(char, at: cursorIndex)
        cursorOffset += 1
    }

    private func insert(string: String) {
        let count = lineBuffer.count
        lineBuffer.insert(contentsOf: string, at: cursorIndex)
        let delta = lineBuffer.count - count
        cursorOffset += delta
    }

    private func handleControlChar(_ byte: UInt8) throws {
        switch byte {

        // Ctrl-A: move the cursor to the beginning of the line.
        case 1:
            cursorOffset = 0

        // Ctrl-B: move back.
        case 2:
            if cursorOffset > 0 {
                cursorOffset -= 1
            }

        // Ctrl-C:
        case 3:
            throw TermUtilsError.ctrl_c

        // Ctrl-D: if there is a character to the right, delete it; otherwise
        // signal EOF, but only if the buffer is empty.
        case 4:
            if cursorOffset < lineBuffer.count {
                lineBuffer.remove(at: cursorIndex)
            } else if lineBuffer.isEmpty {
                throw TermUtilsError.eof
            }

        // Ctrl-E: move the cursor to the end of the line.
        case 5:
            cursorOffset = lineBuffer.count

        // Ctrl-F: move forward.
        case 6:
            if cursorOffset < lineBuffer.count {
                cursorOffset += 1
            }

        // Ctrl-H (8 = ascii backspace) or keyboard backspace (127 = ascii
        // delete): if there is a character to the left, delete it.
        case 8, 127:
            if cursorOffset > 0 {
                let location = lineBuffer.index(before: cursorIndex)
                lineBuffer.remove(at: location)
                cursorOffset -= 1
            }

        // Ctrl-K: delete all to the right.
        case 11:
            if cursorOffset < lineBuffer.count {
                lineBuffer.removeLast(lineBuffer.count - cursorOffset)
            }

        // Ctrl-L: clear screen and move the cursor to the home position.
        case 12:
            print("\u{001B}[2J\u{001B}[H", terminator: "")
            fflush(stdout)

        // Ctrl-U: delete all to the left.
        case 21:
            if cursorOffset > 0 {
                lineBuffer.removeFirst(cursorOffset)
                cursorOffset = 0
            }

        // Ctrl-W: delete previous word.
        case 23:
            var index = cursorIndex

            // Work backwards to find the first non-space character.
            while index > lineBuffer.startIndex {
                if lineBuffer[lineBuffer.index(before: index)] == " " {
                    index = lineBuffer.index(before: index)
                } else {
                    break
                }
            }

            // Work backwards to find the first space character.
            while index > lineBuffer.startIndex {
                if lineBuffer[lineBuffer.index(before: index)] != " " {
                    index = lineBuffer.index(before: index)
                } else {
                    break
                }
            }

            let distance = lineBuffer.distance(from: index, to: cursorIndex)
            if distance > 0 {
                lineBuffer.removeSubrange(index ..< cursorIndex)
                cursorOffset -= distance
            }

        // Escape.
        case 27:
            guard let next1 = readByte() else { break }
            guard let next2 = readByte() else { break }
            guard next1 == 91 else { break }

            switch next2 {

            // Up cursor key.
            case 65:
                historyPrevious()

            // Down cursor key.
            case 66:
                historyNext()

            // Right cursor key.
            case 67:
                if cursorOffset < lineBuffer.count {
                    cursorOffset += 1
                }

            // Left cursor key.
            case 68:
                if cursorOffset > 0 {
                    cursorOffset -= 1
                }

            default:
                break
            }

        // Ctrl-N: next history.
        case 14:
            historyNext()

        // Ctrl-P: previous history.
        case 16:
            historyPrevious()

        default:
            break
        }
    }

    private func refresh() {
        var output = "\r"
        output += prompt
        output += lineBuffer
        output += "\u{001B}[0K" // erase right
        output += "\r"
        output += "\u{001B}[\(promptLength + cursorOffset)C" // move cursor
        print(output, terminator: "")
        fflush(stdout)
    }

    private func readMultiByteUtf8(firstByte: UInt8) -> String {
        var buf = [firstByte]

        // Check for a two-byte utf8 character.
        if firstByte & 0b1110_0000 == 0b1100_0000 {
            if let b2 = readByte() {
                buf.append(b2)
                return String(data: Data(buf), encoding: .utf8) ?? "?"
            }
        }

        // Check for a three-byte utf8 character.
        else if firstByte & 0b1111_0000 == 0b1110_0000 {
            if let b2 = readByte(), let b3 = readByte() {
                buf.append(b2)
                buf.append(b3)
                return String(data: Data(buf), encoding: .utf8) ?? "?"
            }
        }

        // Check for a four-byte utf8 character.
        else if firstByte & 0b1111_1000 == 0b1111_0000 {
            if let b2 = readByte(), let b3 = readByte(), let b4 = readByte() {
                buf.append(b2)
                buf.append(b3)
                buf.append(b4)
                return String(data: Data(buf), encoding: .utf8) ?? "?"
            }
        }

        // Not a valid utf8 encoding.
        return "?"
    }

    private func historyNext() {
        if let item = history.next() {
            lineBuffer = item
            if cursorOffset > item.count {
                cursorOffset = item.count
            }
        }
    }

    private func historyPrevious() {
        if let item = history.previous(current: lineBuffer) {
            lineBuffer = item
            if cursorOffset > item.count {
                cursorOffset = item.count
            }
        }
    }
}
