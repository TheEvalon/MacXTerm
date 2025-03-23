# MacXTerm

A comprehensive remote computing and terminal tool for macOS that replicates and extends MobaXterm functionality.

## Features

- Tabbed terminal interface with multi-session support
- Integrated SSH/SFTP client
- X server capabilities
- Multi-session management
- Built-in Unix command utilities
- Tunneling and port forwarding
- Macro and scripting support
- Plugin system
- Secure credential management
- Customizable themes and layouts

## Requirements

- macOS 12.0 or later
- Xcode 14.0 or later
- Swift 5.7 or later
- OpenSSH
- XQuartz (for X11 support)

## Building from Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/MacXTerm.git
cd MacXTerm
```

2. Install dependencies:
```bash
brew install openssh xquartz
```

3. Open the project in Xcode:
```bash
open MacXTerm.xcodeproj
```

4. Build and run the project (⌘R)

## Project Structure

```
MacXTerm/
├── Sources/
│   ├── App/                 # Main application entry point
│   ├── UI/                  # User interface components
│   ├── Core/                # Core functionality
│   ├── Terminal/            # Terminal emulation
│   ├── Session/             # Session management
│   ├── Network/             # Network protocols
│   ├── Security/            # Security features
│   └── Plugins/             # Plugin system
├── Resources/               # Application resources
├── Tests/                   # Unit and integration tests
└── Documentation/           # Project documentation
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by MobaXterm
- Built with SwiftUI and modern macOS frameworks
- Community-driven development 