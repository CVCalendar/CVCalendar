//
//  ContentViewController2.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 2/23/16.
//  Copyright © 2016 GameApp. All rights reserved.
//

import UIKit

///  ContentViewController2

public protocol CVCalendarContentViewController: CVCalendarViewContentManager {
    typealias ContentView
    var contentView: ContentView { get set }
    unowned var calendarView: CVCalendarView { get set }
}

public extension CVCalendarContentViewController where Self.ContentView : UIView {
    var bounds: CGRect { return contentView.bounds }
}

@objc public protocol CVCalendarViewContentManager {
    optional func performedDayViewSelection(dayView: DayView)
    optional func togglePresentedDate(date: NSDate)
    optional func presentNextView(view: UIView?)
    optional func presentPreviousView(view: UIView?)
    optional func updateDayViews(hidden: Bool)
}

///  CVCalendarScrollableContentViewController

public protocol CVCalendarScrollableContentViewController: CVCalendarContentViewController, UIScrollViewDelegate {
    var presentedMonthView: CVCalendarMonthView { get set }
    
    var currentPage: Int { get set }
    var pageChanged: Bool { get }
    
    var pageLoadingEnabled: Bool { get set }
    var presentationEnabled: Bool { get set }
    var lastContentOffset: CGFloat { get set }
    var direction: CVScrollDirection { get set }
    
    //func updateSelection()
}

public enum Identifier: String {
    case Previous = "Previous"
    case Presented = "Presented"
    case Following = "Following"
}

public extension CVCalendarScrollableContentViewController where Self.ContentView : UIScrollView {
    func indexOfIdentifier(identifier: Identifier) -> Int {
        let index: Int
        switch identifier {
        case .Previous:
            index = 0
        case .Presented:
            index = 1
        case .Following:
            index = 2
        }
        
        return index
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        print("Scroll From POROTOCOL")
        
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0)
        }
        
        let page = Int(floor((scrollView.contentOffset.x - scrollView.frame.width / 2) / scrollView.frame.width) + 1)
        if currentPage != page {
            currentPage = page
        }
        
        lastContentOffset = scrollView.contentOffset.x
    }
}


///  CVCalendarViewRefresher

public protocol CVCalendarViewRefresher {
    func updateFrames(frame: CGRect)
    func removeCircleLabel(dayView: CVCalendarDayView)
    func removeDotViews(dayView: CVCalendarDayView)
}

public extension CVCalendarViewRefresher where Self : CVCalendarContentViewController, Self.ContentView : UIView {
    func updateFrames(frame: CGRect) {
        print("Update frames for VIEW")
        if frame != .zero {
            contentView.frame = frame
            contentView.removeAllSubviews()
        }
        
        calendarView.hidden = false
    }
    
    func removeCircleLabel(dayView: CVCalendarDayView) {
        for each in dayView.subviews {
            if each is UILabel {
                continue
            } else if each is CVAuxiliaryView  {
                continue
            } else {
                each.removeFromSuperview()
            }
        }
    }
    
    func removeDotViews(dayView: CVCalendarDayView) {
        for each in dayView.subviews {
            if each is CVAuxiliaryView && each.frame.height == 13 {
                each.removeFromSuperview()
            }
        }
    }
}

public extension CVCalendarViewRefresher where Self : CVCalendarScrollableContentViewController, Self.ContentView : UIScrollView {
    func updateFrames(frame: CGRect) {
        print("Update frames for SCROLL VIEW")
        if frame != .zero {
            contentView.frame = frame
            contentView.removeAllSubviews()
            contentView.contentSize = CGSizeMake(frame.size.width * 3, frame.size.height)
        }
        
        calendarView.hidden = false
    }
    
    func refreshPresentedMonth() {
        for weekV in presentedMonthView.weekViews {
            for dayView in weekV.dayViews {
                removeCircleLabel(dayView)
                dayView.setupDotMarker()
                dayView.preliminarySetup()
                dayView.supplementarySetup()
                dayView.topMarkerSetup()
            }
        }
    }
}

///  CVCalendarViewDateManager

public protocol CVCalendarViewDateManager {
    func dateBeforeDate(date: NSDate) -> NSDate
    func dateAfterDate(date: NSDate) -> NSDate
    func matchedMonths(lhs: Date, _ rhs: Date) -> Bool
    func matchedWeeks(lhs: Date, _ rhs: Date) -> Bool
    func matchedDays(lhs: Date, _ rhs: Date) -> Bool
}

