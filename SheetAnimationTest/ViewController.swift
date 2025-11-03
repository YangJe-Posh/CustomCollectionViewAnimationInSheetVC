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

// MARK: - Sheet ViewController with CollectionView
class SheetViewController: UIViewController {

    var type: AnimationType = .none

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "The Sheet"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let colors: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen, .systemOrange,
        .systemPurple, .systemPink, .systemTeal, .systemIndigo,
        .systemMint, .systemCyan, .systemBrown, .systemYellow,
        .systemGray,
    ]

    var commonTestParameter: CollectionViewCellAnimationParameter {
        let animationTypes: Set<PoshmarkCollectionCellAnimationType> = [
            .opacity(animationOpacity: (starting: 0, finished: 1)),
            .slide(animationSliding: (isToIdentity: true, direction: .vertical, amount: 50))
        ]
        return CollectionViewCellAnimationParameter(type: animationTypes, duration: 3, delay: 0, springWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseOut)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    static var commonTestParameter: CollectionViewCellAnimationParameter {
        let animationTypes: Set<PoshmarkCollectionCellAnimationType> = [
            .opacity(animationOpacity: (starting: 0, finished: 1)),
            .slide(animationSliding: (isToIdentity: true, direction: .vertical, amount: 50))
        ]
        return CollectionViewCellAnimationParameter(type: animationTypes, duration: 3, delay: 0, springWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseOut)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard type != .none else { return } 
        collectionView.animateVisibleCells(parameter: commonTestParameter)
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension SheetViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        cell.configure(with: colors[indexPath.item], number: indexPath.item + 1)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCellInRow: Int = 3
        // Calculate padding: left/right inset + spacing between cells
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let leftRightInset = layout.sectionInset.left + layout.sectionInset.right
        let spacingBetweenCells = layout.minimumInteritemSpacing * CGFloat(numberOfCellInRow - 1)
        let totalPadding = leftRightInset + spacingBetweenCells
        // Calculate width (square)
        let width = (collectionView.frame.width - totalPadding) / CGFloat(numberOfCellInRow)
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard self.type.isAnimationEnabled else { return }
//        let animationTypes: [PoshmarkCollectionCellAnimationType] = [
//            .opacity(animationOpacity: (starting: 0, finished: 1)),
//            .slide(animationSliding: (isToIdentity: true, direction: .vertical, amount: 500))
//        ]
//        let parameter = CollectionViewCellAnimationParameter(type: animationTypes, duration: 0.4, delay: 0, springWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseOut)
//        collectionView.animate(views: [cell], parameter: parameter)
    }
}

// MARK: - Custom Cell
class ColorCell: UICollectionViewCell {

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8

        contentView.addSubview(numberLabel)

        NSLayoutConstraint.activate([
            numberLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with color: UIColor, number: Int) {
        backgroundColor = color
        numberLabel.text = "\(number)"
    }
}
