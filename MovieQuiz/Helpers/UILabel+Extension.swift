import UIKit

extension UILabel {
    func animateQuestion(animated: Bool = true) {
        let duration = animated ? 1 : 0.0
        UIView.transition(
            with: self,
            duration: duration,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil)
    }
}

extension UIStackView {
    func animateImage(animated: Bool = true) {
        let duration = animated ? 1 : 0.0
        UIView.transition(
            with: self,
            duration: duration,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil)
    }
}

extension Int {
    mutating func increment() {
        self += 1
    }
}
