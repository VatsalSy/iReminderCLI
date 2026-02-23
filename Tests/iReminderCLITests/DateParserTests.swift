import XCTest
@testable import iReminderCLI

final class DateParserTests: XCTestCase {
  func testParseToComponentsWithTimeIncludesHourAndMinute() {
    let parser = DateParser()

    guard let components = parser.parseToComponents("2026-05-21 18:00") else {
      XCTFail("Expected parser to return date components for a valid date-time string")
      return
    }

    XCTAssertNotNil(components.year)
    XCTAssertNotNil(components.month)
    XCTAssertNotNil(components.day)
    XCTAssertNotNil(components.hour)
    XCTAssertNotNil(components.minute)
  }

  func testParseToComponentsRelativeHoursIncludesTime() {
    let parser = DateParser()

    guard let inTwoHours = parser.parseToComponents("in 2 hours") else {
      XCTFail("Expected parser to return date components for 'in 2 hours'")
      return
    }

    XCTAssertNotNil(inTwoHours.hour)
    XCTAssertNotNil(inTwoHours.minute)

    guard let inThirtyMinutes = parser.parseToComponents("in 30 minutes") else {
      XCTFail("Expected parser to return date components for 'in 30 minutes'")
      return
    }

    XCTAssertNotNil(inThirtyMinutes.hour)
    XCTAssertNotNil(inThirtyMinutes.minute)
  }

  func testEditParseSucceedsForRunLevelValidationCases() throws {
    XCTAssertNoThrow(try Edit.parse(["Shopping", "0"]))
    XCTAssertNoThrow(try Edit.parse(["Shopping", "0", "--due-date", "tomorrow", "--clear-due-date"]))
  }

  func testParseToComponentsDateOnlyOmitsTime() {
    let parser = DateParser()

    guard let components = parser.parseToComponents("tomorrow") else {
      XCTFail("Expected parser to return date components for 'tomorrow'")
      return
    }

    XCTAssertNotNil(components.year)
    XCTAssertNotNil(components.month)
    XCTAssertNotNil(components.day)
    XCTAssertNil(components.hour)
    XCTAssertNil(components.minute)
  }
}
