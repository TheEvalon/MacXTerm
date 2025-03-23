import SwiftUI

struct TerminalView: View {
    @ObservedObject var emulator: TerminalEmulator
    @State private var fontSize: CGFloat = 12
    @State private var fontFamily: String = "Menlo"
    @State private var isSelecting: Bool = false
    @State private var selectionStart: CGPoint?
    @State private var selectionEnd: CGPoint?
    
    private let cellWidth: CGFloat = 8
    private let cellHeight: CGFloat = 16
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical]) {
                ZStack(alignment: .topLeading) {
                    // Terminal content
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(0..<emulator.buffer.count, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<emulator.buffer[row].count, id: \.self) { col in
                                    let cell = emulator.buffer[row][col]
                                    Text(String(cell.character))
                                        .font(.custom(fontFamily, size: fontSize))
                                        .foregroundColor(cell.attributes.foregroundColor.color)
                                        .background(cell.attributes.backgroundColor.color)
                                        .frame(width: cellWidth, height: cellHeight)
                                }
                            }
                        }
                    }
                    
                    // Cursor
                    if let cursor = emulator.cursorPosition {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: cellWidth, height: cellHeight)
                            .position(
                                x: CGFloat(cursor.x) * cellWidth + cellWidth/2,
                                y: CGFloat(cursor.y) * cellHeight + cellHeight/2
                            )
                    }
                    
                    // Selection overlay
                    if isSelecting, let start = selectionStart, let end = selectionEnd {
                        SelectionOverlay(start: start, end: end)
                    }
                }
                .frame(
                    width: CGFloat(emulator.columns) * cellWidth,
                    height: CGFloat(emulator.rows) * cellHeight
                )
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isSelecting {
                            isSelecting = true
                            selectionStart = value.location
                        }
                        selectionEnd = value.location
                    }
                    .onEnded { _ in
                        isSelecting = false
                        // Handle selection
                        if let start = selectionStart,
                           let end = selectionEnd {
                            handleSelection(from: start, to: end)
                        }
                        selectionStart = nil
                        selectionEnd = nil
                    }
            )
        }
        .background(Color.black)
    }
    
    private func handleSelection(from start: CGPoint, to end: CGPoint) {
        // Convert screen coordinates to buffer coordinates
        let startCol = Int(start.x / cellWidth)
        let startRow = Int(start.y / cellHeight)
        let endCol = Int(end.x / cellWidth)
        let endRow = Int(end.y / cellHeight)
        
        // Ensure coordinates are within bounds
        let minRow = max(0, min(startRow, endRow))
        let maxRow = min(emulator.buffer.count - 1, max(startRow, endRow))
        let minCol = max(0, min(startCol, endCol))
        let maxCol = min(emulator.buffer[0].count - 1, max(startCol, endCol))
        
        // Extract selected text
        var selectedText = ""
        for row in minRow...maxRow {
            let startCol = row == minRow ? minCol : 0
            let endCol = row == maxRow ? maxCol : emulator.buffer[row].count - 1
            let rowText = emulator.buffer[row][startCol...endCol]
                .map { String($0.character) }
                .joined()
            selectedText += rowText + (row < maxRow ? "\n" : "")
        }
        
        // Copy to clipboard
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(selectedText, forType: .string)
    }
}

struct SelectionOverlay: View {
    let start: CGPoint
    let end: CGPoint
    
    var body: some View {
        let rect = CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
        
        Rectangle()
            .fill(Color.blue.opacity(0.3))
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
    }
}

#Preview {
    TerminalView(emulator: TerminalEmulator())
} 