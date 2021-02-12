import Foundation


let binaryCharacters = CharacterSet(charactersIn: "01")
let octalCharacters = CharacterSet(charactersIn: "01234567")
let hexCharacters = CharacterSet(charactersIn: "0123456789abcdefABCDEF")


let identifierCharacters = CharacterSet.alphanumerics.union(
    CharacterSet(charactersIn: "_")
)


// This extension enables indexing into strings, e.g. foo[5].
extension String {
    subscript(offset: Int) -> String {
        return String(self[index(startIndex, offsetBy: offset)])
    }
}


// Extension methods on the String type required by the scanner.
extension String {

    func isAlpha() -> Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.letters.inverted) == nil
    }

    func isDecimal() -> Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }

    func isAlphanumeric() -> Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil
    }

    func isValidIdentfier() -> Bool {
        return !isEmpty && rangeOfCharacter(from: identifierCharacters.inverted) == nil
    }

    func isWhitespace() -> Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines.inverted) == nil
    }

    func isBinary() -> Bool {
        return !isEmpty && rangeOfCharacter(from: binaryCharacters.inverted) == nil
    }

    func isOctal() -> Bool {
        return !isEmpty && rangeOfCharacter(from: octalCharacters.inverted) == nil
    }

    func isHex() -> Bool {
        return !isEmpty && rangeOfCharacter(from: hexCharacters.inverted) == nil
    }
}
