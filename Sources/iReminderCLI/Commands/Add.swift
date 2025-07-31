import ArgumentParser
import Foundation
import EventKit

struct Add: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "add",
    abstract: "Add a new reminder to a list"
  )
  
  @Argument(help: "The name of the reminder list")
  var listName: String
  
  @Argument(help: "The reminder text")
  var text: String
  
  @Option(name: .long, help: "Due date (e.g., 'today', 'tomorrow 3pm', 'next Monday')")
  var dueDate: String?
  
  @Option(name: .long, help: "Priority level (0-3, where 3 is highest)")
  var priority: Int = 0
  
  @Option(name: .long, help: "Additional notes for the reminder")
  var notes: String?
  
  mutating func run() throws {
    let reminders = Reminders()
    
    guard let list = reminders.getList(withName: listName) else {
      print("List '\(listName)' not found.", to: &standardError)
      throw ExitCode.failure
    }
    
    var dueDateComponents: DateComponents?
    if let dueDateString = dueDate {
      let parser = DateParser()
      guard let components = parser.parseToComponents(dueDateString) else {
        print("Invalid date format: '\(dueDateString)'", to: &standardError)
        throw ExitCode.failure
      }
      dueDateComponents = components
    }
    
    let validPriority = max(0, min(3, priority))
    
    do {
      try reminders.addReminder(
        to: list,
        title: text,
        notes: notes,
        dueDate: dueDateComponents,
        priority: validPriority
      )
      print("Reminder added successfully.")
    } catch {
      print("Failed to add reminder: \(error.localizedDescription)", to: &standardError)
      throw ExitCode.failure
    }
  }
}