extension Int {
    mutating func increment() {
        self += 1
    }
}

extension Float {
    var myOwnRounded: String { String(format: "%.2f", self)}
}
