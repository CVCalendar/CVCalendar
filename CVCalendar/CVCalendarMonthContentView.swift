//
//  CVCalendarMonthContentView.swift
//  CVCalendar Demo
//
//  Created by E. Mozharovsky on 1/25/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

enum ScrollDirection {
    case None
    case Right
    case Left
}

class CVCalendarMonthContentView: NSObject, CVCalendarContentDelegate {

    // MARK: - Types work
    
    typealias WeekView = CVCalendarWeekView
    typealias CalendarView = CVCalendarView
    typealias MonthView = CVCalendarMonthView
    typealias Manager = CVCalendarManager
    typealias Recovery = CVCalendarWeekContentRecovery
    typealias WeekContentView = CVCalendarWeekContentView
    typealias DayView = CVCalendarDayView
    typealias ContentController = CVCalendarContentViewController
    
    // MARK: - Public Properties
    
    var monthViews: [Int : CVCalendarMonthView]!
    
    // MARK: - Private Properties
    
    private var lastContentOffset: CGFloat = 0
    private var page: Int = 1
    private var pageChanged = false
    private var pageLoadingEnabled = true
    private var direction: ScrollDirection = .None
    
    private let controller: CVCalendarContentViewController!
    private let calendarView: CVCalendarView!
    private let presentedMonthView: CVCalendarMonthView!
    private let contentController: ContentController!
    private let scrollView: UIScrollView!
    
    // MARK: - Initialization
    
    init(contentController: ContentController) {
        super.init()
        
        self.contentController = contentController
        self.calendarView = contentController.calendarView
        self.presentedMonthView = contentController.presentedMonthView
        self.scrollView = contentController.preparedScrollView()
        
        self.monthViews = [Int : CVCalendarMonthView]()
        self.initialLoad(presentedMonthView)
        
        // Add the scroll view.
        calendarView.addSubview(scrollView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Insertion & Removing
    
    func insertMonthView(monthView: CVCalendarMonthView, atIndex index: Int) {
        let x = scrollView.bounds.width * CGFloat(index)
        let y = CGFloat(0)
        
        monthView.frame.origin = CGPointMake(x, y)
        
        monthViews.updateValue(monthView, forKey: index)
        
        scrollView.addSubview(monthView)
    }
    
    // MARK: - Motion control
    
    func _scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.prepareTopMarkersOnDayViews(self.monthViews![1]!, hidden: true)
    }
    
    func _scrollViewDidScroll(scrollView: UIScrollView) {
        let width = scrollView.frame.width
        
        let page = Int(floor((scrollView.contentOffset.x - width/2) / width) + 1)
        if page != self.page {
            self.page = page
            
            if !self.pageChanged {
                self.pageChanged = true
            } else {
                self.pageChanged = false
            }
        }
        
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0)
        }
        
        if self.lastContentOffset > scrollView.contentOffset.x {
            self.direction = .Right
        } else if self.lastContentOffset < scrollView.contentOffset.x {
            self.direction = .Left
        }
        
