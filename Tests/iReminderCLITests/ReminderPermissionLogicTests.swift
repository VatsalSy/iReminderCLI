import XCTest
import EventKit
@testable import iReminderCLI

final class ReminderPermissionLogicTests: XCTestCase {
  func testLegacyStatusRequiresAuthorized() {
    XCTAssertTrue(Reminders.hasReminderAccess(.authorized))
    XCTAssertFalse(Reminders.hasReminderAccess(.denied))
    XCTAssertFalse(Reminders.hasReminderAccess(.restricted))

    XCTAssertTrue(Reminders.shouldRequestReminderAccess(.notDetermined))
    XCTAssertFalse(Reminders.shouldRequestReminderAccess(.denied))
    XCTAssertFalse(Reminders.shouldRequestReminderAccess(.restricted))
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
