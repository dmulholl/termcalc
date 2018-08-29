
import Foundation


public class Terminal {

    public static func writeErr(_ string: String) {
        if let data = string.data(using: .utf8) {
            FileHandle.standardError.write(data)
        }
    }

    public enum Color: String {
        case reset = "\u{001B}[0m"
        case bold = "\u{001B}[1m"
        case dim = "\u{001B}[2m"
        case black = "\u{001B}[30m"
        case red = "\u{001B}[31m"
        case green = "\u{001B}[32m"
        case yellow = "\u{001B}[33m"
        case blue = "\u{001B}[34m"
        case magenta = "\u{001B}[35m"
        case cyan = "\u{001B}[36m"
        case white = "\u{001B}[37m"
        case grey = "\u{001B}[30;1m"

        public var string: String {
            return self.rawValue
        }
    }

    public init?() {
        if isatty(fileno(stdout)) == 0 {
            return nil
        }
    }

    public func setColor(_ color: Color) {
        print(color.string, terminator: "")
    }

    public func write(_ string: String, color: Color? = nil, times: Int = 1) {
        var output = string
        if let color = color {
            output = "\(color.string)\(string)\(Color.reset.string)"
        }
        for _ in 1...times {
            print(output, terminator: "")
        }
    }

    public func writeln(_ string: String, color: Color? = nil, times: Int = 1) {
        write(string, color: color, times: times)
        print()
    }

    public func flush() {
        fflush(stdout)
    }

    public func width() -> Int? {
        if let columns = ProcessInfo.processInfo.environment["COLUMNS"] {
            if let width = Int(columns) {
                return width
            }
        }

        var ws = winsize()
        if ioctl(1, UInt(TIOCGWINSZ), &ws) == 0 {
            return Int(ws.ws_col)
        }

        return nil
    }

    public func getLine(prompt: String,
                        color: Color? = nil,
                        editable: Bool = false) -> String? {
        if editable {
            return LineEditor(prompt: prompt, color: color).getLine()
        } else {
            write(prompt, color: color)
            return readLine()
        }
    }
}
