import ArgumentParser
import EventKit
import Foundation

@main
struct IReminderCLI: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "ireminder",
    abstract: "Manage Apple Reminders from the command line",
    discussion: """
      Quick start:
        ireminder show-lists
        ireminder add "Inbox" "Follow up with design team" --due-date "tomorrow 10am"
        ireminder show "Inbox"

      Identifier guide:
        Commands like complete/edit/delete accept either:
        - index (0-based, from `ireminder show "LIST"` output like [0])
        - reminder ID string (from `ireminder show "LIST" --json` in the `id` field)

      Help:
        ireminder help <subcommand>
        ireminder <subcommand> --help
      """,
    version: "1.1.0",
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
