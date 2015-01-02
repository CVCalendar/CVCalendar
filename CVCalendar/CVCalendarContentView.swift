//
//  CVCalendarContentView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

enum ScrollDirection {
    case None
    case Left
    case Right
}

class CVCalendarContentView: UIScrollView, UIScrollViewDelegate {
    
    private var lastContentOffset: CGFloat = 0
    private var monthViews: [Int : CVCalendarMonthView]?
    private var page: Int = 1
    private var pageChanged = false
    private var pageLoadingEnabled = true
    private var direction: ScrollDirection = .None
    private let calendarView: CVCalendarView?
    
    // MARK: - Initialization
   
    override init() {
        super.init()
    }
    
    init(frame: CGRect, calendarView: CVCalendarView, presentedMonthView: CVCalendarMonthView) {
        super.init(frame: frame)
        
        self.calendarView = calendarView
        
        self.frame = frame
        self.contentSize = CGSizeMake(self.frame.width * 3, self.frame.height)
        self.showsHorizontalScrollIndicator = false
        self.pagingEnabled = true
        self.delegate = self
        
        self.monthViews = [Int : CVCalendarMonthView]()
        self.initialLoad(presentedMonthView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Insertion & Removing
    
    func insertMonthView(monthView: CVCalendarMonthView, atIndex index: Int) {
        let width = self.contentSize.width / 3
        let height = self.frame.height
        let x = CGFloat(index) * width
        let y = CGFloat(0)
        
        let frame = CGRectMake(x, y, width, height)
        monthView.frame = frame
        
        self.addSubview(monthView)
    }
    
    // MARK: - Motion control
    
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
            self.scrollRectToVisible(frame, animated: false)
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
        
        let frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
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
        
        let frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
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
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
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
    
    // MARK: - Visual preparation
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.prepareTopMarkersOnDayViews(self.monthViews![1]!, hidden: true)
    }
    
    func prepareTopMarkersOnDayViews(monthView: CVCalendarMonthView, hidden: Bool) {
        let weekViews = monthView.weekViews!
        
        for week in weekViews {
            let dayViews = week.dayViews!
            
            for day in dayViews {
                day.topMarker?.hidden = hidden
            }
        }
    }
    
    func updateDayViews(hidden: Bool) {
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
    
    func updateFrames(frame: CGRect) {
        self.frame = frame
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        let monthViews = self.monthViews!.values
        for monthView in monthViews {
            monthView.reloadWeekViewsWithMonthFrame(frame)
        }
        self.replaceMonthViewsOnReload()
        
        self.calendarView?.hidden = false
        self.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height)
        
        let presentedMonthView = self.monthViews![1]!
        self.scrollRectToVisible(presentedMonthView.frame, animated: false)
        
    }
    
    func replaceMonthViewsOnReload() {
        let keys = self.monthViews!.keys
        for key in keys {
            let monthView = self.monthViews![key]!
            monthView.frame.origin.x = CGFloat(key) * self.frame.width
            self.addSubview(monthView)
        }
    }
}
