import ArgumentParser
import Foundation
import EventKit

struct NewList: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "new-list",
    abstract: "Create a new reminder list"
  )
  
  @Argument(help: "The name of the new list")
  var name: String
  
  @Option(name: .long, help: "The source account (e.g., 'iCloud', 'Local')")
  var source: String?
  
  mutating func run() throws {
    let reminders = Reminders()
    
    if reminders.getList(withName: name) != nil {
      print("A list with the name '\(name)' already exists.", to: &standardError)
      throw ExitCode.failure
    }
    
    var selectedSource: EKSource?
    if let sourceName = source {
      let sources = reminders.getSources()
      selectedSource = sources.first { $0.title.lowercased() == sourceName.lowercased() }
      
      if selectedSource == nil {
        print("Source '\(sourceName)' not found. Available sources:", to: &standardError)
        for src in sources {
          print("  - \(src.title)", to: &standardError)
        }
        throw ExitCode.failure
      }
    }
    
    do {
      let newList = try reminders.createList(name: name, source: selectedSource)
      print("Created new list: \(newList.title)")
    } catch {
      print("Failed to create list: \(error.localizedDescription)", to: &standardError)
      throw ExitCode.failure
    }
  }
}