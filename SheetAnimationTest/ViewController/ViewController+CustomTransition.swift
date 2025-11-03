//
//  ViewController+CustomTransition.swift
//  SheetAnimationTest
//
//  Created by USER on 10/31/25.
//

import UIKit

class SheetPresentationController: UIPresentationController {

    // Dimming view for background
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.alpha = 0

        // ✨ Tap to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDimmingViewTap))
        view.addGestureRecognizer(tapGesture)

        return view
    }()

    @objc private func handleDimmingViewTap() {
        presentedViewController.dismiss(animated: true)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }

        // Set sheet height to 70% of screen (similar to medium detent)
        let height = containerView.bounds.height * 0.7
        let yOffset = containerView.bounds.height - height

        return CGRect(
            x: 0,
            y: yOffset,
            width: containerView.bounds.width,
            height: height
        )
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        guard let containerView = containerView else { return }

        // Add dimming view
        dimmingView.frame = containerView.bounds
        containerView.insertSubview(dimmingView, at: 0)

        // Add shadow to sheet
        presentedView?.layer.shadowColor = UIColor.black.cgColor
        presentedView?.layer.shadowOpacity = 0.3
        presentedView?.layer.shadowOffset = CGSize(width: 0, height: -2)
        presentedView?.layer.shadowRadius = 10

        // Fade in dimming view alongside present animation
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        })
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        // Fade out dimming view alongside dismiss animation
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)

        if completed {
            dimmingView.removeFromSuperview()
        }
    }
}

// MARK: - Custom Sheet Presentation Animator
class SheetPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let isPresenting: Bool

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animatePresentation(using: transitionContext)
        } else {
            animateDismissal(using: transitionContext)
        }
    }

    private func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? SheetViewController,
              let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)

        // Configure sheet view
        toView.frame = finalFrame
        toView.layer.cornerRadius = 16
        toView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        toView.clipsToBounds = true

        // Initial position: below screen
        toView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
        containerView.addSubview(toView)

        // Execute present animation and cell animation simultaneously
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut,
            animations: {
                // Slide sheet up
                toView.transform = .identity
                if toVC.type == .duringCustomTransition {
                    // Start cell animation simultaneously (by row)
                    toVC.collectionView.animateVisibleCellsByRow(parameter: commonTestParameter)
                }
            },
            completion: { finished in
                transitionContext.completeTransition(finished)
            }
        )
    }

    private func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.5,
            options: .curveEaseIn,
            animations: {
                fromView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
            },
            completion: { finished in
                transitionContext.completeTransition(finished)
            }
        )
    }
}

// MARK: - Transitioning Delegate
class SheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SheetPresentationAnimator(isPresenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SheetPresentationAnimator(isPresenting: false)
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
