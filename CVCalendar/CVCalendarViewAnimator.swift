//
//  CVCalendarViewAnimator.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarViewAnimator {
    private unowned let calendarView: CalendarView
    
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
    public func animateSelectionOnDayView(dayView: DayView) {
        let selectionAnimation = delegate.selectionAnimation()
        dayView.setSelectedWithType(.Single)
        selectionAnimation(dayView) { [unowned dayView] _ in
            // Something...
        }
    }
    
    public func animateDeselectionOnDayView(dayView: DayView) {
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
    @objc public func selectionAnimation() -> ((DayView, ((Bool) -> ())) -> ()) {
        return selectionWithBounceEffect()
    }
    
    @objc public func deselectionAnimation() -> ((DayView, ((Bool) -> ())) -> ()) {
        return deselectionWithFadeOutEffect()
    }
}

// MARK: - Default animations

private extension CVCalendarViewAnimator {
    func selectionWithBounceEffect() -> ((DayView, ((Bool) -> ())) -> ()) {
        return {
            dayView, completion in
            dayView.dayLabel?.transform = CGAffineTransformMakeScale(0.5, 0.5)
            dayView.selectionView?.transform = CGAffineTransformMakeScale(0.5, 0.5)
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                dayView.selectionView?.transform = CGAffineTransformMakeScale(1, 1)
                dayView.dayLabel?.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: completion)
        }
    }
    
    func deselectionWithBubbleEffect() -> ((DayView, ((Bool) -> ())) -> ()) {
        return {
            dayView, completion in
            UIView.animateWithDuration(0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                dayView.selectionView!.transform = CGAffineTransformMakeScale(1.3, 1.3)
            }) { _ in
                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    if let selectionView = dayView.selectionView {
                        selectionView.transform = CGAffineTransformMakeScale(0.1, 0.1)
                    }
                }, completion: completion)
            }
        }
    }
    
    func deselectionWithFadeOutEffect() -> ((DayView, ((Bool) -> ())) -> ()) {
        return {
            dayView, completion in
            UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [], animations: {
                dayView.setDeselectedWithClearing(false) // return labels' defaults while circle view disappearing
                if let selectionView = dayView.selectionView {
                    selectionView.alpha = 0
                }
            }, completion: completion)
        }
    }
    
    func deselectionWithRollingEffect() -> ((DayView, ((Bool) -> ())) -> ()) {
        return {
            dayView, completion in
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                dayView.selectionView?.transform = CGAffineTransformMakeScale(0.1, 0.1)
                dayView.selectionView?.alpha = 0.0
            }, completion: completion)
        }
    }
}

