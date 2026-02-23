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
