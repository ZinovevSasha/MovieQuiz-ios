import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - UIElements
    private let questionTitleLabel = UILabel()
    private let indexLabel = UILabel()
    private let questionLabel = UILabel()
    private let viewForQuestionLabel = UIView()
    private let noButton = UIButton(type: .system)
    private let yesButton = UIButton(type: .system)
    private let previewImage: UIImageView = {
        let previewImage = UIImageView(image: UIImage())
        previewImage.contentMode = .scaleAspectFill
        previewImage.backgroundColor = .ypWhite
        previewImage.layer.masksToBounds = true
        previewImage.layer.cornerRadius = 20
        previewImage.accessibilityIdentifier = "Poster"
        return previewImage
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    private let stackViewForPreviewImage = UIStackView()
    private let stackViewForButtons = UIStackView()
    private let stackViewForLabels = UIStackView()
    private let stackViewForAll = UIStackView()
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Dependencies
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var presenter: MovieQuizPresenter!

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        createUIElements()
        setUpScreen()
        setUpConstraints()
        showLoadingIndicator()
    }

    // MARK: - Functions to handle "state machine"
    func show(quiz step: QuizStepViewModel) {
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
        questionLabel.text = step.question

        questionLabel.animateQuestion()
        stackViewForPreviewImage.animateImage()
    }

    func show(quiz result: QuizResultsViewModel) {
        let alertController = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)

        let action = UIAlertAction(
            title: result.buttonText,
            style: .default) { [weak self] _ in
                self?.presenter.restartGame()
        }
        alertController.addAction(action)
        self.present(alertController, animated: true)
    }

    func showNetworkError(message: String) {
        let alertController = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)

        let action = UIAlertAction(
            title: "Попробовать еще раз",
            style: .default) { [weak self] _ in
                self?.presenter.restartGame()
        }
        alertController.addAction(action)
        present(alertController, animated: true)
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        previewImage.layer.borderWidth = 0
    }

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    func enableButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    private func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }

    // buttons action
    @objc private func noButtonPressed(sender: UIButton) {
        showLoadingIndicator()
        presenter.noButtonPressed()
        disableButtons()
    }

    @objc private func yesButtonPressed(sender: UIButton) {
        showLoadingIndicator()
        presenter.yesButtonPressed()
        disableButtons()
    }

    // MARK: - create elements and constraints on screen
    private func createUIElements() {
        view.backgroundColor = .ypBlack
        makeAppearance(of: noButton, title: "Нет", action: #selector(noButtonPressed(sender: )))
        makeAppearance(of: yesButton, title: "Да", action: #selector(yesButtonPressed(sender: )))
        yesButton.accessibilityIdentifier = "Yes"
        noButton.accessibilityIdentifier = "No"
        indexLabel.accessibilityIdentifier = "Index"

        makeAppearance(of: questionTitleLabel, text: "Вопрос:", font: .ysMedium ?? UIFont())

        makeAppearance(of: indexLabel, text: "1/10", font: .ysMedium ?? UIFont(), textAlignment: .right)

        indexLabel.setContentHuggingPriority(UILayoutPriority(252), for: .horizontal)

        makeAppearance(of: questionLabel, text: "", font: .ysBold ?? UIFont(), numberOfLines: 2, textAlignment: .center)

        questionLabel.setContentCompressionResistancePriority(UILayoutPriority(751.0), for: .vertical)

        makeAppearance(of: stackViewForLabels, axis: .horizontal, distribution: .fill, spacing: 0)
        makeAppearance(of: stackViewForButtons, axis: .horizontal, distribution: .fillEqually)
        makeAppearance(of: stackViewForAll, axis: .vertical, distribution: .fill)
    }

    private func setUpScreen() {
        [
            previewImage, stackViewForAll,
            noButton, yesButton, indexLabel,
            questionLabel, questionTitleLabel,
            stackViewForLabels, stackViewForButtons, activityIndicator
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        stackViewForLabels.addArrangedSubViews(
            questionTitleLabel,
            indexLabel)
        stackViewForButtons.addArrangedSubViews(
            noButton,
            yesButton)
        viewForQuestionLabel.addSubview(questionLabel)
        stackViewForPreviewImage.addArrangedSubview(previewImage)

        stackViewForAll.addArrangedSubViews(
            stackViewForLabels,
            stackViewForPreviewImage,
            viewForQuestionLabel,
            stackViewForButtons)

        view.addSubview(stackViewForAll)
        view.addSubview(activityIndicator)
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            // set constraints for (stackViewForAll)
            stackViewForAll.leadingAnchor.constraint(
                equalTo: view.safeLeadingAnchor,
                constant: 20),
            stackViewForAll.trailingAnchor.constraint(
                equalTo: view.safeTrailingAnchor,
                constant: -20),
            stackViewForAll.topAnchor.constraint(
                equalTo: view.safeTopAnchor,
                constant: 10),
            stackViewForAll.bottomAnchor.constraint(
                equalTo: view.safeBottomAnchor,
                constant: 0),
            // set ratio for (previewImage) 2/3
            previewImage.widthAnchor.constraint(
                equalTo: previewImage.heightAnchor,
                multiplier: (2 / 3)),
            // set height for stackViewForButtons
            stackViewForButtons.heightAnchor.constraint(
                equalToConstant: 60),
            // set  constraints from label to view, label sits inside
            questionLabel.leadingAnchor.constraint(
                equalTo: viewForQuestionLabel.leadingAnchor,
                constant: 42),
            questionLabel.trailingAnchor.constraint(
                equalTo: viewForQuestionLabel.trailingAnchor,
                constant: -42),
            questionLabel.topAnchor.constraint(
                equalTo: viewForQuestionLabel.topAnchor,
                constant: 13),
            questionLabel.bottomAnchor.constraint(
                equalTo: viewForQuestionLabel.bottomAnchor,
                constant: -13),
            // activityIndicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Helper Function
    private func makeAppearance(
        of button: UIButton,
        title: String,
        font: UIFont = .ysMedium ?? UIFont(),
        alignment: NSTextAlignment = .center,
        backgroundColor: UIColor = .ypGray,
        titleColor: UIColor = .ypBlack,
        cornerRadius: CGFloat = 15,
        action: Selector
    ) { button.backgroundColor = backgroundColor
        button.layer.cornerRadius = cornerRadius
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = font
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    private func makeAppearance(
        of label: UILabel,
        text: String,
        textColor: UIColor = .ypWhite,
        font: UIFont,
        numberOfLines: Int = 0,
        textAlignment: NSTextAlignment? = .none
    ) {
        label.text = text
        label.textColor = textColor
        label.font = font
        label.numberOfLines = numberOfLines
        label.textAlignment = textAlignment ?? .natural
        }

    private func makeAppearance(
        of stackView: UIStackView,
        axis: NSLayoutConstraint.Axis,
        distribution: UIStackView.Distribution,
        alignment: UIStackView.Alignment = .fill,
        spacing: CGFloat = 20
    ) {
        stackView.axis = axis
        stackView.distribution = distribution
        stackView.alignment = alignment
        stackView.spacing = spacing
    }
}
