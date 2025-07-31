import Foundation
import EventKit
@testable import iReminderCLI

protocol RemindersProtocol {
  func getList(withName name: String) -> EKCalendar?
  func getSources() -> [EKSource]
  func createList(name: String, source: EKSource?) throws -> EKCalendar
}

class MockReminders: RemindersProtocol {
  var existingLists: [String] = []
  var availableSources: [MockEKSource] = []
  var shouldThrowOnCreate = false
  var createListCalled = false
  var lastCreatedListName: String?
  var lastCreatedListSource: EKSource?
  
  func getList(withName name: String) -> EKCalendar? {
    if existingLists.contains(where: { $0.lowercased() == name.lowercased() }) {
      let calendar = EKCalendar(for: .reminder, eventStore: EKEventStore())
      calendar.title = name
      return calendar
    }
    return nil
  }
  
  func getSources() -> [EKSource] {
    return availableSources
  }
  
  func createList(name: String, source: EKSource?) throws -> EKCalendar {
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

class MockEKSource: EKSource {
  private let _title: String
  
  init(title: String) {
    self._title = title
    super.init()
  }
  
  override var title: String {
    return _title
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