        self.lastContentOffset = scrollView.contentOffset.x
    }
    
    func _scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if self.pageChanged {
            if self.direction == .Left {
                if self.monthViews![0] != nil {
                    self.scrolledLeft()
                }
            } else if self.direction == .Right {
                if self.monthViews![2] != nil {
                    self.scrolledRight()
                }
            }
        }
        
        self.pageChanged = false
        self.pageLoadingEnabled = true
        self.direction = .None
        
        self.prepareTopMarkersOnDayViews(self.monthViews![0]!, hidden: false)
        self.prepareTopMarkersOnDayViews(self.monthViews![1]!, hidden: false)
        self.prepareTopMarkersOnDayViews(self.monthViews![2]!, hidden: false)
        
        self.calendarView!.presentedDate = CVDate(date: self.monthViews![1]!.date!)
    }
    
    // MARK: - Page control
    
    func initialLoad(presentedMonthView: CVCalendarMonthView) {
        let previousMonth = self.getPreviousMonth(presentedMonthView.date!)
        let nextMonth = self.getNextMonth(presentedMonthView.date!)
        
        self.monthViews!.updateValue(previousMonth, forKey: 0)
        self.monthViews!.updateValue(presentedMonthView, forKey: 1)
        self.monthViews!.updateValue(nextMonth, forKey: 2)
        
        self.insertMonthView(previousMonth, atIndex: self.page - 1)
        self.insertMonthView(presentedMonthView, atIndex: self.page)
        self.insertMonthView(nextMonth, atIndex: self.page + 1)
        
        self.calendarView!.presentedDate = CVDate(date: presentedMonthView.date!)
    }
    
    func replaceMonthView(monthView: CVCalendarMonthView, toPage page: Int, animatable: Bool) {
        var frame = monthView.frame
        frame.origin.x = frame.width * CGFloat(page)
        monthView.frame = frame
        if animatable {
            scrollView.scrollRectToVisible(frame, animated: false)
        }
    }
    
    // MARK: - Date preparation
    
    func getNextMonth(date: NSDate) -> CVCalendarMonthView {
        let calendar = NSCalendar.currentCalendar()
        let calendarManager = CVCalendarManager.sharedManager
        
        let firstDate = calendarManager.monthDateRange(date).monthStartDate
        
        let components = CVCalendarManager.sharedManager.componentsForDate(firstDate)
        components.month += 1
        
        let _date = calendar.dateFromComponents(components)!
        
        let frame = CGRectMake(0, 0, scrollView.frame.width, scrollView.frame.height)
        let monthView = CVCalendarMonthView(calendarView: self.calendarView!, date: _date)
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    func getPreviousMonth(date: NSDate) -> CVCalendarMonthView {
        let calendar = NSCalendar.currentCalendar()
        let calendarManager = CVCalendarManager.sharedManager
        
        let firstDate = calendarManager.monthDateRange(date).monthStartDate
        
        let components = CVCalendarManager.sharedManager.componentsForDate(firstDate)
        components.month -= 1
        
        let _date = calendar.dateFromComponents(components)!
        
        let frame = CGRectMake(0, 0, scrollView.frame.width, scrollView.frame.height)
        let monthView = CVCalendarMonthView(calendarView: self.calendarView!, date: _date)
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    // MARK: - Page loading on scrolling
    
    func scrolledLeft() {
        if self.page != 1 && self.pageLoadingEnabled {
            self.pageLoadingEnabled = false
            
            let leftMonthView = self.monthViews![1]
            let presented = self.monthViews![2]
            let date = presented!.date!
            
            self.replaceMonthView(leftMonthView!, toPage: 0, animatable: false)
            self.replaceMonthView(presented!, toPage: 1, animatable: true)
            
            var extraMonthView: CVCalendarMonthView? = self.monthViews!.removeValueForKey(0)
            extraMonthView!.removeFromSuperview()
            extraMonthView!.destroy()
            extraMonthView = nil
            
            let rightMonthView = self.getNextMonth(date)
            
            self.monthViews!.updateValue(leftMonthView!, forKey: 0)
            self.monthViews!.updateValue(presented!, forKey: 1)
            self.monthViews!.updateValue(rightMonthView, forKey: 2)
            
            self.insertMonthView(rightMonthView, atIndex: 2)
        }
    }
    
    func scrolledRight() {
        if self.page != 1 && self.pageLoadingEnabled {
            self.pageLoadingEnabled = false
            
            let rightMonthView = self.monthViews![1]
            let presented = self.monthViews![0]
            let date = presented!.date!
            
            self.replaceMonthView(rightMonthView!, toPage: 2, animatable: false)
            self.replaceMonthView(presented!, toPage: 1, animatable: true)
            
            var extraMonthView: CVCalendarMonthView? = self.monthViews!.removeValueForKey(2)
            extraMonthView!.removeFromSuperview()
            extraMonthView!.destroy()
            extraMonthView = nil
            
            let leftMonthView = self.getPreviousMonth(date)
            
            self.monthViews!.updateValue(leftMonthView, forKey: 0)
            self.monthViews!.updateValue(presented!, forKey: 1)
            self.monthViews!.updateValue(rightMonthView!, forKey: 2)
            
            self.insertMonthView(leftMonthView, atIndex: 0)
        }
    }
    

    
    // MARK: - Visual preparation
    
    func prepareTopMarkersOnDayViews(monthView: CVCalendarMonthView, hidden: Bool) {
        let weekViews = monthView.weekViews!
        
        for week in weekViews {
            let dayViews = week.dayViews!
            
            for day in dayViews {
                day.topMarker?.hidden = hidden
            }
        }
    }
    
    func _updateDayViews(hidden: Bool) {
        let values = self.monthViews!.values
        for monthView in values {
            let weekViews = monthView.weekViews!
            for weekView in weekViews {
                let dayViews = weekView.dayViews!
                for dayView in dayViews {
                    if dayView.isOut {
                        if !hidden {
                            dayView.alpha = 0
                            dayView.hidden = false
                        }
                        
                        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                            if hidden {
                                dayView.alpha = 0
                            } else {
                                dayView.alpha = 1
                            }
                            
                            }, completion: { (finished) -> Void in
                                if hidden {
                                    dayView.hidden = true
                                    dayView.alpha = 1
                                }
                        })
                    }
                }
            }
        }
    }
    
    // MARK: - Frame management
    
    func _updateFrames() {
        let frame = scrollView.frame
        
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        
        let monthViews = self.monthViews!.values
        for monthView in monthViews {
            monthView.reloadWeekViewsWithMonthFrame(frame)
        }
        
        replaceMonthViewsOnReload()
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 3, scrollView.frame.size.height)
        
        let presentedMonthView = self.monthViews![1]!
        scrollView.scrollRectToVisible(presentedMonthView.frame, animated: false)
        
    }
    
    func replaceMonthViewsOnReload() {
        let keys = self.monthViews!.keys
        for key in keys {
            let monthView = self.monthViews![key]!
            monthView.frame.origin.x = CGFloat(key) * scrollView.frame.width
            scrollView.addSubview(monthView)
        }
    }
    
    // MARK: - Day View Out selection
    
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
    
    func selectDayViewWithDay(day: Int, inMonthView monthView: CVCalendarMonthView) {
        let coordinator = CVCalendarDayViewControlCoordinator.sharedControlCoordinator
        for weekView in monthView.weekViews! {
            for dayView in weekView.dayViews! {
                if dayView.date?.day == day && !dayView.isOut {
                    coordinator.performDayViewSelection(dayView)
                }
            }
        }
    }
    
    func _performedDayViewSelection(dayView: CVCalendarDayView) {
        if dayView.isOut {
            if dayView.date?.day > 20 {
                let presentedDate = dayView.weekView!.monthView!.date!
                self.calendarView!.presentedDate = CVDate(date: self.dateBeforeDate(presentedDate))
                
                self.presentPreviousMonthView(dayView)
                
            } else {
                let presentedDate = dayView.weekView!.monthView!.date!
                self.calendarView!.presentedDate = CVDate(date: self.dateAfterDate(presentedDate))
                self.presentNextMonthView(dayView)
            }
        }
    }
    
    func presentNextMonthView(dayView: CVCalendarDayView?) {
        var extraMonthView = self.monthViews![0]
        let leftMonthView = self.monthViews![1]!
        let presentedMonthView = self.monthViews![2]!
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.prepareTopMarkersOnDayViews(leftMonthView, hidden: true)
            
            extraMonthView!.frame.origin.x -= self.scrollView.frame.width
            leftMonthView.frame.origin.x -= self.scrollView.frame.width
            presentedMonthView.frame.origin.x -= self.scrollView.frame.width
            
            }, completion: { (finished) -> Void in
                extraMonthView!.removeFromSuperview()
                extraMonthView!.destroy()
                extraMonthView = nil
                
                let rightMonthView = self.getNextMonth(presentedMonthView.date!)
                
                self.monthViews?.updateValue(leftMonthView, forKey: 0)
                self.monthViews?.updateValue(presentedMonthView, forKey: 1)
                self.monthViews?.updateValue(rightMonthView, forKey: 2)
                
                self.insertMonthView(rightMonthView, atIndex: 2)
                
                var day = 1
                if dayView != nil {
                    day = dayView!.date!.day!
                }
                
                self.selectDayViewWithDay(day, inMonthView: presentedMonthView)
                
                self.prepareTopMarkersOnDayViews(self.monthViews![0]!, hidden: false)
                self.prepareTopMarkersOnDayViews(self.monthViews![1]!, hidden: false)
                self.prepareTopMarkersOnDayViews(self.monthViews![2]!, hidden: false)
        })
    }
    
    func presentPreviousMonthView(dayView: CVCalendarDayView?) {
        
        var extraMonthView = self.monthViews!.removeValueForKey(2)
        let rightMonthView = self.monthViews![1]!
        let presentedMonthView = self.monthViews![0]!
        
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.prepareTopMarkersOnDayViews(rightMonthView, hidden: true)
            
            extraMonthView!.frame.origin.x += self.scrollView.frame.width
            rightMonthView.frame.origin.x += self.scrollView.frame.width
            presentedMonthView.frame.origin.x += self.scrollView.frame.width
            
            
            
            }, completion: { (finished) -> Void in
                
                extraMonthView!.removeFromSuperview()
                extraMonthView!.destroy()
                extraMonthView = nil
                
                let leftMonthView = self.getPreviousMonth(presentedMonthView.date!)
                
                self.monthViews?.updateValue(leftMonthView, forKey: 0)
                self.monthViews?.updateValue(presentedMonthView, forKey: 1)
                self.monthViews?.updateValue(rightMonthView, forKey: 2)
                
                self.insertMonthView(leftMonthView, atIndex: 0)
                
                var day = 1
                if dayView != nil {
                    day = dayView!.date!.day!
                }
                
                self.selectDayViewWithDay(day, inMonthView: presentedMonthView)
                
                self.prepareTopMarkersOnDayViews(self.monthViews![0]!, hidden: false)
                self.prepareTopMarkersOnDayViews(self.monthViews![1]!, hidden: false)
                self.prepareTopMarkersOnDayViews(self.monthViews![2]!, hidden: false)
        })
    }
    
    // MARK: - Month Views' toggling
    
    private var togglingBlocked = false
    func _togglePresentedDate(date: NSDate) {
        var currentMonthView = self.monthViews![1]
        let currentDate = currentMonthView!.date!
        
        if !self.date(currentDate, equalToPresentedDate: date) && !self.togglingBlocked {
            self.togglingBlocked = true
            let rightMonthView = self.getNextMonth(date)
            let leftMonthView = self.getPreviousMonth(date)
            
            var extraLeftMonthView = self.monthViews!.removeValueForKey(0)
            var extraRightMonthView = self.monthViews!.removeValueForKey(2)
            
            extraLeftMonthView?.removeFromSuperview()
            extraLeftMonthView?.destroy()
            extraLeftMonthView = nil
            
            extraRightMonthView?.removeFromSuperview()
            extraRightMonthView?.destroy()
            extraRightMonthView = nil
            
            let presentedMonthView = CVCalendarMonthView(calendarView: self.calendarView!, date: date)
            let frame = CGRectMake(0, 0, scrollView.frame.width, scrollView.frame.height)
            presentedMonthView.updateAppearance(frame)
            presentedMonthView.alpha = 0
            
            self.insertMonthView(presentedMonthView, atIndex: 1)
            
            UIView.animateWithDuration(0.8, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                presentedMonthView.alpha = 1
                currentMonthView?.alpha = 0
                }) { (finished) -> Void in
                    self.monthViews!.removeValueForKey(1)
                    currentMonthView!.removeFromSuperview()
                    currentMonthView!.destroy()
                    currentMonthView = nil
                    
                    self.monthViews!.updateValue(leftMonthView, forKey: 0)
                    self.monthViews!.updateValue(presentedMonthView, forKey: 1)
                    self.monthViews!.updateValue(rightMonthView, forKey: 2)
                    
                    self.insertMonthView(leftMonthView, atIndex: 0)
                    self.insertMonthView(rightMonthView, atIndex: 2)
                    
                    let presentedDate = CVDate(date: date)
                    self.calendarView!.presentedDate = presentedDate
                    
                    if self.date(date, equalToPresentedDate: NSDate()) {
                        self.selectDayViewWithDay(presentedDate.day!, inMonthView: presentedMonthView)
                    } else {
                        let day = CVCalendarManager.sharedManager.dateRange(date).day
                        self.selectDayViewWithDay(day, inMonthView: presentedMonthView)
                    }
                    
                    
                    self.togglingBlocked = false
            }
        }
    }
    
    func date(currentDate: NSDate, equalToPresentedDate presentedDate: NSDate) -> Bool {
        let calendarManager = CVCalendarManager.sharedManager
        
        let currentDateMonthStartDate = calendarManager.monthDateRange(currentDate).monthStartDate
        let presentedDateMonthStartDate = calendarManager.monthDateRange(presentedDate).monthStartDate
        
        if currentDateMonthStartDate == presentedDateMonthStartDate {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Content View Delegate
    
    func updateFrames() {
        _updateFrames()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        _scrollViewWillBeginDragging(scrollView)
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        _scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        _scrollViewDidEndDecelerating(scrollView)
    }
    
    func performedDayViewSelection(dayView: CVCalendarDayView) {
        _performedDayViewSelection(dayView)
    }
    
    func presentNextView(dayView: DayView?) {
        presentNextMonthView(dayView)
    }
    
    func presentPreviousView(dayView: DayView?) {
        presentPreviousMonthView(dayView)
    }
    
    func updateDayViews(hidden: Bool) {
        _updateDayViews(hidden)
    }
    
    func togglePresentedDate(date: NSDate) {
        _togglePresentedDate(date)
    }
}
