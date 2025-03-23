import XCTest
@testable import MacXTerm

final class TerminalEmulatorTests: XCTestCase {
    var emulator: TerminalEmulator!
    
    override func setUp() {
        super.setUp()
        emulator = TerminalEmulator(columns: 80, rows: 24)
    }
    
    override func tearDown() {
        emulator = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(emulator.buffer.count, 24)
        XCTAssertEqual(emulator.buffer[0].count, 80)
        XCTAssertEqual(emulator.cursorPosition.x, 0)
        XCTAssertEqual(emulator.cursorPosition.y, 0)
    }
    
    func testWriteCharacter() {
        emulator.write("A".data(using: .utf8)!)
        
        XCTAssertEqual(emulator.buffer[0][0].character, "A")
        XCTAssertEqual(emulator.cursorPosition.x, 1)
        XCTAssertEqual(emulator.cursorPosition.y, 0)
    }
    
    func testNewLine() {
        emulator.write("\n".data(using: .utf8)!)
        
        XCTAssertEqual(emulator.cursorPosition.x, 0)
        XCTAssertEqual(emulator.cursorPosition.y, 1)
    }
    
    func testCarriageReturn() {
        emulator.write("ABC".data(using: .utf8)!)
        emulator.write("\r".data(using: .utf8)!)
        
        XCTAssertEqual(emulator.cursorPosition.x, 0)
        XCTAssertEqual(emulator.cursorPosition.y, 0)
    }
    
    func testTab() {
        emulator.write("\t".data(using: .utf8)!)
        
        XCTAssertEqual(emulator.cursorPosition.x, 8)
        XCTAssertEqual(emulator.cursorPosition.y, 0)
    }
    
    func testScrollUp() {
        // Fill the buffer
        for _ in 0..<25 {
            emulator.write("A".data(using: .utf8)!)
            emulator.write("\n".data(using: .utf8)!)
        }
        
        XCTAssertEqual(emulator.buffer.count, 24)
        XCTAssertEqual(emulator.scrollbackBuffer.count, 1)
        XCTAssertEqual(emulator.cursorPosition.y, 23)
    }
    
    func testClearScreen() {
        emulator.write("ABC".data(using: .utf8)!)
        emulator.write("\u{1B}[2J".data(using: .utf8)!) // Clear screen escape sequence
        
        XCTAssertEqual(emulator.cursorPosition.x, 0)
        XCTAssertEqual(emulator.cursorPosition.y, 0)
        XCTAssertEqual(emulator.buffer[0][0].character, " ")
    }
    
    func testANSIColors() {
        emulator.write("\u{1B}[31m".data(using: .utf8)!) // Red foreground
        emulator.write("A".data(using: .utf8)!)
        
        XCTAssertEqual(emulator.buffer[0][0].attributes.foregroundColor, .red)
        
        emulator.write("\u{1B}[42m".data(using: .utf8)!) // Green background
        emulator.write("B".data(using: .utf8)!)
        
        XCTAssertEqual(emulator.buffer[0][1].attributes.backgroundColor, .green)
    }
    
    func testMultipleAttributes() {
        emulator.write("\u{1B}[31;42m".data(using: .utf8)!) // Red foreground, green background
        emulator.write("A".data(using: .utf8)!)
        
        XCTAssertEqual(emulator.buffer[0][0].attributes.foregroundColor, .red)
        XCTAssertEqual(emulator.buffer[0][0].attributes.backgroundColor, .green)
    }
    
    func testResetAttributes() {
        emulator.write("\u{1B}[31;42m".data(using: .utf8)!) // Set attributes
        emulator.write("A".data(using: .utf8)!)
        emulator.write("\u{1B}[0m".data(using: .utf8)!) // Reset attributes
        emulator.write("B".data(using: .utf8)!)
        
        XCTAssertEqual(emulator.buffer[0][1].attributes.foregroundColor, .default)
        XCTAssertEqual(emulator.buffer[0][1].attributes.backgroundColor, .default)
    }
} 
