//
//  CVCalendarWeekContentView.swift
//  CVCalendar Demo
//
//  Created by E. Mozharovsky on 1/23/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

class CVCalendarWeekContentView: UIScrollView, UIScrollViewDelegate {

    // MARK: - Types work 
    
    typealias WeekView = CVCalendarWeekView
    typealias CalendarView = CVCalendarView
    typealias MonthView = CVCalendarMonthView
    typealias Manager = CVCalendarManager
    typealias Recovery = CVCalendarWeekContentRecovery
    typealias WeekContentView = CVCalendarWeekContentView
    
    // MARK: Public properties
    
    // Contains 3 loaded weekViews & monthViews { Previous | Current | Next }.
    var weekViews: [Int : WeekView]!
    
    // MARK: Private properties
    
    private var page: Int! = 1 // The current one.
    var presentedDate: NSDate!
    var presentedMonthView: MonthView!
    
    private let calendarView: CalendarView!
    
    // MARK: Initialization
    
    init(frame: CGRect, calendarView: CVCalendarView, presentedMonthView: CVCalendarMonthView) {
        super.init(frame: frame)
        
        println("Initilized")
        
        // Common init.
        contentSize = CGSizeMake(frame.width * 3, frame.height)
        showsHorizontalScrollIndicator = false 
        pagingEnabled = true
        delegate = self
        
        // Properties init.
        self.calendarView = calendarView
        self.presentedMonthView = presentedMonthView
        self.presentedDate = presentedMonthView.date!
        
        weekViews = [Int : WeekView]()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Frames Reload 
    
    func updateFrames(frame: CGRect) {
        self.frame = frame
        
        calendarView.hidden = false
        contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height)
        
        let countOfWeeks = CGFloat(presentedMonthView.weekViews!.count)
        let sizeConformedFrame = CGRectMake(0, 0, frame.width, frame.height * countOfWeeks)
        presentedMonthView.reloadWeekViewsWithMonthFrame(sizeConformedFrame)
        
        let presentedWeekView = self.presentedWeekView()
        let nextWeekView = self.nextWeekView(presentedWeekView)
        let previousWeekView = self.previousWeekView(presentedWeekView)
        
        insertWeekView(previousWeekView, atIndex: 0)
        insertWeekView(presentedWeekView, atIndex: 1)
        insertWeekView(nextWeekView, atIndex: 2)
        
        scrollRectToVisible(presentedWeekView.frame, animated: false)
        
        recovery.recoverMonthView(presentedMonthView, direction: direction)
    }
    
    // MARK: - Month Views Loading 
    
    private let calendar = NSCalendar.currentCalendar()
    private let manager = Manager.sharedManager
    
