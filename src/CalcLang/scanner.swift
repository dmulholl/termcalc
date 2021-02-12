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
        let char = nextChar()

        // Single-character tokens.
        if char == "(" {
            addToken(type: .left_paren)
        } else if char == ")" {
            addToken(type: .right_paren)
        } else if char == "," {
            addToken(type: .comma)
        } else if char == "=" {
            addToken(type: .equal)
        } else if char == "!" {
            addToken(type: .bang)
        }

        // Single or double-character tokens.
        else if char == "+" {
            match("=") ? addToken(type: .plus_equal) : addToken(type: .plus)
        } else if char == "-" {
            match("=") ? addToken(type: .minus_equal) : addToken(type: .minus)
        } else if char == "*" {
            match("=") ? addToken(type: .star_equal) : addToken(type: .star)
        } else if char == "/" {
            match("=") ? addToken(type: .slash_equal) : addToken(type: .slash)
        } else if char == "%" {
            match("=") ? addToken(type: .mod_equal) : addToken(type: .mod)
        } else if char == "^" {
            match("=") ? addToken(type: .caret_equal) : addToken(type: .caret)
        }

        // Whitespace.
        else if String(char).isWhitespace() {
            // We simply skip whitespace characters.
        }

        // Integer literals with a base specifier.
        else if char == "0" {
            if match("b") {
                readBinaryInt()
            } else if match("o") {
                readOctalInt()
            } else if match("d") {
                readDecimalInt()
            } else if match("x") {
                readHexInt()
            } else {
                readIntOrFloat()
            }
        }

        // Decimal integer or float.
        else if String(char).isDecimal() {
            readIntOrFloat()
        }

        // Float literals beginning with a '.'.
        else if char == "." && String(peek()!).isDecimal() {
            readDotFloat()
        }

        // Identifiers & keywords.
        else if String(char).isAlpha() {
            readIdentifier()
        }

        // Reference.
        else if char == "$" {
            while !isAtEnd() && String(peek()!).isDecimal() {
                nextChar()
            }
            addToken(type: .identifier)
        }

        else {
            throw CalcLangError.syntaxError(
                current - 1,
                "\(char)",
                "Invalid character '\(char)' in input."
            )
        }
    }

    private func isAtEnd() -> Bool {
        return current >= source.count
    }

    @discardableResult private func nextChar() -> Character {
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

    private func readBinaryInt() {
        while !isAtEnd() && (String(peek()!).isBinary() || peek()! == "_") {
            nextChar()
        }
        addToken(type: .integer)
    }

    private func readOctalInt() {
        while !isAtEnd() && (String(peek()!).isOctal() || peek()! == "_") {
            nextChar()
        }
        addToken(type: .integer)
    }

    private func readDecimalInt() {
        while !isAtEnd() && (String(peek()!).isDecimal() || peek()! == "_") {
            nextChar()
        }
        addToken(type: .integer)
    }

    private func readHexInt() {
        while !isAtEnd() && (String(peek()!).isHex() || peek()! == "_") {
            nextChar()
        }
        addToken(type: .integer)
    }

    private func readIntOrFloat() {
        while !isAtEnd() && (String(peek()!).isDecimal() || peek()! == "_") {
            nextChar()
        }
        if isAtEnd() || (peek()! != "." && peek()! != "e") {
            addToken(type: .integer)
            return
        }
        if current < source.count - 1 {
            if peek()! == "." && String(peekNext()!).isDecimal() {
                nextChar()
                while !isAtEnd() && (String(peek()!).isDecimal() || peek()! == "_") {
                    nextChar()
                }
            }
        }
        if current < source.count - 1 {
            if peek()! == "e" {
                nextChar()
                if peek()! == "+" || peek() == "-" {
                    nextChar()
                }
                while !isAtEnd() && (String(peek()!).isDecimal() || peek()! == "_") {
                    nextChar()
                }
            }
        }
        addToken(type: .float)
    }

    private func readDotFloat() {
        while !isAtEnd() && (String(peek()!).isDecimal() || peek()! == "_") {
            nextChar()
        }
        if current < source.count - 1 {
            if peek()! == "e" {
                nextChar()
                if peek()! == "+" || peek() == "-" {
                    nextChar()
                }
                while !isAtEnd() && (String(peek()!).isDecimal() || peek()! == "_") {
                    nextChar()
                }
            }
        }
        addToken(type: .dot_float)
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
            nextChar()
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
