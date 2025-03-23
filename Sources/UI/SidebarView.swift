import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingNewSessionSheet = false
    @State private var selectedGroup: SessionGroup?
    @State private var searchText = ""
    
    var body: some View {
        List {
            Section("Quick Actions") {
                Button(action: { showingNewSessionSheet = true }) {
                    Label("New Session", systemImage: "plus.circle.fill")
                }
                
                Button(action: { /* TODO: Show settings */ }) {
                    Label("Settings", systemImage: "gear")
                }
            }
            
            Section("Sessions") {
                ForEach(filteredSessions) { session in
                    SessionRow(session: session)
                }
                .onDelete(perform: deleteSessions)
            }
            
            Section("Groups") {
                ForEach(sessionGroups) { group in
                    SessionGroupRow(group: group)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search sessions")
        .sheet(isPresented: $showingNewSessionSheet) {
            NewSessionSheet()
        }
    }
    
    private var filteredSessions: [TerminalSession] {
        if searchText.isEmpty {
            return appState.activeSessions
        }
        return appState.activeSessions.filter { session in
            session.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var sessionGroups: [SessionGroup] {
        // TODO: Implement session grouping
        return []
    }
    
    private func deleteSessions(at offsets: IndexSet) {
        appState.activeSessions.remove(atOffsets: offsets)
    }
}

struct SessionRow: View {
    let session: TerminalSession
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
            
            VStack(alignment: .leading) {
                Text(session.title)
                    .font(.headline)
                Text(session.type.rawValue.uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if session.id == appState.selectedSession?.id {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            appState.selectedSession = session
        }
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

struct SessionGroupRow: View {
    let group: SessionGroup
    @State private var isExpanded = true
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(group.sessions) { session in
                SessionRow(session: session)
            }
        } label: {
            Label(group.name, systemImage: "folder")
        }
    }
}

struct SessionGroup: Identifiable {
    let id = UUID()
    let name: String
    let sessions: [TerminalSession]
}

struct NewSessionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var sessionType: TerminalSession.SessionType = .ssh
    @State private var host = ""
    @State private var port = ""
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Session Type", selection: $sessionType) {
                    Text("SSH").tag(TerminalSession.SessionType.ssh)
                    Text("Telnet").tag(TerminalSession.SessionType.telnet)
                    Text("Local").tag(TerminalSession.SessionType.local)
                    Text("Serial").tag(TerminalSession.SessionType.serial)
                }
                
                if sessionType != .local {
                    TextField("Host", text: $host)
                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                }
                
                if sessionType == .ssh {
                    TextField("Username", text: $username)
                    SecureField("Password", text: $password)
                }
            }
            .navigationTitle("New Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Connect") {
                        createSession()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        switch sessionType {
        case .ssh:
            return !host.isEmpty && !username.isEmpty
        case .telnet:
            return !host.isEmpty
        case .local:
            return true
        case .serial:
            return false // TODO: Implement serial validation
        }
    }
    
    private func createSession() {
        let session: TerminalSession
        
        switch sessionType {
        case .ssh:
            session = appState.sessionManager.createSSHSession(
                host: host,
                port: Int(port) ?? 22,
                username: username,
                password: password.isEmpty ? nil : password
            )
        case .telnet:
            session = appState.sessionManager.createTelnetSession(
                host: host,
                port: Int(port) ?? 23
            )
        case .local:
            session = appState.sessionManager.createLocalSession()
        case .serial:
            // TODO: Implement serial session creation
            return
        }
        
        appState.activeSessions.append(session)
        appState.selectedSession = session
        dismiss()
    }
} 