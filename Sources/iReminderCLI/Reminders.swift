import EventKit
import Foundation
import os

class Reminders {
  private let store = EKEventStore()
  private var accessGranted = false
  
  init() {
    requestAccess()
  }

  private func hasReminderUsageDescription() -> Bool {
    if #available(macOS 14.0, *) {
      let fullAccess = Bundle.main.object(forInfoDictionaryKey: "NSRemindersFullAccessUsageDescription") as? String
      let legacyAccess = Bundle.main.object(forInfoDictionaryKey: "NSRemindersUsageDescription") as? String
      return !(fullAccess?.isEmpty ?? true) || !(legacyAccess?.isEmpty ?? true)
    }

    let legacyAccess = Bundle.main.object(forInfoDictionaryKey: "NSRemindersUsageDescription") as? String
    return !(legacyAccess?.isEmpty ?? true)
  }

  private func hasReminderAccess(_ status: EKAuthorizationStatus) -> Bool {
    if #available(macOS 14.0, *) {
      return status == .fullAccess || status == .writeOnly
    }

    return status == .authorized
  }

  private static func reportRequestError(_ error: Error) {
    let nsError = error as NSError
    print(
      "Failed to request Reminders access (\(nsError.domain) code \(nsError.code)): \(nsError.localizedDescription)",
      to: &standardError
    )
  }

  private func printAccessDeniedGuidance() {
    print("Access to Reminders denied.", to: &standardError)
    print(
      "Grant access for your terminal app in System Settings > Privacy & Security > Reminders.",
      to: &standardError
    )
    print("If you previously denied access, reset and retry:", to: &standardError)
    print("  tccutil reset Reminders", to: &standardError)
  }
  
  private func requestAccess() {
    if !hasReminderUsageDescription() {
      print(
        "This build is missing NSReminders usage description metadata required by macOS.",
        to: &standardError
      )
      print("Rebuild iReminderCLI from source and reinstall.", to: &standardError)
      exit(1)
    }

    let currentStatus = EKEventStore.authorizationStatus(for: .reminder)
    if hasReminderAccess(currentStatus) {
      accessGranted = true
      return
    }

    if currentStatus != .notDetermined {
      printAccessDeniedGuidance()
      exit(1)
    }

    let semaphore = DispatchSemaphore(value: 0)
    let grantedAccess = OSAllocatedUnfairLock(initialState: false)
    
    if #available(macOS 14.0, *) {
      store.requestFullAccessToReminders { granted, error in
        grantedAccess.withLock { $0 = granted }
        if let error = error {
          Self.reportRequestError(error)
        }
        semaphore.signal()
      }
    } else {
      store.requestAccess(to: .reminder) { granted, error in
        grantedAccess.withLock { $0 = granted }
        if let error = error {
          Self.reportRequestError(error)
        }
        semaphore.signal()
      }
    }
    
    semaphore.wait()
    self.accessGranted = grantedAccess.withLock { $0 }
    
    if !accessGranted {
      printAccessDeniedGuidance()
      exit(1)
    }
  }
  
  func getLists() -> [EKCalendar] {
    return store.calendars(for: .reminder).filter { $0.allowsContentModifications }
  }
  
  func getList(withName name: String) -> EKCalendar? {
    return getLists().first { $0.title.lowercased() == name.lowercased() }
  }
  
  func getReminders(
    from list: EKCalendar? = nil,
    includeCompleted: Bool = false,
    onlyCompleted: Bool = false,
    dueDate: Date? = nil
  ) -> [EKReminder] {
    let semaphore = DispatchSemaphore(value: 0)
    var reminders: [EKReminder] = []
    
    let calendars = list != nil ? [list!] : getLists()
    let predicate = store.predicateForReminders(in: calendars)
    
    store.fetchReminders(matching: predicate) { foundReminders in
      reminders = foundReminders ?? []
      semaphore.signal()
    }
    
    semaphore.wait()
    
    if !includeCompleted && !onlyCompleted {
      reminders = reminders.filter { !$0.isCompleted }
    } else if onlyCompleted {
      reminders = reminders.filter { $0.isCompleted }
    }
    
    if let dueDate = dueDate {
      let calendar = Calendar.current
      reminders = reminders.filter { reminder in
        guard let reminderDueDate = reminder.dueDateComponents?.date else { return false }
        return calendar.isDate(reminderDueDate, inSameDayAs: dueDate)
      }
    }
    
    return reminders
  }
  
  func addReminder(
    to list: EKCalendar,
    title: String,
    notes: String? = nil,
    dueDate: DateComponents? = nil,
    priority: Int = 0
  ) throws {
    let reminder = EKReminder(eventStore: store)
    reminder.calendar = list
    reminder.title = title
    reminder.notes = notes
    reminder.priority = priority
    
    if let dueDate = dueDate {
      reminder.dueDateComponents = dueDate
      if dueDate.hour != nil || dueDate.minute != nil {
        reminder.addAlarm(EKAlarm(absoluteDate: dueDate.date!))
      }
    }
    
    try store.save(reminder, commit: true)
  }
  
  func updateReminder(_ reminder: EKReminder) throws {
    try store.save(reminder, commit: true)
  }
  
  func deleteReminder(_ reminder: EKReminder) throws {
    try store.remove(reminder, commit: true)
  }
  
  func createList(name: String, source: EKSource? = nil) throws -> EKCalendar {
    let calendar = EKCalendar(for: .reminder, eventStore: store)
    calendar.title = name
    
    if let source = source {
      calendar.source = source
    } else {
      calendar.source = store.defaultCalendarForNewReminders()?.source ?? store.sources.first!
    }
    
    try store.saveCalendar(calendar, commit: true)
    return calendar
  }
  
  func getSources() -> [EKSource] {
    return store.sources
  }
}

nonisolated(unsafe) var standardError = FileHandle.standardError

extension FileHandle: @retroactive TextOutputStream {
  public func write(_ string: String) {
    guard let data = string.data(using: .utf8) else { return }
    self.write(data)
  }
}
