import Foundation
import EventKit
@testable import iReminderCLI

// Protocol for testable source - abstracts away EKSource details
protocol SourceProtocol {
  var title: String { get }
  var sourceIdentifier: String { get }
  var sourceType: EKSourceType { get }
}

// Protocol that mirrors the actual Reminders class interface
protocol RemindersProtocol {
  func getList(withName name: String) -> EKCalendar?
  func getLists() -> [EKCalendar]
  func getSources() -> [SourceProtocol]
  func createList(name: String, sourceTitle: String?) throws -> EKCalendar
  func saveList(_ calendar: EKCalendar) throws
}

// Mock implementation of a source
struct MockSource: SourceProtocol {
  let title: String
  let sourceIdentifier: String
  let sourceType: EKSourceType
  
  init(title: String, sourceType: EKSourceType = .local) {
    self.title = title
    self.sourceIdentifier = UUID().uuidString
    self.sourceType = sourceType
  }
}

// Mock implementation for testing
class MockReminders: RemindersProtocol {
  var existingLists: [String] = []
  var availableSources: [MockSource] = []
  var shouldThrowOnCreate = false
  var shouldThrowOnSave = false
  var createListCalled = false
  var saveListCalled = false
  var lastCreatedListName: String?
  var lastCreatedListSourceTitle: String?
  
  private var mockCalendars: [EKCalendar] = []
  
  func getList(withName name: String) -> EKCalendar? {
    return mockCalendars.first { $0.title.lowercased() == name.lowercased() }
  }
  
  func getLists() -> [EKCalendar] {
    return mockCalendars
  }
  
  func getSources() -> [SourceProtocol] {
    return availableSources
  }
  
  func createList(name: String, sourceTitle: String?) throws -> EKCalendar {
    createListCalled = true
    lastCreatedListName = name
    lastCreatedListSourceTitle = sourceTitle
    
    if shouldThrowOnCreate {
      throw MockError.createListFailed
    }
    
    // For testing, we need to create a mock calendar since we can't
    // create real EKCalendar objects without a real event store
    let calendar = EKCalendar(for: .reminder, eventStore: EKEventStore())
    calendar.title = name
    
    // Find the source if specified
    if let sourceTitle = sourceTitle {
      if availableSources.first(where: { $0.title.lowercased() == sourceTitle.lowercased() }) == nil {
        throw MockError.sourceNotFound
      }
    }
    
    return calendar
  }
  
  func saveList(_ calendar: EKCalendar) throws {
    saveListCalled = true
    
    if shouldThrowOnSave {
      throw MockError.saveListFailed
    }
    
    // Add to our mock storage
    mockCalendars.append(calendar)
  }
  
  // Helper method to pre-populate lists for testing
  func addMockList(_ name: String) {
    let calendar = EKCalendar(for: .reminder, eventStore: EKEventStore())
    calendar.title = name
    mockCalendars.append(calendar)
  }
}

enum MockError: Error, LocalizedError {
  case createListFailed
  case saveListFailed
  case sourceNotFound
  
  var errorDescription: String? {
    switch self {
    case .createListFailed:
      return "Failed to create list"
    case .saveListFailed:
      return "Failed to save list"
    case .sourceNotFound:
      return "Source not found"
    }
  }
}