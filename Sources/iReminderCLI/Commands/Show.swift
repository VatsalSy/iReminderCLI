import ArgumentParser
import Foundation

struct Show: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "show",
    abstract: "Show reminders in a specific list"
  )
  
  @Argument(help: "The name of the reminder list")
  var listName: String
  
  @Flag(name: .long, help: "Include completed reminders")
  var includeCompleted = false
  
  @Flag(name: .long, help: "Show only completed reminders")
  var onlyCompleted = false
  
  @Option(name: .long, help: "Filter by due date (e.g., 'today', 'tomorrow', '2023-12-25')")
  var dueDate: String?
  
  @Flag(name: .shortAndLong, help: "Output in JSON format")
  var json = false
  
  @Option(name: .long, help: "Sort by: due-date or creation-date")
  var sortBy: String = "due-date"
  
  mutating func run() throws {
    let reminders = Reminders()
    
    guard let list = reminders.getList(withName: listName) else {
      print("List '\(listName)' not found.", to: &standardError)
      throw ExitCode.failure
    }
    
    var filterDate: Date?
    if let dueDateString = dueDate {
      let parser = DateParser()
      guard let parsedDate = parser.parse(dueDateString) else {
        print("Invalid date format: '\(dueDateString)'", to: &standardError)
        throw ExitCode.failure
      }
      filterDate = parsedDate
    }
    
    var reminderList = reminders.getReminders(
      from: list,
      includeCompleted: includeCompleted,
      onlyCompleted: onlyCompleted,
      dueDate: filterDate
    )
    
    if sortBy == "due-date" {
      reminderList.sort { r1, r2 in
        guard let d1 = r1.dueDateComponents?.date else { return false }
        guard let d2 = r2.dueDateComponents?.date else { return true }
        return d1 < d2
      }
    } else if sortBy == "creation-date" {
      reminderList.sort { r1, r2 in
        guard let d1 = r1.creationDate else { return false }
        guard let d2 = r2.creationDate else { return true }
        return d1 < d2
      }
    }
    
    if json {
      let outputs = reminderList.enumerated().map { index, reminder in
        ReminderOutput(reminder: reminder, index: index).toDictionary()
      }
      let jsonData = try JSONSerialization.data(withJSONObject: outputs, options: .prettyPrinted)
      print(String(data: jsonData, encoding: .utf8)!)
    } else {
      if reminderList.isEmpty {
        print("No reminders found.")
      } else {
        for (index, reminder) in reminderList.enumerated() {
          let output = ReminderOutput(reminder: reminder, index: index)
          print(output.formatForDisplay())
        }
      }
    }
  }
}