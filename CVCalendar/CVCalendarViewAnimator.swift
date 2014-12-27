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
    
    let coordinator = CVCalendarDayViewControlCoordinator.sharedControlCoordinator
    
    func animateSelectionWithBounceEffect(dayView: CVCalendarDayView) {
        dayView.setDayLabelHighlighted()
        
        dayView.dayLabel?.transform = CGAffineTransformMakeScale(0.5, 0.5)
        dayView.circleView?.transform = CGAffineTransformMakeScale(0.5, 0.5)
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.coordinator.animationStarted()
            
            dayView.circleView?.transform = CGAffineTransformMakeScale(1, 1)
            dayView.dayLabel?.transform = CGAffineTransformMakeScale(1, 1)
            
            }) { (Bool) -> Void in
                self.coordinator.animationEnded()
        }
    }
    
    func animateDeselectionWithRollingEffect(dayView: CVCalendarDayView) {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.coordinator.animationStarted()
            dayView.circleView!.transform = CGAffineTransformMakeScale(0.1, 0.1)
            dayView.circleView?.alpha = 0.0
            
            }) { (Bool) -> Void in
                dayView.setDayLabelUnhighlighted()
                self.coordinator.animationEnded()
        }
    }
    
    func animateDeselectionWithBubbleEffect(dayView: CVCalendarDayView) {
        UIView.animateWithDuration(0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            
            self.coordinator.animationStarted()
            
            dayView.circleView!.transform = CGAffineTransformMakeScale(1.3, 1.3)
            
            }) { (Bool) -> Void in
                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    
                    dayView.circleView!.transform = CGAffineTransformMakeScale(0.1, 0.1)
                    
                    }) { (Bool) -> Void in
                        dayView.setDayLabelUnhighlighted()
                        self.coordinator.animationEnded()
                }
        }
    }
    
    // MARK: - Animator Delegate
   
    func animateSelection(dayView: CVCalendarDayView) {
        self.animateSelectionWithBounceEffect(dayView)
    }
    
    func animateDeselection(dayView: CVCalendarDayView) {
        self.animateDeselectionWithRollingEffect(dayView)
    }
    
}
