import ArgumentParser
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
    
    if text == nil && notes == nil {
      print("Nothing to update. Provide new text or notes.", to: &standardError)
      throw ExitCode.failure
    }
    
    if let newText = text {
      reminder.title = newText
    }
    
    if let newNotes = notes {
      reminder.notes = newNotes
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