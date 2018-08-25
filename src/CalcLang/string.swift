
import Foundation

extension String {
    
    func isAlpha() -> Bool {
        return
            !isEmpty &&
            rangeOfCharacter(from: CharacterSet.letters.inverted) == nil
    }

    func isDigit() -> Bool {
        return
            !isEmpty &&
            rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }

    func isAlphanumeric() -> Bool {
        return
            !isEmpty &&
            rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil
    }

    func isWhitespace() -> Bool {
        return
            !isEmpty &&
            self.rangeOfCharacter(
                from: CharacterSet.whitespacesAndNewlines.inverted) == nil
    }
}
