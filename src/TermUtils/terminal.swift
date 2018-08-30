
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

    public enum Color: String {
        case reset = "\u{001B}[0m"
        case bold = "\u{001B}[1m"
        case dim = "\u{001B}[2m"
        case underline = "\u{001B}[4m"
        case blink = "\u{001B}[5m"
        case hide = "\u{001B}[8m"

        case black = "\u{001B}[30m"
        case red = "\u{001B}[31m"
        case green = "\u{001B}[32m"
        case yellow = "\u{001B}[33m"
        case blue = "\u{001B}[34m"
        case magenta = "\u{001B}[35m"
        case cyan = "\u{001B}[36m"
        case white = "\u{001B}[37m"
        case def = "\u{001B}[39m"

        case brightBlack = "\u{001B}[90m"
        case brightRed = "\u{001B}[91m"
        case brightGreen = "\u{001B}[92m"
        case brightYellow = "\u{001B}[93m"
        case brightBlue = "\u{001B}[94m"
        case brightMagenta = "\u{001B}[95m"
        case brightCyan = "\u{001B}[96m"
        case brightWhite = "\u{001B}[97m"

        case grey = "\u{001B}[30;1m"

        public var string: String {
            return self.rawValue
        }
    }

    private var ln: LineNoise

    public init?() {
        if isatty(fileno(stdout)) == 0 {
            return nil
        }
        ln = LineNoise()
    }

    public func setColor(_ color: Color) {
        print(color.string, terminator: "")
    }

    public func write(_ string: String, color: Color? = nil, times: Int = 1) {
        var output = string
        if let color = color {
            output = "\(color.string)\(string)\(Color.reset.string)"
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

    public func getLineBasic(prompt: String, color: Color? = nil) -> String? {
        write(prompt, color: color)
        return readLine()
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
