import ArgumentParser
import Foundation

struct Uncomplete: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "uncomplete",
    abstract: "Mark a reminder as not completed"
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
    
    guard let reminder = reminders.findReminder(in: list, by: identifier, includeCompleted: true) else {
      print("Reminder '\(identifier)' not found in list '\(listName)'.", to: &standardError)
      throw ExitCode.failure
    }
    
    if !reminder.isCompleted {
      print("Reminder is already uncompleted.")
      return
    }
    
    reminder.isCompleted = false
    reminder.completionDate = nil
    
    do {
      try reminders.updateReminder(reminder)
      print("Reminder marked as uncompleted.")
    } catch {
      print("Failed to update reminder: \(error.localizedDescription)", to: &standardError)
      throw ExitCode.failure
    }
  }
}