# Contributing to iReminderCLI

Thank you for your interest in contributing to iReminderCLI! This guide will help you get started with contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR-USERNAME/iReminderCLI.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Run tests: `swift test`
6. Commit your changes: `git commit -m "Add new feature"`
7. Push to your fork: `git push origin feature/your-feature-name`
8. Create a Pull Request

## Development Setup

### Prerequisites

- macOS 13.0+ (Ventura or later)
- Swift 6.1+ with StrictConcurrency support
- Xcode or Swift command line tools

### Building

```bash
# Build debug version
swift build

# Build release version
swift build -c release

# Run tests
swift test
```

## Code Style

Please follow these coding conventions:

- **Indentation**: 2 spaces (no tabs)
- **Line length**: 80 characters maximum
- **Naming**: 
  - PascalCase for types
  - camelCase for functions and variables
  - kebab-case for command names
- **Access Control**: Use explicit `private` for internal methods
- **Error Handling**: Provide descriptive error messages

## Architecture Guidelines

### Adding New Commands

1. Create a new file in `Sources/iReminderCLI/Commands/`
2. Implement a struct conforming to `ParsableCommand`
3. Follow the existing command pattern:

```swift
struct NewCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "command-name",
    abstract: "Brief description"
  )
  
  @Argument var requiredArg: String
  @Option var optionalArg: String?
  
  mutating func run() throws {
    // Implementation
  }
}
```

3. Add the command to the main `iReminderCLI` struct's subcommands array
4. Add tests in `Tests/iReminderCLITests/`

### Error Handling

Always output errors to stderr:

```swift
print("Error: \(message)", to: &standardError)
throw ExitCode.failure
```

When displaying existing data on error (like the duplicate list example), provide helpful context to the user.

### Testing

- Write unit tests for new functionality
- Use the mock classes in `Tests/iReminderCLITests/Mocks/`
- Test both success and failure cases
- Ensure command parsing works correctly

## Pull Request Process

1. Update the README.md with details of changes if applicable
2. Add tests for new functionality
3. Ensure all tests pass: `swift test`
4. Update CLAUDE.md if you're adding new architectural patterns
5. Your PR will be reviewed by maintainers

## Reporting Issues

When reporting issues, please include:

- macOS version
- Swift version
- Steps to reproduce
- Expected behavior
- Actual behavior
- Any error messages

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive criticism
- Assume good intentions

## Questions?

If you have questions about contributing, feel free to open an issue with the "question" label.