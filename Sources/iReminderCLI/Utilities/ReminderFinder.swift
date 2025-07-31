import EventKit
import Foundation

extension Reminders {
  func findReminder(in list: EKCalendar, by identifier: String, includeCompleted: Bool = false) -> EKReminder? {
    let allReminders = getReminders(from: list, includeCompleted: includeCompleted)
    
    if let index = Int(identifier) {
      let incompleteReminders = includeCompleted ? allReminders : allReminders.filter { !$0.isCompleted }
      guard index >= 0 && index < incompleteReminders.count else { return nil }
      return incompleteReminders[index]
    } else {
      return allReminders.first { $0.calendarItemIdentifier == identifier }
    }
  }
}