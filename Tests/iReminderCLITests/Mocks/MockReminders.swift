import Foundation
import EventKit
@testable import iReminderCLI

protocol RemindersProtocol {
  func getList(withName name: String) -> EKCalendar?
  func getSources() -> [MockEKSource]
  func createList(name: String, source: MockEKSource?) throws -> EKCalendar
}

class MockReminders: RemindersProtocol {
  var existingLists: [String] = []
  var availableSources: [MockEKSource] = []
  var shouldThrowOnCreate = false
  var createListCalled = false
  var lastCreatedListName: String?
  var lastCreatedListSource: MockEKSource?
  
  func getList(withName name: String) -> EKCalendar? {
    if existingLists.contains(where: { $0.lowercased() == name.lowercased() }) {
      let calendar = EKCalendar(for: .reminder, eventStore: EKEventStore())
      calendar.title = name
      return calendar
    }
    return nil
  }
  
  func getSources() -> [MockEKSource] {
    return availableSources
  }
  
  func createList(name: String, source: MockEKSource?) throws -> EKCalendar {
    createListCalled = true
    lastCreatedListName = name
    lastCreatedListSource = source
    
    if shouldThrowOnCreate {
      throw MockError.createListFailed
    }
    
    let calendar = EKCalendar(for: .reminder, eventStore: EKEventStore())
    calendar.title = name
    return calendar
  }
}

// Mock EKSource - we can't subclass EKSource directly as it's a cluster class
// Instead, we'll create a wrapper that behaves like an EKSource for testing
class MockEKSource {
  let title: String
  let sourceType: EKSourceType
  let sourceIdentifier: String
  
  init(title: String, sourceType: EKSourceType = .local) {
    self.title = title
    self.sourceType = sourceType
    self.sourceIdentifier = UUID().uuidString
  }
}

enum MockError: Error, LocalizedError {
  case createListFailed
  
  var errorDescription: String? {
    switch self {
    case .createListFailed:
      return "Failed to create list"
    }
  }
}