public extension CVCalendarViewDateManager {
    public func dateBeforeDate(date: NSDate) -> NSDate {
        return date.month - 1
    }
    
    public func dateAfterDate(date: NSDate) -> NSDate {
        return date.month + 1
    }
    
    public func matchedMonths(lhs: Date, _ rhs: Date) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month
    }
    
    public func matchedWeeks(lhs: Date, _ rhs: Date) -> Bool {
        return (lhs.year == rhs.year && lhs.month == rhs.month && lhs.week == rhs.week)
    }
    
    public func matchedDays(lhs: Date, _ rhs: Date) -> Bool {
        return (lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day)
    }
}

///  CVCalendarViewLayoutManager

public protocol CVCalendarViewLayoutManager {
    func layoutViews(views: [UIView], toHeight height: CGFloat)
    func updateHeight(height: CGFloat, animated: Bool)
    func updateLayoutIfNeeded()
}

public extension CVCalendarViewLayoutManager where Self : CVCalendarContentViewController, Self.ContentView : UIView {
    func layoutViews(views: [UIView], toHeight height: CGFloat) {
        contentView.frame.size.height = height
        
        var superStack = [UIView]()
        var currentView: UIView = calendarView
        while let currentSuperview = currentView.superview where !(currentSuperview is UIWindow) {
            superStack += [currentSuperview]
            currentView = currentSuperview
        }
        
        for view in views + superStack {
            view.layoutIfNeeded()
        }
    }
    
    func updateHeight(height: CGFloat, animated: Bool) {
        guard calendarView.shouldAnimateResizing else {
            return
        }
        
        var viewsToLayout = [UIView]()
        if let calendarSuperview = calendarView.superview {
            for constraintIn in calendarSuperview.constraints {
                if let firstItem = constraintIn.firstItem as? UIView, _ = constraintIn.secondItem as? CalendarView {
                    viewsToLayout.append(firstItem)
                }
            }
        }
        
        for constraintIn in calendarView.constraints where constraintIn.firstAttribute == NSLayoutAttribute.Height {
            constraintIn.constant = height
            
            if animated {
                UIView.animateWithDuration(0.2,
                    delay: 0,
                    options: UIViewAnimationOptions.CurveLinear,
                    
                    animations: {
                        self.layoutViews(viewsToLayout, toHeight: height)
                    },
                    
                    completion: nil
                )
            } else {
                layoutViews(viewsToLayout, toHeight: height)
            }
            
            break
        }
    }
    
    func updateLayoutIfNeeded() {
        contentView.layoutIfNeeded()
    }
}

public extension CVCalendarViewLayoutManager where Self : CVCalendarScrollableContentViewController, Self.ContentView : UIScrollView {
    func updateHeight(height: CGFloat, animated: Bool) {
        guard calendarView.shouldAnimateResizing else {
            return
        }
        
        var viewsToLayout = [UIView]()
        if let calendarSuperview = calendarView.superview {
            for constraintIn in calendarSuperview.constraints {
                if let firstItem = constraintIn.firstItem as? UIView, _ = constraintIn.secondItem as? CalendarView {
                    
                    viewsToLayout.append(firstItem)
                }
            }
        }
        
        for constraintIn in calendarView.constraints where constraintIn.firstAttribute == NSLayoutAttribute.Height {
            constraintIn.constant = height
            
            if animated {
                UIView.animateWithDuration(0.2,
                    delay: 0,
                    options: UIViewAnimationOptions.CurveLinear,
                    
                    animations: {
                        self.layoutViews(viewsToLayout, toHeight: height)
                    },
                    
                    completion: { _ in
                        self.presentedMonthView.frame.size = self.presentedMonthView.potentialSize
                        self.presentedMonthView.updateInteractiveView()
                    }
                )
            } else {
                layoutViews(viewsToLayout, toHeight: height)
                presentedMonthView.updateInteractiveView()
                presentedMonthView.frame.size = presentedMonthView.potentialSize
                presentedMonthView.updateInteractiveView()
            }
            
            break
        }
    }
    
    func updateLayoutIfNeeded() {
        if presentedMonthView.potentialSize.height != contentView.bounds.height {
            updateHeight(presentedMonthView.potentialSize.height, animated: true)
        } else if presentedMonthView.frame.size != contentView.frame.size {
            presentedMonthView.frame.size = presentedMonthView.potentialSize
            presentedMonthView.updateInteractiveView()
        }
    }
}

/// Extension 

public extension UIView {
    public func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
}