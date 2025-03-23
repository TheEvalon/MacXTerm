import SwiftUI

@main
struct MacXTermApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandGroup(replacing: .saveItem) { }
            CommandGroup(replacing: .closeItem) { }
        }
    }
}

class AppState: ObservableObject {
    @Published var activeSessions: [TerminalSession] = []
    @Published var selectedSession: TerminalSession?
    @Published var sidebarVisible: Bool = true
    @Published var theme: AppTheme = .system
    
    // Add more app-wide state management here
}

enum AppTheme: String, CaseIterable {
    case light
    case dark
    case system
}

struct MainView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            TerminalTabView()
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }
        }
    }
    
    private func toggleSidebar() {
        appState.sidebarVisible.toggle()
    }
}

// Placeholder views - these will be implemented in separate files
struct SidebarView: View {
    var body: some View {
        Text("Sidebar")
    }
}

struct TerminalTabView: View {
    var body: some View {
        Text("Terminal Tabs")
    }
}

struct TerminalSession: Identifiable {
    let id = UUID()
    var title: String
    var type: SessionType
    var status: SessionStatus
    
    enum SessionType {
        case ssh
        case telnet
        case local
        case serial
    }
    
    enum SessionStatus {
        case disconnected
        case connecting
        case connected
        case error(String)
    }
} 
