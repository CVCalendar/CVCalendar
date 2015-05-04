//
//  CVCalendarContentViewController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 12/04/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

typealias Identifier = String
class CVCalendarContentViewController: UIViewController {
    // MARK: - Constants
    let Previous = "Previous"
    let Presented = "Presented"
    let Following = "Following"
    
    // MARK: - Public Properties
    let calendarView: CalendarView
    let scrollView: UIScrollView
    
    var presentedMonthView: MonthView
    
    var bounds: CGRect {
        return scrollView.bounds
    }
    
    var currentPage = 1
    var pageChanged: Bool {
        get {
            return currentPage == 1 ? false : true
        }
    }
    
    var pageLoadingEnabled = true
    var presentationEnabled = true
    var lastContentOffset: CGFloat = 0
    var direction: CVScrollDirection = .None
    
    init(calendarView: CalendarView, frame: CGRect) {
        self.calendarView = calendarView
        scrollView = UIScrollView(frame: frame)
        presentedMonthView = MonthView(calendarView: calendarView, date: NSDate())
        presentedMonthView.updateAppearance(frame)
        
        super.init(nibName: nil, bundle: nil)
        
        scrollView.contentSize = CGSizeMake(frame.width * 3, frame.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.layer.masksToBounds = true
        scrollView.pagingEnabled = true
        scrollView.delegate = self
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Refresh

extension CVCalendarContentViewController {
    func updateFrames(frame: CGRect) {
        if frame != CGRectZero {
            scrollView.frame = frame
            scrollView.removeAllSubviews()
            scrollView.contentSize = CGSizeMake(frame.size.width * 3, frame.size.height)
        }
        
        calendarView.hidden = false
    }
}

// MARK: - Abstract methods

/// UIScrollViewDelegate
extension CVCalendarContentViewController: UIScrollViewDelegate { }

/// Convenience API.
extension CVCalendarContentViewController {
    func performedDayViewSelection(dayView: DayView) { }
    
    func togglePresentedDate(date: NSDate) { }
    
    func presentNextView(view: UIView?) { }
    
    func presentPreviousView(view: UIView?) { }
    
    func updateDayViews(hidden: Bool) { }
}

// MARK: - Contsant conversion

extension CVCalendarContentViewController {
    func indexOfIdentifier(identifier: Identifier) -> Int {
        let index: Int
        switch identifier {
        case Previous: index = 0
        case Presented: index = 1
        case Following: index = 2
        default: index = -1
        }
        
        return index
    }
}

// MARK: - Date management

extension CVCalendarContentViewController {
    func dateBeforeDate(date: NSDate) -> NSDate {
        let components = Manager.componentsForDate(date)
        let calendar = NSCalendar.currentCalendar()
        
        components.month -= 1
        
        let dateBefore = calendar.dateFromComponents(components)!
        
        return dateBefore
    }
    
    func dateAfterDate(date: NSDate) -> NSDate {
        let components = Manager.componentsForDate(date)
        let calendar = NSCalendar.currentCalendar()
        
        components.month += 1
        
        let dateAfter = calendar.dateFromComponents(components)!
        
        return dateAfter
    }
    
    func matchedMonths(lhs: Date, _ rhs: Date) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month
    }
    
    func matchedWeeks(lhs: Date, _ rhs: Date) -> Bool {
        return (lhs.year == rhs.year && lhs.month == rhs.month && lhs.week == rhs.week)
    }
    
    func matchedDays(lhs: Date, _ rhs: Date) -> Bool {
        return (lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day)
    }
}

// MARK: - AutoLayout Management

extension CVCalendarContentViewController {
    private func layoutViews(views: [UIView], toHeight height: CGFloat) {
        self.scrollView.frame.size.height = height
        self.calendarView.layoutIfNeeded()
        
        for view in views {
            view.layoutIfNeeded()
        }
    }
    
    func updateHeight(height: CGFloat, animated: Bool) {
        var viewsToLayout = [UIView]()
        if let calendarSuperview = calendarView.superview {
            for constraintIn in calendarSuperview.constraints() {
                if let constraint = constraintIn as? NSLayoutConstraint {
                    if let firstItem = constraint.firstItem as? UIView, let secondItem = constraint.secondItem as? CalendarView {
                        viewsToLayout.append(firstItem)
                    }
                }
            }
        }
        
        
        
        for constraintIn in calendarView.constraints() {
            if let constraint = constraintIn as? NSLayoutConstraint where constraint.firstAttribute == NSLayoutAttribute.Height {
                calendarView.layoutIfNeeded()
                constraint.constant = height
                if animated {
                    UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                        self.layoutViews(viewsToLayout, toHeight: height)
                        }) { _ in
                            self.presentedMonthView.frame.size = self.presentedMonthView.potentialSize
                            self.presentedMonthView.updateInteractiveView()
                    }
                } else {
                    layoutViews(viewsToLayout, toHeight: height)
                    presentedMonthView.updateInteractiveView()
                    presentedMonthView.frame.size = presentedMonthView.potentialSize
                    presentedMonthView.updateInteractiveView()
                }
                
                break
            }
        }
    }
    
    func updateLayoutIfNeeded() {
        if presentedMonthView.potentialSize.height != scrollView.bounds.height {
            updateHeight(presentedMonthView.potentialSize.height, animated: true)
        } else if presentedMonthView.frame.size != scrollView.frame.size {
            presentedMonthView.frame.size = presentedMonthView.potentialSize
            presentedMonthView.updateInteractiveView()
        }
    }
}

extension UIView {
    func removeAllSubviews() {
        for subview in subviews {
            if let view = subview as? UIView {
                view.removeFromSuperview()
            }
        }
    }
}