    func nextMonthView(date: NSDate) -> MonthView {
        let firstDate = manager.monthDateRange(date).monthStartDate
        
        let components = manager.componentsForDate(firstDate)
        components.month += 1
        
        let _date = calendar.dateFromComponents(components)!
        let countOfWeeks = CGFloat(manager.monthDateRange(_date).countOfWeeks)
        
        let frame = CGRectMake(0, 0, bounds.width, bounds.height * countOfWeeks)
        let monthView = MonthView(calendarView: self.calendarView!, date: _date)
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    func previousMonthView(date: NSDate) -> MonthView {
        let firstDate = manager.monthDateRange(date).monthStartDate
        
        let components = manager.componentsForDate(firstDate)
        components.month -= 1
        
        let _date = calendar.dateFromComponents(components)!
        let countOfWeeks = CGFloat(manager.monthDateRange(_date).countOfWeeks)
        
        let frame = CGRectMake(0, 0, bounds.width, bounds.height * countOfWeeks)
        let monthView = MonthView(calendarView: self.calendarView!, date: _date)
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    // MARK: - Week Views Loading 
    
    func presentedWeekView() -> WeekView {
        let components = manager.componentsForDate(presentedDate)
        let index = components.weekOfMonth - 1
        let weekView = presentedMonthView.weekViews![index]
        
        return weekView
    }
    
    func nextWeekView(weekView: WeekView) -> WeekView {
        let index = weekView.index! + 1
        let date = weekView.monthView!.date!
        let countOfWeeks = manager.monthDateRange(date).countOfWeeks
        
        var nextWeekView: WeekView!
        if index < countOfWeeks {
            let monthView = weekView.monthView!
            nextWeekView = monthView.weekViews![index]
        } else {
            let nextMonthView = self.nextMonthView(date)
            nextWeekView = nextMonthView.weekViews!.first!
        }
        
        return nextWeekView
    }
    
    func previousWeekView(weekView: WeekView) -> WeekView {
        let index = weekView.index! - 1
        let date = weekView.monthView!.date!
        let countOfWeeks = manager.monthDateRange(date).countOfWeeks
        
        var previousWeekView: WeekView!
        if index >= 0 {
            let monthView = weekView.monthView!
            previousWeekView = monthView.weekViews![index]
        } else {
            let previousMonthView = self.previousMonthView(date)
            previousWeekView = previousMonthView.weekViews!.last!
        }
        
        return previousWeekView
    }
    
    // MARK: Week Views Insertion 
    
    func insertWeekView(weekView: WeekView, atIndex index: Int) {
        let x = bounds.width * CGFloat(index)
        let y = CGFloat(0)
        
        weekView.frame.origin = CGPointMake(x, y)
        
        weekViews.updateValue(weekView, forKey: index)
        
        addSubview(weekView)
    }
    
    func replaceWeekView(weekView: WeekView, toPage page: Int, animatable: Bool) {
        var frame = self.frame
        frame.origin.x = frame.width * CGFloat(page)
        weekView.frame = frame
        
        if animatable {
            self.scrollRectToVisible(frame, animated: false)
        }
        
        weekViews.updateValue(weekView, forKey: page)
    }
    
    // MARK: - Scroll Pages Update
    
    private var pageLoadingEnabled = true
    private lazy var recovery: Recovery = {
        let _recovery = Recovery()
        _recovery.weekContentView = self
        return _recovery
    }()
    
    func scrolledLeft() {
        if self.page != 1 && self.pageLoadingEnabled {
            self.pageLoadingEnabled = false
            
            let leftWeekView = weekViews[1]!
            let presentedWeekView = weekViews[2]!
            let rightWeekView = self.nextWeekView(presentedWeekView)
            
            // Update presented month view.
            presentedMonthView = presentedWeekView.monthView!
            presentedDate = presentedMonthView.date!
            
            let extraWeekView = weekViews.removeValueForKey(0)!
            extraWeekView.removeFromSuperview()
            
            presentedWeekView.utilizable = true
            recovery.recoverMonthView(presentedWeekView.monthView!, direction: direction)
            
            replaceWeekView(leftWeekView, toPage: 0, animatable: false)
            replaceWeekView(presentedWeekView, toPage: 1, animatable: true)
            
            insertWeekView(rightWeekView, atIndex: 2)
        }
    }
    
    func scrolledRight() {
        if self.page != 1 && self.pageLoadingEnabled {
            self.pageLoadingEnabled = false
            
            let rightWeekView = weekViews[1]!
            let presentedWeekView = weekViews[0]!
            let leftWeekView = self.previousWeekView(presentedWeekView)
            
            // Update presented month view.
            presentedMonthView = presentedWeekView.monthView!
            presentedDate = presentedMonthView.date!
            
            let extraWeekView = weekViews.removeValueForKey(2)!
            extraWeekView.removeFromSuperview()
            
            presentedWeekView.utilizable = true
            recovery.recoverMonthView(presentedWeekView.monthView!, direction: direction)
            
            replaceWeekView(rightWeekView, toPage: 2, animatable: false)
            replaceWeekView(presentedWeekView, toPage: 1, animatable: true)
            
            insertWeekView(leftWeekView, atIndex: 0)
        }
    }
    
    // MARK: - Scroll View Motion
    
    private var pageChanged = false
    private var lastContentOffset: CGFloat = 0
    private var direction: ScrollDirection = .None
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        prepareTopMarkersOnDayViews(weekViews[1]!, hidden: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let width = self.frame.width
        
        let page = Int(floor((self.contentOffset.x - width/2) / width) + 1)
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
        } else if self.lastContentOffset < self.contentOffset.x {
            self.direction = .Left
        }
        
        self.lastContentOffset = scrollView.contentOffset.x
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if self.pageChanged {
            if self.direction == .Left {
                if self.weekViews[0] != nil {
                    self.scrolledLeft()
                }
            } else if self.direction == .Right {
                if self.weekViews[2] != nil {
                    self.scrolledRight()
                }
            }
        }
        
        self.pageChanged = false
        self.pageLoadingEnabled = true
        self.direction = .None
        
        self.prepareTopMarkersOnDayViews(self.weekViews[0]!, hidden: false)
        self.prepareTopMarkersOnDayViews(self.weekViews[1]!, hidden: false)
        self.prepareTopMarkersOnDayViews(self.weekViews[2]!, hidden: false)
        
        let presentedWeekView = weekViews[1]!
        let presentedMonthView = presentedWeekView.monthView?
        if presentedMonthView != nil {
            self.calendarView.presentedDate = CVDate(date: presentedMonthView!.date!)
        }
        
    }
    
    // MARK: - Day View Selection
    
    func performedDayViewSelection(dayView: CVCalendarDayView) {
        if dayView.isOut {
            if dayView.date?.day > 20 {
                let presentedDate = dayView.weekView!.monthView!.date!
                self.calendarView!.presentedDate = CVDate(date: self.dateBeforeDate(presentedDate))
                
                self.presentPreviousWeekView(dayView)
                
            } else {
                let presentedDate = dayView.weekView!.monthView!.date!
                self.calendarView!.presentedDate = CVDate(date: self.dateAfterDate(presentedDate))
                self.presentNextWeekView(dayView)
            }
        }
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
    
    // MARK: - Week View Slide
    
    func presentNextWeekView(dayView: CVCalendarDayView?) {
        let extraWeekView = weekViews.removeValueForKey(0)!
        let leftWeekView = weekViews[1]!
        let presentWeekView = weekViews[2]!
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.prepareTopMarkersOnDayViews(leftWeekView, hidden: true)
            
            extraWeekView.frame.origin.x -= self.bounds.width
            leftWeekView.frame.origin.x -= self.bounds.width
            presentWeekView.frame.origin.x -= self.bounds.width
            
            }, completion: { (finished) -> Void in
                
                extraWeekView.removeFromSuperview()
                presentWeekView.utilizable = true
                self.recovery.recoverMonthView(presentWeekView.monthView!, direction: self.direction)
                
                let rightWeekView = self.nextWeekView(presentWeekView)
                
                self.weekViews.updateValue(leftWeekView, forKey: 0)
                self.weekViews.updateValue(presentWeekView, forKey: 1)
                self.weekViews.updateValue(rightWeekView, forKey: 2)
                
                self.insertWeekView(rightWeekView, atIndex: 2)
                
                var day = 1
                if dayView != nil {
                    day = dayView!.date!.day!
                }
                
                self.selectDayViewWithDay(day, inMonthView: presentWeekView.monthView!)
                
                self.prepareTopMarkersOnDayViews(self.weekViews[0]!, hidden: false)
                self.prepareTopMarkersOnDayViews(self.weekViews[1]!, hidden: false)
                self.prepareTopMarkersOnDayViews(self.weekViews[2]!, hidden: false)
        })
    }
    
