//
//  CVCalendarViewAnimator.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarViewAnimator: NSObject, CVCalendarViewAnimatorDelegate {
    
    override init() {
        super.init()
    }
    
    func animateSelectionWithBounceEffect(dayView: CVCalendarDayView, withControlCooordinator coordinator: CVCalendarDayViewControlCoordinator) {
        dayView.setDayLabelSelected()
        dayView.dayLabel?.transform = CGAffineTransformMakeScale(0.5, 0.5)
        dayView.circleView?.transform = CGAffineTransformMakeScale(0.5, 0.5)
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            dayView.circleView?.transform = CGAffineTransformMakeScale(1, 1)
            dayView.dayLabel?.transform = CGAffineTransformMakeScale(1, 1)
        }) { _ in
            
        }
    }
    
    func animateDeselectionWithRollingEffect(dayView: CVCalendarDayView, withControlCooordinator coordinator: CVCalendarDayViewControlCoordinator) {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            dayView.circleView?.transform = CGAffineTransformMakeScale(0.1, 0.1)
            dayView.circleView?.alpha = 0.0
        }) { _ in
            coordinator.deselectionPerformedOnDayView(dayView)
        }
    }
    
    func animateDeselectionWithBubbleEffect(dayView: CVCalendarDayView, withControlCooordinator coordinator: CVCalendarDayViewControlCoordinator) {
        UIView.animateWithDuration(0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            dayView.circleView!.transform = CGAffineTransformMakeScale(1.3, 1.3)
        }) { _ in
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                dayView.circleView!.transform = CGAffineTransformMakeScale(0.1, 0.1)
            }) { _ in
                coordinator.deselectionPerformedOnDayView(dayView)
            }
        }
    }
    
    func animateDeselectionWithFadeOutEffect(dayView: CVCalendarDayView, withControlCoordinator coordinator: CVCalendarDayViewControlCoordinator) {
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: nil, animations: {
            dayView.setDayLabelUnhighlightedDismissingState(false)
            dayView.circleView?.alpha = 0
        }) { _ in
            coordinator.deselectionPerformedOnDayView(dayView)
        }
    }
    
    // MARK: - Animator Delegate
    
    func animateSelection(dayView: CVCalendarDayView, withControlCoordinator coordinator: CVCalendarDayViewControlCoordinator) {
        self.animateSelectionWithBounceEffect(dayView, withControlCooordinator: coordinator)
    }
    
    func animateDeselection(dayView: CVCalendarDayView, withControlCoordinator coordinator: CVCalendarDayViewControlCoordinator) {
        self.animateDeselectionWithFadeOutEffect(dayView, withControlCoordinator: coordinator)
    }
}
