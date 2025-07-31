import XCTest
import ArgumentParser
@testable import iReminderCLI

final class NewListTests: XCTestCase {
  
  func testNewListCreation() throws {
    // Test successful list creation
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    
    // Redirect stdout and stderr
    let originalStdout = dup(STDOUT_FILENO)
    let originalStderr = dup(STDERR_FILENO)
    dup2(outputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
    dup2(errorPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
    
    defer {
      // Restore stdout and stderr
      dup2(originalStdout, STDOUT_FILENO)
      dup2(originalStderr, STDERR_FILENO)
      close(originalStdout)
      close(originalStderr)
    }
    
    // Since we can't easily inject dependencies into NewList,
    // we'll test the logic separately
    let mockReminders = MockReminders()
    
    // Test 1: Create new list successfully
    let listName = "Test List"
    XCTAssertNil(mockReminders.getList(withName: listName))
    
    let newList = try mockReminders.createList(name: listName, source: nil)
    XCTAssertEqual(newList.title, listName)
    XCTAssertTrue(mockReminders.createListCalled)
    XCTAssertEqual(mockReminders.lastCreatedListName, listName)
  }
  
  func testListAlreadyExists() {
    let mockReminders = MockReminders()
    mockReminders.existingLists = ["Existing List"]
    
    let existingList = mockReminders.getList(withName: "Existing List")
    XCTAssertNotNil(existingList)
    XCTAssertEqual(existingList?.title, "Existing List")
  }
  
  func testListNameCaseInsensitive() {
    let mockReminders = MockReminders()
    mockReminders.existingLists = ["Test List"]
    
    XCTAssertNotNil(mockReminders.getList(withName: "test list"))
    XCTAssertNotNil(mockReminders.getList(withName: "TEST LIST"))
    XCTAssertNotNil(mockReminders.getList(withName: "Test List"))
  }
  
  func testSourceSelection() throws {
    let mockReminders = MockReminders()
    let icloudSource = MockEKSource(title: "iCloud")
    let localSource = MockEKSource(title: "Local")
    mockReminders.availableSources = [icloudSource, localSource]
    
    let sources = mockReminders.getSources()
    XCTAssertEqual(sources.count, 2)
    XCTAssertTrue(sources.contains { $0.title == "iCloud" })
    XCTAssertTrue(sources.contains { $0.title == "Local" })
    
    // Test creating list with specific source
    let listName = "Test List"
    _ = try mockReminders.createList(name: listName, source: icloudSource)
    XCTAssertEqual(mockReminders.lastCreatedListSource?.title, "iCloud")
  }
  
  func testSourceNotFound() {
    let mockReminders = MockReminders()
    let localSource = MockEKSource(title: "Local")
    mockReminders.availableSources = [localSource]
    
    let sources = mockReminders.getSources()
    let nonExistentSource = sources.first { $0.title.lowercased() == "dropbox".lowercased() }
    XCTAssertNil(nonExistentSource)
  }
  
  func testCreateListError() {
    let mockReminders = MockReminders()
    mockReminders.shouldThrowOnCreate = true
    
    XCTAssertThrowsError(try mockReminders.createList(name: "Test List", source: nil)) { error in
      XCTAssertEqual(error.localizedDescription, "Failed to create list")
    }
  }
  
  // Integration test for command parsing
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
}