import ArgumentParser
import XCTest
@testable import iReminderCLI

final class EditCommandParsingTests: XCTestCase {
  func testEditParsesDueDateOption() throws {
    let command = try Edit.parse(["Shopping", "0", "--due-date", "tomorrow 3pm"])

    XCTAssertEqual(command.listName, "Shopping")
    XCTAssertEqual(command.identifier, "0")
    XCTAssertNil(command.text)
    XCTAssertNil(command.notes)
    XCTAssertEqual(command.dueDate, "tomorrow 3pm")
    XCTAssertFalse(command.clearDueDate)
  }

  func testEditParsesClearDueDateFlag() throws {
    let command = try Edit.parse(["Shopping", "7B6FF957-B117-4947-A3FD-E5ED1AFD859D", "--clear-due-date"])

    XCTAssertEqual(command.listName, "Shopping")
    XCTAssertEqual(command.identifier, "7B6FF957-B117-4947-A3FD-E5ED1AFD859D")
    XCTAssertNil(command.dueDate)
    XCTAssertTrue(command.clearDueDate)
  }

  func testEditParsesCombinedUpdates() throws {
    let command = try Edit.parse([
      "Work",
      "1",
      "Updated task",
      "--notes",
      "Need follow up",
      "--due-date",
      "next monday 9am"
    ])

    XCTAssertEqual(command.text, "Updated task")
    XCTAssertEqual(command.notes, "Need follow up")
    XCTAssertEqual(command.dueDate, "next monday 9am")
    XCTAssertFalse(command.clearDueDate)
  }

  func testEditParsingErrorsWhenRequiredArgumentsMissing() {
    XCTAssertThrowsError(try Edit.parse([]))
    XCTAssertThrowsError(try Edit.parse(["Shopping"]))
  }
}
