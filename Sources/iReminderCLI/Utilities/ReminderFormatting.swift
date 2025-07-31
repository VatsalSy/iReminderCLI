import EventKit
import Foundation

struct ReminderOutput {
  let reminder: EKReminder
  let index: Int?
  
  func formatForDisplay() -> String {
    var output = ""
    
    if let index = index {
      output += "[\(index)] "
    }
    
    if reminder.isCompleted {
      output += "✓ "
    }
    
    output += reminder.title ?? "Untitled"
    
    if let dueDate = formatReminderDate(reminder.dueDateComponents) {
      output += " (\(dueDate))"
    }
    
    if reminder.priority > 0 && reminder.priority <= 3 {
      let priorities = ["", "!", "!!", "!!!"]
      output += " \(priorities[reminder.priority])"
    }
    
    if let notes = reminder.notes, !notes.isEmpty {
      output += "\n    Notes: \(notes.replacingOccurrences(of: "\n", with: "\n    "))"
    }
    
    return output
  }
  
  func toDictionary() -> [String: Any] {
    var dict: [String: Any] = [
      "id": reminder.calendarItemIdentifier,
      "title": reminder.title ?? "",
      "completed": reminder.isCompleted,
      "priority": reminder.priority
    ]
    
    if let index = index {
      dict["index"] = index
    }
    
    if let notes = reminder.notes {
      dict["notes"] = notes
    }
    
    if let dueDate = reminder.dueDateComponents {
      var dateDict: [String: Any] = [:]
      if let year = dueDate.year { dateDict["year"] = year }
      if let month = dueDate.month { dateDict["month"] = month }
      if let day = dueDate.day { dateDict["day"] = day }
      if let hour = dueDate.hour { dateDict["hour"] = hour }
      if let minute = dueDate.minute { dateDict["minute"] = minute }
      dict["dueDate"] = dateDict
    }
    
    return dict
  }
}