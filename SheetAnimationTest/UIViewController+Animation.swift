//
//  UICollectionView+Animation.swift
//  Poshmark
//
//  Copyright © 2025 Poshmark, Inc. All rights reserved.
//

import UIKit

// MARK: - Animation Types

typealias CollectionViewAnimationOpacity = (starting: CGFloat, finished: CGFloat?)
typealias CollectionViewAnimationSliding = (isToIdentity: Bool, direction: CollectionViewAnimationSlidingDirection, amount: CGFloat)

enum CollectionViewAnimationSlidingDirection {
    case horizontal, vertical
}

enum PoshmarkCollectionCellAnimationType: Hashable {
    case slide(animationSliding: CollectionViewAnimationSliding)
    case opacity(animationOpacity: CollectionViewAnimationOpacity)

    static func == (lhs: PoshmarkCollectionCellAnimationType, rhs: PoshmarkCollectionCellAnimationType) -> Bool {
        switch (lhs, rhs) {
        case (.slide, .slide): return true
        case (.opacity, .opacity): return true
        default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .slide:
            hasher.combine(0)
        case .opacity:
            hasher.combine(1)
        }
    }
}

extension Set where Element == PoshmarkCollectionCellAnimationType {
    var opacityAnimation: CollectionViewAnimationOpacity? {
        for type in self {
            if case .opacity(let animationOpacity) = type {
                return animationOpacity
            }
        }
        return nil
    }
    var slideAnimation: CollectionViewAnimationSliding? {
        for type in self {
            if case .slide(let animationSliding) = type {
                return animationSliding
            }
        }
        return nil
    }
}

struct CollectionViewCellAnimationParameter {
    let type: Set<PoshmarkCollectionCellAnimationType>
    let duration: TimeInterval
    var delay: CGFloat = 0
    var springWithDamping: CGFloat = 1
    var initialSpringVelocity: CGFloat = 0.5
    let options: UIView.AnimationOptions

    func create(with newDelay: CGFloat) -> CollectionViewCellAnimationParameter {
        CollectionViewCellAnimationParameter(
            type: type,
            duration: duration,
            delay: newDelay,
            springWithDamping: springWithDamping,
            initialSpringVelocity: initialSpringVelocity,
            options: options
        )
    }
}

// MARK: - UICollectionView Animation

extension UICollectionView {
    func animate(cell: UIView, parameter: CollectionViewCellAnimationParameter) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            performAnimation(view: cell, parameter: parameter)
        }
    }

    func animateVisibleCells(parameter: CollectionViewCellAnimationParameter) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            // Force layout only with CATransaction, without animation
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layoutIfNeeded()
            CATransaction.commit()
            performAnimation(views: visibleCells, parameter: parameter)
        }
    }

    func animateVisibleCellsByRow(rowInterval: TimeInterval = 0.2, parameter: CollectionViewCellAnimationParameter) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            let cellsByRow = getVisibleCellsByRow()
            // Force layout only with CATransaction, without animation
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layoutIfNeeded()
            CATransaction.commit()
            // Animate each row sequentially
            for (rowIndex, cellsInRow) in cellsByRow.enumerated() {
                // Apply same delay to all cells in the same row
                let rowDelay = CGFloat(rowIndex) * rowInterval
                let rowParameter = parameter.create(with: rowDelay)
                performAnimation(views: cellsInRow, parameter: rowParameter)
            }
        }
    }
}

// MARK: - Private Animation Methods

extension UICollectionView {
    @MainActor
    private func performAnimation(views: [UIView], parameter: CollectionViewCellAnimationParameter) {
        for view in views {
            performAnimation(view: view, parameter: parameter)
        }
    }

    @MainActor
    private func performAnimation(view: UIView, parameter: CollectionViewCellAnimationParameter) {
        guard !parameter.type.isEmpty else { return }
        func transformed(_ animationSliding: CollectionViewAnimationSliding) -> CGAffineTransform {
            switch animationSliding.direction {
            case .horizontal: return CGAffineTransform(translationX: animationSliding.amount, y: 0)
            case .vertical: return CGAffineTransform(translationX: 0, y: animationSliding.amount)
            }
        }

        if let opacityAnimation = parameter.type.opacityAnimation {
            view.alpha = opacityAnimation.starting
        }
        if let slideAnimation = parameter.type.slideAnimation {
            view.transform = slideAnimation.isToIdentity ? transformed(slideAnimation) : .identity
        }

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "collectionViewCellAnimationDidStart"), object: nil)
        UIView.animate(withDuration: parameter.duration,
                       delay: parameter.delay,
                       usingSpringWithDamping: parameter.springWithDamping,
                       initialSpringVelocity: parameter.initialSpringVelocity,
                       options: parameter.options,
                       animations: {
            if let opacityAnimation = parameter.type.opacityAnimation {
                view.alpha = opacityAnimation.finished ?? 1
            }
            if let slideAnimation = parameter.type.slideAnimation {
                view.transform = slideAnimation.isToIdentity ? .identity : transformed(slideAnimation)
            }
        }, completion: { _ in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "collectionViewCellAnimationDidFinish"), object: nil)
        })
    }
}

// MARK: - Helpers

extension UICollectionView {

    /// Group visible cells by row and return
    /// - Returns: Array of cells grouped by row (top to bottom, each row sorted left to right)
    private func getVisibleCellsByRow() -> [[UICollectionViewCell]] {
        // Group by Y coordinate to classify by row
        let rowGroups = Dictionary(grouping: visibleCells) { $0.frame.minY }
        // Sort by Y coordinate (top to bottom)
        let sortedRowYs = rowGroups.keys.sorted()
        // Convert cells of each row to array
        var result: [[UICollectionViewCell]] = []
        for yPosition in sortedRowYs {
            guard let cellsInRow = rowGroups[yPosition] else { continue }
            // Sort cells in the same row from left to right
            let sortedCellsInRow = cellsInRow.sorted { $0.frame.minX < $1.frame.minX }
            result.append(sortedCellsInRow)
        }
        return result
    }
}
