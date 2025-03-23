import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("terminal.fontSize") private var fontSize: Double = 12
    @AppStorage("terminal.fontFamily") private var fontFamily: String = "Menlo"
    @AppStorage("terminal.theme") private var theme: AppTheme = .system
    @AppStorage("terminal.cursorStyle") private var cursorStyle: CursorStyle = .block
    @AppStorage("terminal.showScrollbar") private var showScrollbar: Bool = true
    @AppStorage("terminal.bellEnabled") private var bellEnabled: Bool = true
    @AppStorage("terminal.autoReconnect") private var autoReconnect: Bool = true
    @AppStorage("terminal.keepAliveInterval") private var keepAliveInterval: Double = 60
    
    var body: some View {
        NavigationView {
            List {
                Section("Appearance") {
                    Picker("Theme", selection: $theme) {
                        Text("Light").tag(AppTheme.light)
                        Text("Dark").tag(AppTheme.dark)
                        Text("System").tag(AppTheme.system)
                    }
                    
                    Picker("Font Family", selection: $fontFamily) {
                        Text("Menlo").tag("Menlo")
                        Text("Monaco").tag("Monaco")
                        Text("SF Mono").tag("SF Mono")
                        Text("Courier").tag("Courier")
                    }
                    
                    HStack {
                        Text("Font Size")
                        Slider(value: $fontSize, in: 8...24, step: 1)
                    }
                    
                    Picker("Cursor Style", selection: $cursorStyle) {
                        Text("Block").tag(CursorStyle.block)
                        Text("Underline").tag(CursorStyle.underline)
                        Text("Vertical Bar").tag(CursorStyle.verticalBar)
                    }
                    
                    Toggle("Show Scrollbar", isOn: $showScrollbar)
                }
                
                Section("Behavior") {
                    Toggle("Terminal Bell", isOn: $bellEnabled)
                    Toggle("Auto Reconnect", isOn: $autoReconnect)
                    
                    HStack {
                        Text("Keep-Alive Interval")
                        Slider(value: $keepAliveInterval, in: 30...300, step: 30)
                        Text("\(Int(keepAliveInterval))s")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Keyboard") {
                    NavigationLink("Keyboard Shortcuts") {
                        KeyboardShortcutsView()
                    }
                }
                
                Section("Network") {
                    NavigationLink("Proxy Settings") {
                        ProxySettingsView()
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Check for Updates", destination: URL(string: "https://github.com/yourusername/MacXTerm/releases")!)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct KeyboardShortcutsView: View {
    var body: some View {
        List {
            Section("General") {
                ShortcutRow(title: "New Tab", shortcut: "⌘T")
                ShortcutRow(title: "Close Tab", shortcut: "⌘W")
                ShortcutRow(title: "Next Tab", shortcut: "⌘⇥")
                ShortcutRow(title: "Previous Tab", shortcut: "⌘⇧⇥")
                ShortcutRow(title: "Switch to Tab", shortcut: "⌘1-9")
            }
            
            Section("Terminal") {
                ShortcutRow(title: "Copy", shortcut: "⌘C")
                ShortcutRow(title: "Paste", shortcut: "⌘V")
                ShortcutRow(title: "Select All", shortcut: "⌘A")
                ShortcutRow(title: "Clear Screen", shortcut: "⌘K")
                ShortcutRow(title: "Find", shortcut: "⌘F")
            }
            
            Section("Window") {
                ShortcutRow(title: "New Window", shortcut: "⌘N")
                ShortcutRow(title: "Close Window", shortcut: "⌘⇧W")
                ShortcutRow(title: "Minimize", shortcut: "⌘M")
                ShortcutRow(title: "Zoom", shortcut: "⌘⌥Z")
            }
        }
        .navigationTitle("Keyboard Shortcuts")
    }
}

struct ProxySettingsView: View {
    @AppStorage("proxy.enabled") private var proxyEnabled: Bool = false
    @AppStorage("proxy.host") private var proxyHost: String = ""
    @AppStorage("proxy.port") private var proxyPort: String = ""
    @AppStorage("proxy.username") private var proxyUsername: String = ""
    @AppStorage("proxy.password") private var proxyPassword: String = ""
    
    var body: some View {
        Form {
            Toggle("Enable Proxy", isOn: $proxyEnabled)
            
            if proxyEnabled {
                TextField("Proxy Host", text: $proxyHost)
                TextField("Proxy Port", text: $proxyPort)
                    .keyboardType(.numberPad)
                TextField("Username", text: $proxyUsername)
                SecureField("Password", text: $proxyPassword)
            }
        }
        .navigationTitle("Proxy Settings")
    }
}

struct ShortcutRow: View {
    let title: String
    let shortcut: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(shortcut)
                .foregroundColor(.secondary)
        }
    }
}

enum CursorStyle: String, CaseIterable {
    case block
    case underline
    case verticalBar
} 
