import Foundation

extension DateComponents {
  var date: Date? {
    return Calendar.current.date(from: self)
  }
}

extension Date {
  func relativeDateString() -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    return formatter.localizedString(for: self, relativeTo: Date())
  }
  
  func formattedDateString() -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: self)
  }
}

func formatReminderDate(_ components: DateComponents?) -> String? {
  guard let components = components,
        let date = components.date else { return nil }
  
  let now = Date()
  let calendar = Calendar.current
  
  if calendar.isDateInToday(date) {
    if components.hour != nil {
      let formatter = DateFormatter()
      formatter.timeStyle = .short
      return "Today at \(formatter.string(from: date))"
    }
    return "Today"
  } else if calendar.isDateInTomorrow(date) {
    if components.hour != nil {
      let formatter = DateFormatter()
      formatter.timeStyle = .short
      return "Tomorrow at \(formatter.string(from: date))"
    }
    return "Tomorrow"
  } else if date < now {
    return "Overdue: \(date.formattedDateString())"
  } else {
    return date.relativeDateString()
  }
}