import Foundation

class DateParser {
  private let detector: NSDataDetector?
  
  init() {
    detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
  }
  
  func parse(_ input: String) -> Date? {
    let lowercased = input.lowercased()
    let now = Date()
    let calendar = Calendar.current
    
    switch lowercased {
    case "today":
      return calendar.startOfDay(for: now)
    case "tomorrow":
      return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))
    case "yesterday":
      return calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))
    default:
      break
    }
    
    if lowercased.hasPrefix("in ") {
      let components = lowercased.dropFirst(3).split(separator: " ")
      if components.count >= 2,
         let value = Int(components[0]) {
        let unit = String(components[1])
        
        switch unit {
        case "day", "days":
          return calendar.date(byAdding: .day, value: value, to: now)
        case "week", "weeks":
          return calendar.date(byAdding: .weekOfYear, value: value, to: now)
        case "month", "months":
          return calendar.date(byAdding: .month, value: value, to: now)
        case "year", "years":
          return calendar.date(byAdding: .year, value: value, to: now)
        case "hour", "hours":
          return calendar.date(byAdding: .hour, value: value, to: now)
        case "minute", "minutes":
          return calendar.date(byAdding: .minute, value: value, to: now)
        default:
          break
        }
      }
    }
    
    guard let detector = detector else { return nil }
    
    let range = NSRange(location: 0, length: input.utf16.count)
    let matches = detector.matches(in: input, options: [], range: range)
    
    if let match = matches.first,
       let date = match.date {
      return date
    }
    
    return nil
  }
  
  func parseToComponents(_ input: String) -> DateComponents? {
    guard let date = parse(input) else { return nil }
    
    let calendar = Calendar.current
    let hasTime = input.contains(":") || 
                  input.lowercased().contains("am") || 
                  input.lowercased().contains("pm") ||
                  input.lowercased().contains("at")
    
    if hasTime {
      return calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    } else {
      return calendar.dateComponents([.year, .month, .day], from: date)
    }
  }
}