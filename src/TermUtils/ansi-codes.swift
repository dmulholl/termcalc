
struct AnsiCodes {

    func escape(_ code: String) -> String {
        return "\u{001B}[\(code)"
    }











}
