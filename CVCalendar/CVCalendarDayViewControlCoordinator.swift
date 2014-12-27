//
//  CVCalendarDayViewControlCoordinator.swift
//  CVCalendar
//
//  Created by Мак-ПК on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

private let instance = CVCalendarDayViewControlCoordinator()

class CVCalendarDayViewControlCoordinator: NSObject {
    
    class var sharedControlCoordinator: CVCalendarDayViewControlCoordinator {
        return instance
    }
   
    var selectedDayView: CVCalendarDayView? = nil
    
    lazy var appearance: CVCalendarViewAppearance = {
       return CVCalendarViewAppearance.sharedCalendarViewAppearance
    }()
    
    private override init() {
        super.init()
    }
    
    func performDayViewSelection(dayView: CVCalendarDayView) {
        if let selectedDayView = self.selectedDayView {
            if selectedDayView != dayView {
                self.presentDeselectionOnDayView(self.selectedDayView!)
                self.selectedDayView = dayView
                self.presentSelectionOnDayView(self.selectedDayView!)
            } else {
                // Deselect selected one
            }
        } else {
            self.selectedDayView = dayView
            self.presentSelectionOnDayView(self.selectedDayView!)
        }
    }
    
    private func presentSelectionOnDayView(dayView: CVCalendarDayView) {
        weak var color: UIColor?
        var _alpha: CGFloat?
        
        if dayView.isCurrentDay {
            color = appearance.dayLabelPresentWeekdayHighlightedBackgroundColor!
            _alpha = appearance.dayLabelPresentWeekdayHighlightedBackgroundAlpha!
            dayView.dayLabel?.textColor = appearance.dayLabelPresentWeekdayHighlightedTextColor!
            dayView.dayLabel?.font = UIFont.boldSystemFontOfSize(appearance.dayLabelPresentWeekdayHighlightedTextSize!)
        } else {
            color = appearance.dayLabelWeekdayHighlightedBackgroundColor
            _alpha = appearance.dayLabelWeekdayHighlightedBackgroundAlpha
            dayView.dayLabel?.textColor = appearance.dayLabelWeekdayHighlightedTextColor
            dayView.dayLabel?.font = UIFont.boldSystemFontOfSize(appearance.dayLabelWeekdayHighlightedTextSize!)
        }
        
        // TODO: If OUT weekday selected -> change month
        // TODO: Perform animation
        
        var selectedBackgroundView = CVCircleView(frame: CGRectMake(0, 0, dayView.frame.width, dayView.frame.height), color: color!, _alpha: _alpha!)
        dayView.circleView = selectedBackgroundView
        
        dayView.insertSubview(dayView.circleView!, atIndex: 0)
    }
    
    private func presentDeselectionOnDayView(dayView: CVCalendarDayView) {
        
        var color: UIColor?
        if dayView.isOut {
            color = appearance.dayLabelWeekdayOutTextColor
        } else if dayView.isCurrentDay {
            color = appearance.dayLabelPresentWeekdayTextColor
        } else {
            color = appearance.dayLabelWeekdayInTextColor
        }
        
        var font: UIFont?
        if dayView.isCurrentDay {
            if appearance.dayLabelPresentWeekdayInitallyBold {
                font = UIFont.boldSystemFontOfSize(appearance.dayLabelPresentWeekdayTextSize!)
            } else {
                font = UIFont.systemFontOfSize(appearance.dayLabelPresentWeekdayTextSize!)
            }
        } else {
            font = UIFont.systemFontOfSize(appearance.dayLabelWeekdayTextSize!)
        }
        
        
        
        dayView.dayLabel?.textColor = color
        dayView.dayLabel?.font = font
        
        dayView.circleView?.removeFromSuperview()
        dayView.circleView = nil
        
        
    }
}
