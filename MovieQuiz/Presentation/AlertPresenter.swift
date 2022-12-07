import UIKit

class AlertPresenter {
    weak var viewController: UIViewController?
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
}

extension AlertPresenter: AlertPresenterProtocol {
    func displayAlert(_ alert: AlertModel) {
        let alertController = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert)

        let action = UIAlertAction(
            title: alert.buttonText,
            style: .default) { _ in
                alert.completion()
        }
        alertController.addAction(action)
        viewController?.present(alertController, animated: true)
    }
}
