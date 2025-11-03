//
//  ViewController.swift
//  SheetAnimationTest
//
//  Created by USER on 10/1/25.
//

import UIKit

enum AnimationType {
    case duringCustomTransition, inDefualtSheetTransition, none
    var title: String {
        switch self {
        case .duringCustomTransition: return "Show Custom Transition Sheet"
        case .inDefualtSheetTransition: return "Show Default Transition Sheet"
        case .none: return "Reference"
        }
    }
    var tintColor: UIColor {
        switch self {
        case .duringCustomTransition: return .gray
        case .inDefualtSheetTransition: return .blue
        case .none: return .systemGreen
        }
    }
    var isAnimationEnabled: Bool {
        switch self {
        case .duringCustomTransition: return true
        case .inDefualtSheetTransition: return true
        case .none: return false
        }
    }
}

class ViewController: UIViewController {
    // Must strongly reference TransitioningDelegate
    private let sheetTransitioningDelegate = SheetTransitioningDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Animation Test"
        setupButtons()
    }

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private func presentButton(type: AnimationType) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(type.title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = type.tintColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func setupButtons() {
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 300),
            stackView.heightAnchor.constraint(equalToConstant: 300)
        ])

        let button1 = presentButton(type: .duringCustomTransition)
        NSLayoutConstraint.activate([
            button1.widthAnchor.constraint(equalToConstant: 300),
            button1.heightAnchor.constraint(equalToConstant: 50)
        ])
        button1.addTarget(self, action: #selector(presentInCustomTransitionAnimation), for: .touchUpInside)
        stackView.addArrangedSubview(button1)

        let button2 = presentButton(type: .inDefualtSheetTransition)
        NSLayoutConstraint.activate([
            button2.widthAnchor.constraint(equalToConstant: 300),
            button2.heightAnchor.constraint(equalToConstant: 50)
        ])
        button2.addTarget(self, action: #selector(presentInDefaultTransitionAnimation), for: .touchUpInside)
        stackView.addArrangedSubview(button2)

        let button3 = presentButton(type: .none)
        NSLayoutConstraint.activate([
            button3.widthAnchor.constraint(equalToConstant: 300),
            button3.heightAnchor.constraint(equalToConstant: 50)
        ])
        button3.addTarget(self, action: #selector(presentJust), for: .touchUpInside)
        stackView.addArrangedSubview(button3)
    }

    @objc private func presentInCustomTransitionAnimation() {
        presentSheet(type: .duringCustomTransition)
    }

    @objc private func presentInDefaultTransitionAnimation() {
        presentSheet(type: .inDefualtSheetTransition)
    }

    @objc private func presentJust() {
        presentSheet(type: .none)
    }

    func presentSheet(type: AnimationType) {
        let sheetVC = SheetViewController()
        sheetVC.type = type
        switch type {
        case .duringCustomTransition:
            sheetVC.modalPresentationStyle = .custom
            sheetVC.transitioningDelegate = sheetTransitioningDelegate // Use custom transition (includes cell animation)
        case .inDefualtSheetTransition, .none:
            if let sheet = sheetVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
        }
        present(sheetVC, animated: true)
    }
}
