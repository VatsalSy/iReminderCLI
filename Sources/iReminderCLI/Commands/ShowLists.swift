import ArgumentParser
import Foundation

struct ShowLists: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "show-lists",
    abstract: "Show all reminder lists"
  )
  
  @Flag(name: .shortAndLong, help: "Output in JSON format")
  var json = false
  
  mutating func run() throws {
    let reminders = Reminders()
    let lists = reminders.getLists()
    
    if json {
      let jsonData = try JSONSerialization.data(withJSONObject: lists.map { ["name": $0.title] })
      print(String(data: jsonData, encoding: .utf8)!)
    } else {
      if lists.isEmpty {
        print("No reminder lists found.")
      } else {
        for list in lists {
          print(list.title)
        }
      }
    }
  }
}