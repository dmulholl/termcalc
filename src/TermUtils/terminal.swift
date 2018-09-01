
import Foundation
import LineNoise

public class Terminal {

    public static func writeErr(_ string: String) {
        if let data = string.data(using: .utf8) {
            FileHandle.standardError.write(data)
        }
    }

    public static func isTerminalStdin() -> Bool {
        return isatty(fileno(stdin)) != 0
    }

    public static func isTerminalStdout() -> Bool {
        return isatty(fileno(stdout)) != 0
    }

    public static func isTerminalStderr() -> Bool {
        return isatty(fileno(stderr)) != 0
    }

    public enum Color: Int {

        // Reset all attributes.
        case reset = 0

        // Attributes.
        case bold = 1
        case dim = 2
        case underline = 4
        case blink = 5
        case reverse = 7
        case hidden = 8
        case strikeout = 9

        // Foreground colors.
        case black = 30
        case red = 31
        case green = 32
        case yellow = 33
        case blue = 34
        case magenta = 35
        case cyan = 36
        case white = 37

        // Foreground colors (bright/light).
        case brightBlack = 90
        case brightRed = 91
        case brightGreen = 92
        case brightYellow = 93
        case brightBlue = 94
        case brightMagenta = 95
        case brightCyan = 96
        case brightWhite = 97

        // Background colors.
        case bgBlack = 40
        case bgRed = 41
        case bgGreen = 42
        case bgYellow = 43
        case bgBlue = 44
        case bgMagenta = 45
        case bgCyan = 46
        case bgWhite = 47

        // Background colors (bright/light).
        case bgBrightBlack = 100
        case bgBrightRed = 101
        case bgBrightGreen = 102
        case bgBrightYellow = 103
        case bgBrightBlue = 104
        case bgBrightMagenta = 105
        case bgBrightCyan = 106
        case bgBrightWhite = 107

        // Default foreground & background  colors.
        case standard = 39
        case bgStandard = 49

        public var string: String {
            return "\u{001B}[\(self.rawValue)m"
        }
    }

    private var ln: LineNoise

    public init?() {
        if isatty(fileno(stdout)) == 0 {
            return nil
        }
        ln = LineNoise()
    }

    public func setColor(_ colors: Color...) {
        if colors.count > 0 {
            let codes = colors.map({String($0.rawValue)}).joined(separator: ";")
            print("\u{001B}[\(codes)m", terminator: "")

        }
    }

    public func setColor256(_ color: UInt8) {
        print("\u{001B}38;5;\(color)m", terminator: "")
    }

    public func setBgColor256(_ color: UInt8) {
        print("\u{001B}48;5;\(color)m", terminator: "")
    }

    public func write(_ string: String, color: Color? = nil, times: Int = 1) {
        var output = string
        if let color = color {
            output = "\(color.string)\(string)\(Color.standard.string)"
        }
        for _ in 0..<times {
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

    public func getLine(prompt: String, color: Color? = nil) -> String {
        return LineEditor(prompt: prompt, color: color).getLine()
    }

    public func getLineNoise(prompt: String, color: Color? = nil) throws -> String {
        do {
            let input: String
            if color == nil {
                input = try ln.getLine(prompt: prompt)
            } else {
                let promptstr = "\(color!.string)\(prompt)\(Color.reset.string)"
                ln.promptDelta =  promptstr.count - prompt.count
                input = try ln.getLine(prompt: promptstr)
            }
            ln.addHistory(input)
            return input
        } catch LinenoiseError.EOF {
            throw TermUtilsError.eof
        } catch LinenoiseError.CTRL_C {
            throw TermUtilsError.ctrl_c
        } catch LinenoiseError.generalError(let message) {
            throw TermUtilsError.linenoise(message)
        }
    }
}
