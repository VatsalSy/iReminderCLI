import ArgumentParser
import Foundation

struct ShowAll: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "show-all",
    abstract: "Show reminders from all lists"
  )
  
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
    
    var filterDate: Date?
    if let dueDateString = dueDate {
      let parser = DateParser()
      guard let parsedDate = parser.parse(dueDateString) else {
        print("Invalid date format: '\(dueDateString)'", to: &standardError)
        throw ExitCode.failure
      }
      filterDate = parsedDate
    }
    
    var allReminders = reminders.getReminders(
      includeCompleted: includeCompleted,
      onlyCompleted: onlyCompleted,
      dueDate: filterDate
    )
    
    if sortBy == "due-date" {
      allReminders.sort { r1, r2 in
        guard let d1 = r1.dueDateComponents?.date else { return false }
        guard let d2 = r2.dueDateComponents?.date else { return true }
        return d1 < d2
      }
    } else if sortBy == "creation-date" {
      allReminders.sort { r1, r2 in
        guard let d1 = r1.creationDate else { return false }
        guard let d2 = r2.creationDate else { return true }
        return d1 < d2
      }
    }
    
    if json {
      var outputs: [[String: Any]] = []
      
      for reminder in allReminders {
        let listName = reminder.calendar?.title ?? "Unknown"
        var dict = ReminderOutput(reminder: reminder, index: nil).toDictionary()
        dict["list"] = listName
        outputs.append(dict)
      }
      
      let jsonData = try JSONSerialization.data(withJSONObject: outputs, options: .prettyPrinted)
      print(String(data: jsonData, encoding: .utf8)!)
    } else {
      if allReminders.isEmpty {
        print("No reminders found.")
      } else {
        var currentList = ""
        
        for reminder in allReminders {
          let listName = reminder.calendar?.title ?? "Unknown"
          
          if listName != currentList {
            if !currentList.isEmpty { print() }
            print("=== \(listName) ===")
            currentList = listName
          }
          
          let output = ReminderOutput(reminder: reminder, index: nil)
          print(output.formatForDisplay())
        }
      }
    }
  }
}