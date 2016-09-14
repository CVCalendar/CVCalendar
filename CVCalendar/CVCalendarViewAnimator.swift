//
//  CVCalendarViewAnimator.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarViewAnimator {
    fileprivate unowned let calendarView: CalendarView

    // MARK: - Public properties
    public weak var delegate: CVCalendarViewAnimatorDelegate!
    public var coordinator: CVCalendarDayViewControlCoordinator {
        get {
            return calendarView.coordinator
        }
    }

    // MARK: - Init
    public init(calendarView: CalendarView) {
        self.calendarView = calendarView
        delegate = self
    }
}

// MARK: - Public methods

extension CVCalendarViewAnimator {
    public func animateSelectionOnDayView(_ dayView: DayView) {
        let selectionAnimation = delegate.selectionAnimation()
        dayView.setSelectedWithType(.single)
        selectionAnimation(dayView) { [unowned dayView] _ in
            let _ = dayView
            // Something...
        }
    }

    public func animateDeselectionOnDayView(_ dayView: DayView) {
        let deselectionAnimation = delegate.deselectionAnimation()
        deselectionAnimation(dayView) { [weak dayView] _ in
            if let selectedDayView = dayView {
               self.coordinator.deselectionPerformedOnDayView(selectedDayView)
            }
        }
    }
}

// MARK: - CVCalendarViewAnimatorDelegate

extension CVCalendarViewAnimator: CVCalendarViewAnimatorDelegate {
    @objc public func selectionAnimation() -> ((DayView, @escaping ((Bool) -> ())) -> ()) {
        return selectionWithBounceEffect()
    }

    @objc public func deselectionAnimation() -> ((DayView, @escaping ((Bool) -> ())) -> ()) {
        return deselectionWithFadeOutEffect()
    }
}

// MARK: - Default animations

private extension CVCalendarViewAnimator {
    func selectionWithBounceEffect() -> ((DayView, @escaping ((Bool) -> ())) -> ()) {
        return {
            dayView, completion in
            dayView.dayLabel?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            dayView.selectionView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3,
                                       initialSpringVelocity: 0.1,
                                       options: UIViewAnimationOptions.beginFromCurrentState,
                                       animations: {
                dayView.selectionView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                dayView.dayLabel?.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: completion)
        }
    }

    func deselectionWithBubbleEffect() -> ((DayView, @escaping ((Bool) -> ())) -> ()) {
        return {
            dayView, completion in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.6,
                                       initialSpringVelocity: 0.8,
                                       options: UIViewAnimationOptions.curveEaseOut, animations: {
                dayView.selectionView!.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { _ in
                UIView.animate(withDuration: 0.2, delay: 0,
                                           options: UIViewAnimationOptions(),
                                           animations: {
                    if let selectionView = dayView.selectionView {
                        selectionView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    }
                }, completion: completion)
            }
        }
    }

    func deselectionWithFadeOutEffect() -> ((DayView, @escaping ((Bool) -> ())) -> ()) {
        return {
            dayView, completion in
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6,
                                       initialSpringVelocity: 0, options: [], animations: {

                // return labels' defaults while circle view disappearing
                dayView.setDeselectedWithClearing(false)

                if let selectionView = dayView.selectionView {
                    selectionView.alpha = 0
                }
            }, completion: completion)
        }
    }

    func deselectionWithRollingEffect() -> ((DayView, @escaping ((Bool) -> ())) -> ()) {
        return {
            dayView, completion in
            UIView.animate(withDuration: 0.25, delay: 0,
                                       options: UIViewAnimationOptions(),
                                       animations: { () -> Void in
                dayView.selectionView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                dayView.selectionView?.alpha = 0.0
            }, completion: completion)
        }
    }
}
