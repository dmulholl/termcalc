// -----------------------------------------------------------------------------
// The scanner accepts a source string and converts it into a sequence of
// tokens.
// -----------------------------------------------------------------------------

class Scanner {
    private let source: [Character]
    private var start = 0
    private var current = 0
    private var tokens = [Token]()

    init(_ source: String) {
        self.source = Array(source)
    }

    func scan() throws -> [Token] {
        while !isAtEnd() {
            start = current
            try readNextToken()
        }
        tokens.append(Token(type: .eof, lexeme: "", offset: current))
        return tokens
    }

    private func readNextToken() throws {
        let char = next()

        // Single-character tokens.
        if char == "(" {
            addToken(type: .leftparen)
        } else if char == ")" {
            addToken(type: .rightparen)
        } else if char == "," {
            addToken(type: .comma)
        } else if char == "=" {
            addToken(type: .equal)
        } else if char == "!" {
            addToken(type: .bang)
        }

        // Single or double-character tokens.
        else if char == "+" {
            if match("=") {
                addToken(type: .plusequal)
            } else {
                addToken(type: .plus)
            }
        } else if char == "-" {
            if match("=") {
                addToken(type: .minusequal)
            } else {
                addToken(type: .minus)
            }
        } else if char == "*" {
            if match("=") {
                addToken(type: .starequal)
            } else {
                addToken(type: .star)
            }
        } else if char == "/" {
            if match("=") {
                addToken(type: .slashequal)
            } else {
                addToken(type: .slash)
            }
        } else if char == "%" {
            if match("=") {
                addToken(type: .moduloequal)
            } else {
                addToken(type: .modulo)
            }
        } else if char == "^" {
            if match("=") {
                addToken(type: .caretequal)
            } else {
                addToken(type: .caret)
            }
        }

        // Whitespace.
        else if String(char).isWhitespace() {
            // We simply skip whitespace characters.
        }

        // Integer literals with a base specifier.
        else if char == "0" {
            if match("b") {
                readBinaryIntLiteral()
            } else if match("o") {
                readOctalIntLiteral()
            } else if match("d") {
                readDecimalIntLiteral()
            } else if match("x") {
                readHexIntLiteral()
            } else {
                readNumberLiteral()
            }
        }

        // Decimal integer or float.
        else if String(char).isDecimal() {
            readNumberLiteral()
        }

        // Identifiers & keywords.
        else if String(char).isAlpha() {
            readIdentifier()
        }

        // Reference.
        else if char == "$" {
            while !isAtEnd() && String(peek()!).isDecimal() {
                _ = next()
            }
            addToken(type: .identifier)
        }

        else {
            throw CalcLangError.invalidCharacter(
                offset: current - 1,
                char: char
            )
        }
    }

    private func isAtEnd() -> Bool {
        return current >= source.count
    }

    private func next() -> Character {
        current += 1
        return source[current - 1]
    }

    private func addToken(type: TokenType) {
        let begin = source.index(source.startIndex, offsetBy: start)
        let end = source.index(source.startIndex, offsetBy: current)
        let lexeme = String(source[begin..<end])
        tokens.append(Token(type: type, lexeme: lexeme, offset: start))
    }

    private func match(_ char: Character) -> Bool {
        if isAtEnd() {
            return false
        }
        if source[current] != char {
            return false
        }
        current += 1
        return true
    }

    private func readBinaryIntLiteral() {
        while !isAtEnd() && String(peek()!).isBinary() {
            _ = next()
        }
        addToken(type: .integer)
    }

    private func readOctalIntLiteral() {
        while !isAtEnd() && String(peek()!).isOctal() {
            _ = next()
        }
        addToken(type: .integer)
    }

    private func readDecimalIntLiteral() {
        while !isAtEnd() && String(peek()!).isDecimal() {
            _ = next()
        }
        addToken(type: .integer)
    }

    private func readHexIntLiteral() {
        while !isAtEnd() && String(peek()!).isHex() {
            _ = next()
        }
        addToken(type: .integer)
    }

    private func readNumberLiteral() {
        while !isAtEnd() && String(peek()!).isDecimal() {
            _ = next()
        }

        if isAtEnd() || (peek()! != "." && peek()! != "e") {
            addToken(type: .integer)
            return
        }

        if current < source.count - 1 {
            if peek()! == "." && String(peekNext()!).isDecimal() {
                _ = next()
                while !isAtEnd() && String(peek()!).isDecimal() {
                    _ = next()
                }
            }
        }

        if current < source.count - 1 {
            if peek()! == "e" {
                _ = next()
                if peek()! == "+" || peek() == "-" {
                    _ = next()
                }
                while !isAtEnd() && String(peek()!).isDecimal() {
                    _ = next()
                }
            }
        }

        addToken(type: .float)
    }

    private func peek() -> Character? {
        if isAtEnd() {
            return nil
        }
        return source[current]
    }

    private func peekNext() -> Character? {
        if current + 1 >= source.count {
            return nil
        }
        return source[current + 1]
    }

    private func readIdentifier() {
        while true {
            if isAtEnd() || !String(peek()!).isValidIdentfier() {
                break
            }
            _ = next()
        }
        let begin = source.index(source.startIndex, offsetBy: start)
        let end = source.index(source.startIndex, offsetBy: current)
        let lexeme = String(source[begin..<end])
        if let keywordType = keywords[lexeme] {
            addToken(type: keywordType)
        } else {
            addToken(type: .identifier)
        }
    }
}
