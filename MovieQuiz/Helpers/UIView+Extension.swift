import UIKit

extension UIView {
    func animate(animated: Bool = true) {
        let duration = animated ? 1 : 0.0
        UIView.transition(
            with: self,
            duration: duration,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil)
    }
}
