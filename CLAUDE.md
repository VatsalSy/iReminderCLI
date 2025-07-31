# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with the iReminderCLI repository.

## Project Overview

iReminderCLI is a Swift command-line interface for managing Apple Reminders on macOS. It provides comprehensive CRUD operations for reminders and lists through a clean, intuitive command structure. The tool integrates directly with macOS EventKit framework to interact with the native Reminders app.

**Key Features:**
- Complete reminder management (add, edit, delete, complete/uncomplete)
- Natural language date parsing (e.g., "tomorrow 3pm", "next Monday")
- JSON output support for scripting and automation
- List management (show, create)
- Priority and notes support
- Flexible filtering and sorting options

## Build and Development Commands

```bash
# Build debug version
swift build

# Build release version for distribution
swift build -c release

# Install to system PATH
cp .build/release/iReminderCLI /usr/local/bin/ireminder

# Run directly from build directory
.build/debug/iReminderCLI --help

# Clean build artifacts
swift package clean

# Show package dependencies
swift package show-dependencies

# Run with specific subcommand
swift run iReminderCLI show-lists
swift run iReminderCLI add "Shopping" "Buy milk"
```

## Architecture Overview

The project follows a clean command-pattern architecture using Swift ArgumentParser:

### Core Components

1. **Main Entry Point** (`iReminderCLI.swift`)
   - Uses `@main` attribute with `ParsableCommand`
   - Defines subcommands and global configuration
   - Version: 1.0.0

2. **Reminders Core** (`Reminders.swift`)
   - Central EventKit integration class
   - Handles permission requests (supports macOS 14+ full access API)
   - CRUD operations for reminders and lists
   - Synchronous operations using DispatchSemaphore

3. **Command Structure** (`Commands/`)
   - Each command is a separate `ParsableCommand` struct
   - Consistent error handling with standardError stream
   - JSON output support where applicable
   - Input validation and user-friendly error messages

4. **Utilities** (`Utilities/`)
   - **DateParser**: Natural language date parsing with NSDataDetector
   - **DateFormatting**: Display formatting for dates
   - **ReminderFormatting**: Display and JSON serialization
   - **ReminderFinder**: Search and indexing utilities

### Command Architecture

All commands follow this pattern:
```swift
struct CommandName: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "command-name",
    abstract: "Brief description"
  )
  
  // Arguments and options defined with property wrappers
  @Argument var required: String
  @Option var optional: String?
  @Flag var boolean = false
  
  mutating func run() throws {
    // Implementation with proper error handling
  }
}
```

## Available Commands

### Core Commands
- `show-lists` - List all reminder lists with optional JSON output
- `show <list>` - Show reminders in specific list with filtering
- `show-all` - Show reminders from all lists
- `add <list> <text>` - Add new reminder with optional due date, priority, notes
- `complete <list> <index>` - Mark reminder as complete
- `uncomplete <list> <index>` - Mark reminder as incomplete
- `edit <list> <index> [text]` - Edit reminder title and/or notes
- `delete <list> <index>` - Delete reminder
- `new-list <name>` - Create new reminder list

### Common Patterns
- List names are case-insensitive
- Index-based operations use 0-based indexing
- ID-based operations support Apple reminder URLs
- All commands support `--help` for detailed usage

## Code Conventions and Patterns

### Swift Style
- **Indentation**: 2 spaces (consistent with global style)
- **Naming**: 
  - PascalCase for types (`Reminders`, `DateParser`)
  - camelCase for functions and variables (`getList`, `listName`)
  - kebab-case for command names (`show-lists`, `due-date`)
- **Access Control**: Explicit `private` for internal methods
- **Error Handling**: Comprehensive try-catch with descriptive messages

### Architecture Patterns
1. **Command Pattern**: Each operation is encapsulated in a command struct
2. **Dependency Injection**: Reminders instance created in each command
3. **Separation of Concerns**: Utilities handle specific responsibilities
4. **Synchronous Operations**: Using DispatchSemaphore for EventKit async calls

### Error Handling Strategy
```swift
// Standard error output pattern
print("Error message", to: &standardError)
throw ExitCode.failure

// EventKit operation pattern
do {
  try reminders.someOperation()
  print("Success message")
} catch {
  print("Failed to perform operation: \(error.localizedDescription)", to: &standardError)
  throw ExitCode.failure
}
```

