import ArgumentParser
import Foundation

struct Complete: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "complete",
    abstract: "Mark a reminder as completed"
  )
  
  @Argument(help: "The name of the reminder list")
  var listName: String
  
  @Argument(help: "The reminder index or ID")
  var identifier: String
  
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
    
    if reminder.isCompleted {
      print("Reminder is already completed.")
      return
    }
    
    reminder.isCompleted = true
    reminder.completionDate = Date()
    
    do {
      try reminders.updateReminder(reminder)
      print("Reminder marked as completed.")
    } catch {
      print("Failed to update reminder: \(error.localizedDescription)", to: &standardError)
      throw ExitCode.failure
    }
  }
}