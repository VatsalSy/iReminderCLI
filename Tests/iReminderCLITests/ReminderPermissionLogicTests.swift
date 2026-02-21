import XCTest
import EventKit
@testable import iReminderCLI

final class ReminderPermissionLogicTests: XCTestCase {
  func testLegacyStatusRequiresAuthorized() {
    XCTAssertTrue(Reminders.hasReminderAccess(.authorized))
    XCTAssertTrue(Reminders.shouldRequestReminderAccess(.notDetermined))
    XCTAssertFalse(Reminders.shouldRequestReminderAccess(.denied))
  }

  @available(macOS 14.0, *)
  func testSonomaStatusRequiresFullAccess() {
    XCTAssertTrue(Reminders.hasReminderAccess(.fullAccess))
    XCTAssertFalse(Reminders.hasReminderAccess(.writeOnly))

    XCTAssertTrue(Reminders.shouldRequestReminderAccess(.notDetermined))
    XCTAssertTrue(Reminders.shouldRequestReminderAccess(.writeOnly))
    XCTAssertFalse(Reminders.shouldRequestReminderAccess(.denied))
    XCTAssertFalse(Reminders.shouldRequestReminderAccess(.restricted))
  }
}