### JSON Output Pattern
All commands with `--json` flag follow this structure:
```swift
if json {
  let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
  print(String(data: jsonData, encoding: .utf8)!)
} else {
  // Human-readable output
}
```

## Natural Language Date Parsing

The `DateParser` class supports extensive natural language formats:

### Supported Formats
- **Relative**: "today", "tomorrow", "yesterday"
- **Relative with time**: "tomorrow 3pm", "today at 5:30"
- **Duration**: "in 2 hours", "in 3 days", "in 1 week"
- **Weekdays**: "next Monday", "Friday at 5pm"
- **Absolute**: "2024-12-25", "December 25th at 3:30pm"
- **NSDataDetector**: Falls back to system date detection

### Implementation Details
- Uses NSDataDetector for complex date parsing
- Differentiates between date-only and date-time based on input
- Returns DateComponents for EventKit integration
- Handles timezone and calendar locale automatically

## Testing and Debugging

### Manual Testing Strategy
```bash
# Test basic functionality
ireminder show-lists
ireminder show-lists --json

# Test reminder operations
ireminder add "Test List" "Sample reminder"
ireminder show "Test List"
ireminder complete "Test List" 0
ireminder show "Test List" --include-completed

# Test date parsing
ireminder add "Test List" "Due tomorrow" --due-date "tomorrow 3pm"
ireminder add "Test List" "Due next week" --due-date "next Monday"

# Test JSON output
ireminder show "Test List" --json
```

### Common Issues and Solutions
1. **Permission Denied**: Ensure Reminders access granted in System Preferences
2. **List Not Found**: Check list name spelling and case-insensitivity
3. **Invalid Date**: Test date strings with DateParser examples
4. **Index Out of Range**: Verify reminder count with `show` command first

### Debug Output
Enable debug output by modifying the Reminders class:
```swift
// Add debug prints for troubleshooting
print("DEBUG: Found \(reminders.count) reminders", to: &standardError)
```

## Platform Requirements

- **macOS**: 13.0+ (Ventura or later)
- **Swift**: 6.1+ (uses StrictConcurrency)
- **Dependencies**: swift-argument-parser 1.2.0+
- **Permissions**: EventKit Reminders access required

## Integration Notes

### Related Projects
This project is part of a larger ecosystem including:
- **RemindersSync**: Bidirectional sync between Obsidian and Apple Reminders
- Both projects share EventKit integration patterns and date handling

### Shared Patterns
- EventKit permission handling using semaphores
- DateComponents for cross-platform date representation
- Error handling with standardError stream
- UUID-based ID management (in RemindersSync)

### Key Differences
- iReminderCLI focuses on direct CLI interaction
- RemindersSync handles file-based synchronization
- Different date parsing needs (CLI vs file formats)

## Development Best Practices

1. **Always test permission handling** - EventKit requires user consent
2. **Validate user input** - Check list existence before operations
3. **Use consistent error messages** - Follow established patterns
4. **Support both human and machine output** - JSON flag where applicable
5. **Handle edge cases** - Empty lists, invalid dates, missing reminders
6. **Follow Swift concurrency** - Use proper async/await patterns when available

## Future Enhancement Areas

1. **Testing Framework**: Add XCTest unit tests for utilities
2. **Configuration File**: Support for default lists and preferences
3. **Bulk Operations**: Import/export functionality
4. **Advanced Filtering**: Tag-based filtering, search functionality
5. **Synchronization**: Integration with external task management systems
6. **Notifications**: Local notification support for due reminders

## File Structure Reference

```
Sources/iReminderCLI/
├── iReminderCLI.swift          # Main entry point and command configuration
├── Reminders.swift             # Core EventKit integration
├── Commands/                   # Individual command implementations
│   ├── Add.swift              # Add new reminders
│   ├── Complete.swift         # Mark reminders complete
│   ├── Delete.swift           # Delete reminders
│   ├── Edit.swift             # Edit existing reminders
│   ├── NewList.swift          # Create new lists
│   ├── Show.swift             # Show reminders in specific list
│   ├── ShowAll.swift          # Show reminders from all lists
│   ├── ShowLists.swift        # List all reminder lists
│   └── Uncomplete.swift       # Mark reminders incomplete
└── Utilities/                  # Shared utility functions
    ├── DateFormatting.swift   # Date display formatting
    ├── DateParser.swift       # Natural language date parsing
    ├── ReminderFinder.swift   # Search and indexing utilities
    └── ReminderFormatting.swift # Reminder display and JSON formatting
```