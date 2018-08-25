

enum LangError: Error {
    case scanError(invalidCharacter: Character, offset: Int)
}
