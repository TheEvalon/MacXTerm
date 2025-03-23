import Foundation
import SwiftUI

class TerminalEmulator: ObservableObject {
    @Published private(set) var buffer: [[TerminalCell]] = []
    @Published private(set) var cursorPosition: (x: Int, y: Int) = (0, 0)
    @Published private(set) var scrollbackBuffer: [String] = []
    
    private var currentAttributes: TerminalAttributes = TerminalAttributes()
    private var mode: TerminalMode = .normal
    private var escapeSequence: String = ""
    
    let columns: Int
    let rows: Int
    
    init(columns: Int = 80, rows: Int = 24) {
        self.columns = columns
        self.rows = rows
        initializeBuffer()
    }
    
    private func initializeBuffer() {
        buffer = Array(repeating: Array(repeating: TerminalCell(), count: columns), count: rows)
    }
    
    func write(_ data: Data) {
        guard let string = String(data: data, encoding: .utf8) else { return }
        
        for char in string {
            switch mode {
            case .normal:
                handleNormalMode(char)
            case .escape:
                handleEscapeMode(char)
            case .csi:
                handleCSIMode(char)
            }
        }
    }
    
    private func handleNormalMode(_ char: Character) {
        switch char {
        case "\u{1B}": // ESC
            mode = .escape
            escapeSequence = ""
        case "\r":
            cursorPosition.x = 0
        case "\n":
            newLine()
        case "\t":
            handleTab()
        default:
            writeCharacter(char)
        }
    }
    
    private func handleEscapeMode(_ char: Character) {
        if char == "[" {
            mode = .csi
        } else {
            mode = .normal
            // Handle other escape sequences
        }
    }
    
    private func handleCSIMode(_ char: Character) {
        if char.isNumber || char == ";" {
            escapeSequence.append(char)
        } else {
            handleCSICommand(char)
            mode = .normal
            escapeSequence = ""
        }
    }
    
    private func handleCSICommand(_ char: Character) {
        // Handle various CSI commands (cursor movement, colors, etc.)
        switch char {
        case "H": // Home
            cursorPosition = (0, 0)
        case "J": // Clear screen
            clearScreen()
        case "m": // Set attributes
            handleAttributes()
        default:
            break
        }
    }
    
    private func writeCharacter(_ char: Character) {
        if cursorPosition.x >= columns {
            newLine()
        }
        
        if cursorPosition.y >= rows {
            scrollUp()
        }
        
        buffer[cursorPosition.y][cursorPosition.x] = TerminalCell(
            character: char,
            attributes: currentAttributes
        )
        cursorPosition.x += 1
    }
    
    private func newLine() {
        cursorPosition.x = 0
        cursorPosition.y += 1
        if cursorPosition.y >= rows {
            scrollUp()
        }
    }
    
    private func handleTab() {
        let tabSize = 8
        cursorPosition.x = (cursorPosition.x + tabSize) & ~(tabSize - 1)
        if cursorPosition.x >= columns {
            newLine()
        }
    }
    
    private func scrollUp() {
        scrollbackBuffer.append(buffer[0].map { $0.character }.joined())
        buffer.removeFirst()
        buffer.append(Array(repeating: TerminalCell(), count: columns))
        cursorPosition.y = rows - 1
    }
    
    private func clearScreen() {
        buffer = Array(repeating: Array(repeating: TerminalCell(), count: columns), count: rows)
        cursorPosition = (0, 0)
    }
    
    private func handleAttributes() {
        // Parse and apply ANSI attributes
        let codes = escapeSequence.split(separator: ";").compactMap { Int($0) }
        for code in codes {
            switch code {
            case 0: // Reset
                currentAttributes = TerminalAttributes()
            case 30...37: // Foreground colors
                currentAttributes.foregroundColor = TerminalColor(rawValue: code - 30)
            case 40...47: // Background colors
                currentAttributes.backgroundColor = TerminalColor(rawValue: code - 40)
            default:
                break
            }
        }
    }
}

enum TerminalMode {
    case normal
    case escape
    case csi
}

struct TerminalCell {
    var character: Character = " "
    var attributes: TerminalAttributes = TerminalAttributes()
}

struct TerminalAttributes {
    var foregroundColor: TerminalColor = .default
    var backgroundColor: TerminalColor = .default
    var bold: Bool = false
    var italic: Bool = false
    var underline: Bool = false
    var blink: Bool = false
    var reverse: Bool = false
}

enum TerminalColor: Int {
    case black = 0
    case red = 1
    case green = 2
    case yellow = 3
    case blue = 4
    case magenta = 5
    case cyan = 6
    case white = 7
    case `default` = 9
    
    var color: Color {
        switch self {
        case .black: return .black
        case .red: return .red
        case .green: return .green
        case .yellow: return .yellow
        case .blue: return .blue
        case .magenta: return .purple
        case .cyan: return .cyan
        case .white: return .white
        case .default: return .primary
        }
    }
} 
