import XCTest
import ArgumentParser
import EventKit
@testable import iReminderCLI

final class NewListTests: XCTestCase {
  
  // MARK: - Mock Functionality Tests
  
  func testMockRemindersCreateList() throws {
    let mockReminders = MockReminders()
    mockReminders.availableSources = [
      MockSource(title: "iCloud", sourceType: .calDAV),
      MockSource(title: "Local", sourceType: .local)
    ]
    
    // Test successful list creation
    let calendar = try mockReminders.createList(name: "Test List", sourceTitle: nil)
    XCTAssertEqual(calendar.title, "Test List")
    XCTAssertTrue(mockReminders.createListCalled)
    XCTAssertEqual(mockReminders.lastCreatedListName, "Test List")
    XCTAssertNil(mockReminders.lastCreatedListSourceTitle)
    
    // Save the list
    try mockReminders.saveList(calendar)
    XCTAssertTrue(mockReminders.saveListCalled)
    
    // Verify it exists
    let foundList = mockReminders.getList(withName: "Test List")
    XCTAssertNotNil(foundList)
    XCTAssertEqual(foundList?.title, "Test List")
  }
  
  func testMockRemindersCreateListWithSource() throws {
    let mockReminders = MockReminders()
    mockReminders.availableSources = [
      MockSource(title: "iCloud", sourceType: .calDAV),
      MockSource(title: "Local", sourceType: .local)
    ]
    
    // Create with specific source
    let calendar = try mockReminders.createList(name: "Cloud List", sourceTitle: "iCloud")
    XCTAssertEqual(calendar.title, "Cloud List")
    XCTAssertEqual(mockReminders.lastCreatedListSourceTitle, "iCloud")
  }
  
  func testMockRemindersListAlreadyExists() {
    let mockReminders = MockReminders()
    mockReminders.addMockList("Existing List")
    
    let existingList = mockReminders.getList(withName: "Existing List")
    XCTAssertNotNil(existingList)
    XCTAssertEqual(existingList?.title, "Existing List")
    
    // Test case insensitive
    XCTAssertNotNil(mockReminders.getList(withName: "existing list"))
    XCTAssertNotNil(mockReminders.getList(withName: "EXISTING LIST"))
  }
  
  func testMockRemindersGetAllLists() {
    let mockReminders = MockReminders()
    mockReminders.addMockList("List 1")
    mockReminders.addMockList("List 2")
    mockReminders.addMockList("List 3")
    
    let lists = mockReminders.getLists()
    XCTAssertEqual(lists.count, 3)
    XCTAssertTrue(lists.contains { $0.title == "List 1" })
    XCTAssertTrue(lists.contains { $0.title == "List 2" })
    XCTAssertTrue(lists.contains { $0.title == "List 3" })
  }
  
  func testMockRemindersCreateListError() {
    let mockReminders = MockReminders()
    mockReminders.shouldThrowOnCreate = true
    
    XCTAssertThrowsError(try mockReminders.createList(name: "Test List", sourceTitle: nil)) { error in
      XCTAssertEqual(error.localizedDescription, "Failed to create list")
    }
  }
  
  func testMockRemindersSaveListError() {
    let mockReminders = MockReminders()
    mockReminders.shouldThrowOnSave = true
    
    let calendar = EKCalendar(for: .reminder, eventStore: EKEventStore())
    calendar.title = "Test List"
    
    XCTAssertThrowsError(try mockReminders.saveList(calendar)) { error in
      XCTAssertEqual(error.localizedDescription, "Failed to save list")
    }
  }
  
  func testMockRemindersSourceNotFound() {
    let mockReminders = MockReminders()
    mockReminders.availableSources = [
      MockSource(title: "Local", sourceType: .local)
    ]
    
    XCTAssertThrowsError(try mockReminders.createList(name: "Test", sourceTitle: "iCloud")) { error in
      XCTAssertEqual(error.localizedDescription, "Source not found")
    }
  }
  
  // MARK: - Command Parsing Tests
  
  func testCommandParsing() throws {
    var command = try NewList.parse(["Test List"])
    XCTAssertEqual(command.name, "Test List")
    XCTAssertNil(command.source)
    
    command = try NewList.parse(["Another List", "--source", "iCloud"])
    XCTAssertEqual(command.name, "Another List")
    XCTAssertEqual(command.source, "iCloud")
  }
  
  func testCommandParsingErrors() {
    // Test missing required argument
    XCTAssertThrowsError(try NewList.parse([])) { error in
      // ArgumentParser throws its own error types
      // We just verify that parsing fails when arguments are missing
      XCTAssertNotNil(error)
    }
    
    // Test too many arguments
    XCTAssertThrowsError(try NewList.parse(["List1", "List2"])) { error in
      // ArgumentParser throws its own error types
      // We just verify that parsing fails with unexpected arguments
      XCTAssertNotNil(error)
    }
  }
  
  // MARK: - Logic Tests
  
  func testNewListLogic() throws {
    // These tests verify the business logic without executing the actual command
    let mockReminders = MockReminders()
    
    // Test 1: Can't create duplicate list
    mockReminders.addMockList("Shopping")
    XCTAssertNotNil(mockReminders.getList(withName: "Shopping"))
    
    // Test 2: Available sources
    mockReminders.availableSources = [
      MockSource(title: "iCloud", sourceType: .calDAV),
      MockSource(title: "Local", sourceType: .local),
      MockSource(title: "Exchange", sourceType: .exchange)
    ]
    
    let sources = mockReminders.getSources()
    XCTAssertEqual(sources.count, 3)
    XCTAssertTrue(sources.contains { $0.title == "iCloud" })
    XCTAssertTrue(sources.contains { $0.title == "Local" })
    XCTAssertTrue(sources.contains { $0.title == "Exchange" })
  }
}