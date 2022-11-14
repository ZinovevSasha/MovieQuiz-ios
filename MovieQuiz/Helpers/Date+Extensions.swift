import Foundation

private let dateTimeDefaultFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.YY hh:mm"
    return dateFormatter
}()

extension Date {
    var dateTimeString: String { dateTimeDefaultFormatter.string(from: self) }
}


extension Float {
    var myOwnRounded: String { String(format: "%.2f", self)}
}
extension Double {
    var myOwnRounded: String { String(format: "%.1f", self)}
}
