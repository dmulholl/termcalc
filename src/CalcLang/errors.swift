public enum CalcLangError: Error, Equatable {
    case syntaxError(_ offset: Int, _ lexeme: String, _ message: String)
    case runtimeError(_ offset: Int, _ lexeme: String, _ message: String)
}