    func presentPreviousWeekView(dayView: CVCalendarDayView?) {
        
        let extraWeekView = weekViews.removeValueForKey(2)!
        let rightWeekView = weekViews[1]!
        let presentedWeekView = weekViews[0]!
        
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            presentedWeekView.utilizable = true
            self.prepareTopMarkersOnDayViews(rightWeekView, hidden: true)
            
            extraWeekView.frame.origin.x += self.bounds.width
            rightWeekView.frame.origin.x += self.bounds.width
            presentedWeekView.frame.origin.x += self.bounds.width
            
            
            }, completion: { (finished) -> Void in

                extraWeekView.removeFromSuperview()
                self.recovery.recoverMonthView(presentedWeekView.monthView!, direction: self.direction)
                
                let leftWeekView = self.previousWeekView(presentedWeekView)
                
                self.weekViews.updateValue(leftWeekView, forKey: 0)
                self.weekViews.updateValue(presentedWeekView, forKey: 1)
                self.weekViews.updateValue(rightWeekView, forKey: 2)
                
                self.insertWeekView(leftWeekView, atIndex: 0)
                
                var day = 1
                if dayView != nil {
                    day = dayView!.date!.day!
                }
                
                self.selectDayViewWithDay(day, inMonthView: presentedWeekView.monthView!)
                
                self.prepareTopMarkersOnDayViews(self.weekViews[0]!, hidden: false)
                self.prepareTopMarkersOnDayViews(self.weekViews[1]!, hidden: false)
                self.prepareTopMarkersOnDayViews(self.weekViews[2]!, hidden: false)
        })
    }
    
    // MARK: - Date Management 
    
    func dateBeforeDate(date: NSDate) -> NSDate {
        let components = manager.componentsForDate(date)
        components.month -= 1
        
        let dateBefore = calendar.dateFromComponents(components)!
        
        return dateBefore
    }
    
    func dateAfterDate(date: NSDate) -> NSDate {
        let components = manager.componentsForDate(date)
        components.month += 1
        
        let dateAfter = calendar.dateFromComponents(components)!
        
        return dateAfter
    }
    
    // MARK: - Visual Preparation 
    
    func prepareTopMarkersOnDayViews(weekView: WeekView, hidden: Bool) {
        if weekView.dayViews != nil {
            let dayViews = weekView.dayViews!
            
            for day in dayViews {
                day.topMarker?.hidden = hidden
            }
        } else {
            println("Week View = \(weekView)")
            println("Month Date = \(weekView.monthView?.date)")
        }
    }
    
    /**
        Updates showing days out. Invoke if you want to hide days out or on the contrary unhide.
    
        :param: hidden A mask indicating if days out are shown or not.
    */
    func updateDayViews(hidden: Bool) {
        for weekView in weekViews.values {
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
