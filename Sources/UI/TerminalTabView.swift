import SwiftUI

struct TerminalTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: TerminalSession?
    @State private var showingTabMenu = false
    @State private var tabMenuLocation: CGPoint?
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(appState.activeSessions) { session in
                        TabButton(
                            session: session,
                            isSelected: session.id == selectedTab?.id,
                            onSelect: { selectedTab = session },
                            onClose: { closeTab(session) }
                        )
                    }
                    
                    // New tab button
                    Button(action: { showingTabMenu = true }) {
                        Image(systemName: "plus")
                            .frame(width: 30, height: 30)
                            .background(Color(.windowBackgroundColor))
                    }
                    .buttonStyle(.plain)
                }
                .background(Color(.windowBackgroundColor))
            }
            .frame(height: 30)
            
            // Terminal content
            if let session = selectedTab {
                TerminalView(emulator: session.emulator)
                    .id(session.id) // Force view recreation when switching tabs
            } else {
                EmptyTerminalView()
            }
        }
        .contextMenu {
            ForEach(appState.activeSessions) { session in
                Button(action: { selectedTab = session }) {
                    Label(session.title, systemImage: "terminal")
                }
            }
        }
        .sheet(isPresented: $showingTabMenu) {
            TabMenuView(selectedTab: $selectedTab)
        }
    }
    
    private func closeTab(_ session: TerminalSession) {
        if let index = appState.activeSessions.firstIndex(where: { $0.id == session.id }) {
            appState.activeSessions.remove(at: index)
            if selectedTab?.id == session.id {
                selectedTab = appState.activeSessions.first
            }
        }
    }
}

struct TabButton: View {
    let session: TerminalSession
    let isSelected: Bool
    let onSelect: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
                .font(.system(size: 10))
            
            Text(session.title)
                .lineLimit(1)
            
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .frame(height: 30)
        .background(isSelected ? Color(.selectedContentBackgroundColor) : Color(.windowBackgroundColor))
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }
    
    private var statusIcon: String {
        switch session.status {
        case .connected:
            return "circle.fill"
        case .connecting:
            return "circle.dotted"
        case .disconnected:
            return "circle"
        case .error:
            return "exclamationmark.circle"
        }
    }
    
    private var statusColor: Color {
        switch session.status {
        case .connected:
            return .green
        case .connecting:
            return .yellow
        case .disconnected:
            return .gray
        case .error:
            return .red
        }
    }
}

struct EmptyTerminalView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "terminal")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Terminal Session")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Create a new session or select an existing one")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
    }
}

struct TabMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: TerminalSession?
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationView {
            List(appState.activeSessions) { session in
                Button(action: {
                    selectedTab = session
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "terminal")
                        Text(session.title)
                        Spacer()
                        if session.id == selectedTab?.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Switch Tab")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Extend TerminalSession to include emulator
extension TerminalSession {
    var emulator: TerminalEmulator {
        if _emulator == nil {
            _emulator = TerminalEmulator()
        }
        return _emulator
    }
    
    private var _emulator: TerminalEmulator?
} 