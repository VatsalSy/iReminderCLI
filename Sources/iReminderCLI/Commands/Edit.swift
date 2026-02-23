import ArgumentParser
import EventKit
import Foundation

struct Edit: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "edit",
    abstract: "Edit an existing reminder"
  )
  
  @Argument(help: "The name of the reminder list")
  var listName: String
  
  @Argument(help: "The reminder index or ID")
  var identifier: String
  
  @Argument(help: "The new reminder text")
  var text: String?
  
  @Option(name: .long, help: "New notes for the reminder")
  var notes: String?

  @Option(name: .long, help: "New due date (e.g., 'today', 'tomorrow 3pm', 'next Monday')")
  var dueDate: String?

  @Flag(name: .long, help: "Clear the existing due date")
  var clearDueDate = false
  
  mutating func run() throws {
    let reminders = Reminders()
    
    guard let list = reminders.getList(withName: listName) else {
      print("List '\(listName)' not found.", to: &standardError)
      throw ExitCode.failure
    }
    
    guard let reminder = reminders.findReminder(in: list, by: identifier) else {
      print("Reminder '\(identifier)' not found in list '\(listName)'.", to: &standardError)
      throw ExitCode.failure
    }
    
    var newDueDateComponents: DateComponents?
    if let dueDateString = dueDate {
      let parser = DateParser()
      guard let parsedComponents = parser.parseToComponents(dueDateString) else {
        print("Invalid date format: '\(dueDateString)'", to: &standardError)
        throw ExitCode.failure
      }
      newDueDateComponents = parsedComponents
    }
    
    if let newText = text {
      reminder.title = newText
    }
    
    if let newNotes = notes {
      reminder.notes = newNotes
    }

    if clearDueDate {
      reminder.dueDateComponents = nil
      reminder.alarms = nil
    }

    if let dueDateComponents = newDueDateComponents {
      reminder.dueDateComponents = dueDateComponents
      reminder.alarms = nil

      if dueDateComponents.hour != nil || dueDateComponents.minute != nil {
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        let fallbackDate = calendar.date(from: DateComponents(
          year: dueDateComponents.year ?? currentComponents.year,
          month: dueDateComponents.month ?? currentComponents.month,
          day: dueDateComponents.day ?? currentComponents.day,
          hour: dueDateComponents.hour,
          minute: dueDateComponents.minute
        ))

        if let alarmDate = dueDateComponents.date ?? fallbackDate {
          reminder.addAlarm(EKAlarm(absoluteDate: alarmDate))
        }
      }
    }
    
    do {
      try reminders.updateReminder(reminder)
      print("Reminder updated successfully.")
    } catch {
      print("Failed to update reminder: \(error.localizedDescription)", to: &standardError)
      throw ExitCode.failure
    }
  }
}
