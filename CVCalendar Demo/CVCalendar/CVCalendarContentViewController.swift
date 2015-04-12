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
    
    var page = 0
    var pageChanged = false
    var pageLoadingEnabled = true
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
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        
        calendarView.addSubview(scrollView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIScrollViewDelegate

extension CVCalendarContentViewController: UIScrollViewDelegate {
    
}

// MARK: - UI Refresh

extension CVCalendarContentViewController {
    func updateFrames(frame: CGRect) {
        scrollView.frame = frame
        scrollView.removeAllSubviews()
        scrollView.contentSize = CGSizeMake(frame.size.width * 3, frame.size.height)
        calendarView.hidden = false
    }
}

// MARK: - Convenience API

extension CVCalendarContentViewController {
    func performedDayViewSelection(dayView: DayView) {
        //delegate.performedDayViewSelection(dayView)
    }
    
    func togglePresentedDate(date: NSDate) {
        //delegate.togglePresentedDate(date)
    }
    
    func presentNextView(view: UIView?) {
        //delegate.presentNextView(dayView)
    }
    
    func presentPreviousView(view: UIView?) {
        //delegate.presentPreviousView(dayView)
    }
    
    func updateDayViews(hidden: Bool) {
        //delegate.updateDayViews(hidden)
    }
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
        let components = CVCalendarManager.sharedManager.componentsForDate(date)
        let calendar = NSCalendar.currentCalendar()
        
        components.month -= 1
        
        let dateBefore = calendar.dateFromComponents(components)!
        
        return dateBefore
    }
    
    func dateAfterDate(date: NSDate) -> NSDate {
        let components = CVCalendarManager.sharedManager.componentsForDate(date)
        let calendar = NSCalendar.currentCalendar()
        
        components.month += 1
        
        let dateAfter = calendar.dateFromComponents(components)!
        
        return dateAfter
    }
    
    func match(lhs: NSDate, _ rhs: NSDate) -> Bool {
        let lhsRange = Manager.sharedManager.dateRange(lhs)
        let rhsRange = Manager.sharedManager.dateRange(rhs)
        
        if lhsRange.year == rhsRange.year && lhsRange.month == rhsRange.month {
            return true
        }
        
        return false
    }
    
    func selectDayViewWithDay(day: Int, inMonthView monthView: CVCalendarMonthView) {
        let coordinator = CVCalendarDayViewControlCoordinator.sharedControlCoordinator
        monthView.mapDayViews { dayView in
            if dayView.date.day == day && !dayView.isOut {
                if let selected = coordinator.selectedDayView where selected != dayView {
                    self.calendarView.didSelectDayView(dayView)
                }
                
                coordinator.performDayViewSingleSelection(dayView)
            }
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