import ArgumentParser
import EventKit
import Foundation

@main
struct IReminderCLI: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "ireminder",
    abstract: "A command-line tool to manage Apple Reminders",
    version: "1.0.0",
    subcommands: [
      ShowLists.self,
      Show.self,
      ShowAll.self,
      Add.self,
      Complete.self,
      Uncomplete.self,
      Edit.self,
      Delete.self,
      NewList.self
    ]
  )
}