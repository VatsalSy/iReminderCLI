import EventKit
import Foundation

class Reminders {
  private let store = EKEventStore()
  private var accessGranted = false
  
  init() {
    requestAccess()
  }
  
  private func requestAccess() {
    let semaphore = DispatchSemaphore(value: 0)
    
    if #available(macOS 14.0, *) {
      store.requestFullAccessToReminders { granted, error in
        self.accessGranted = granted
        if let error = error {
          print("Error requesting access: \(error.localizedDescription)", to: &standardError)
        }
        semaphore.signal()
      }
    } else {
      store.requestAccess(to: .reminder) { granted, error in
        self.accessGranted = granted
        if let error = error {
          print("Error requesting access: \(error.localizedDescription)", to: &standardError)
        }
        semaphore.signal()
      }
    }
    
    semaphore.wait()
    
    if !accessGranted {
      print("Access to Reminders denied. Please grant access in System Preferences.", to: &standardError)
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