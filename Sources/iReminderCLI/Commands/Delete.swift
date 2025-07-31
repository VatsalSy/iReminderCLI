import ArgumentParser
import Foundation

struct Delete: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "delete",
    abstract: "Delete a reminder"
  )
  
  @Argument(help: "The name of the reminder list")
  var listName: String
  
  @Argument(help: "The reminder index or ID")
  var identifier: String
  
  @Flag(name: .long, help: "Include completed reminders when searching by index")
  var includeCompleted = false
  
  mutating func run() throws {
    let reminders = Reminders()
    
    guard let list = reminders.getList(withName: listName) else {
      print("List '\(listName)' not found.", to: &standardError)
      throw ExitCode.failure
    }
    
    guard let reminder = reminders.findReminder(in: list, by: identifier, includeCompleted: includeCompleted) else {
      print("Reminder '\(identifier)' not found in list '\(listName)'.", to: &standardError)
      throw ExitCode.failure
    }
    
    let title = reminder.title ?? "Untitled"
    
    do {
      try reminders.deleteReminder(reminder)
      print("Deleted reminder: \(title)")
    } catch {
      print("Failed to delete reminder: \(error.localizedDescription)", to: &standardError)
      throw ExitCode.failure
    }
  }
}