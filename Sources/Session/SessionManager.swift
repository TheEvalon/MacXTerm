import Foundation
import Network

class SessionManager: ObservableObject {
    @Published private(set) var sessions: [TerminalSession] = []
    @Published private(set) var activeSession: TerminalSession?
    
    private var connections: [UUID: NWConnection] = [:]
    private var sessionQueues: [UUID: DispatchQueue] = [:]
    
    func createSession(type: TerminalSession.SessionType, title: String) -> TerminalSession {
        let session = TerminalSession(title: title, type: type, status: .disconnected)
        sessions.append(session)
        return session
    }
    
    func connect(session: TerminalSession, host: String, port: Int, username: String, password: String? = nil) {
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        
        sessions[index].status = .connecting
        
        let endpoint = NWEndpoint.hostPort(
            NWEndpoint.Host(host),
            NWEndpoint.Port(integerLiteral: UInt16(port))
        )
        
        let connection = NWConnection(
            to: endpoint,
            using: .tls
        )
        
        connections[session.id] = connection
        sessionQueues[session.id] = DispatchQueue(label: "com.macxterm.session.\(session.id)")
        
        connection.stateUpdateHandler = { [weak self] state in
            self?.handleConnectionState(state, for: session)
        }
        
        connection.start(queue: sessionQueues[session.id]!)
    }
    
    func disconnect(session: TerminalSession) {
        guard let connection = connections[session.id] else { return }
        
        connection.cancel()
        connections.removeValue(forKey: session.id)
        sessionQueues.removeValue(forKey: session.id)
        
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index].status = .disconnected
        }
    }
    
    func sendData(_ data: Data, to session: TerminalSession) {
        guard let connection = connections[session.id] else { return }
        
        connection.send(content: data, completion: .contentProcessed { [weak self] error in
            if let error = error {
                self?.handleError(error, for: session)
            }
        })
    }
    
    private func handleConnectionState(_ state: NWConnection.State, for session: TerminalSession) {
        switch state {
        case .ready:
            if let index = sessions.firstIndex(where: { $0.id == session.id }) {
                sessions[index].status = .connected
                setupReceive(for: session)
            }
        case .failed(let error):
            handleError(error, for: session)
        case .cancelled:
            if let index = sessions.firstIndex(where: { $0.id == session.id }) {
                sessions[index].status = .disconnected
            }
        default:
            break
        }
    }
    
    private func setupReceive(for session: TerminalSession) {
        guard let connection = connections[session.id] else { return }
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            if let error = error {
                self?.handleError(error, for: session)
                return
            }
            
            if let data = content {
                // Handle received data
                NotificationCenter.default.post(
                    name: .sessionDataReceived,
                    object: nil,
                    userInfo: ["sessionId": session.id, "data": data]
                )
            }
            
            if !isComplete {
                self?.setupReceive(for: session)
            }
        }
    }
    
    private func handleError(_ error: Error, for session: TerminalSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index].status = .error(error.localizedDescription)
        }
        disconnect(session: session)
    }
}

extension Notification.Name {
    static let sessionDataReceived = Notification.Name("sessionDataReceived")
}

// SSH-specific session handling
extension SessionManager {
    func createSSHSession(host: String, port: Int, username: String, password: String? = nil) -> TerminalSession {
        let session = createSession(type: .ssh, title: "\(username)@\(host)")
        
        // Initialize SSH connection
        connect(session: session, host: host, port: port, username: username, password: password)
        
        return session
    }
}

// Telnet-specific session handling
extension SessionManager {
    func createTelnetSession(host: String, port: Int) -> TerminalSession {
        let session = createSession(type: .telnet, title: "telnet://\(host):\(port)")
        
        // Initialize Telnet connection
        connect(session: session, host: host, port: port, username: "", password: nil)
        
        return session
    }
}

// Local terminal session handling
extension SessionManager {
    func createLocalSession() -> TerminalSession {
        let session = createSession(type: .local, title: "Local Terminal")
        
        // Initialize local terminal process
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["--login"]
        
        do {
            try process.run()
            if let index = sessions.firstIndex(where: { $0.id == session.id }) {
                sessions[index].status = .connected
            }
        } catch {
            if let index = sessions.firstIndex(where: { $0.id == session.id }) {
                sessions[index].status = .error(error.localizedDescription)
            }
        }
        
        return session
    }
} 
