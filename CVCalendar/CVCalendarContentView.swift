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
    
    var lastContentOffset: CGFloat = 0
    var monthViews: [Int : CVCalendarMonthView]?
    var page: Int = 1
    var pageChanged = false
    
    var direction: ScrollDirection = .None
    var presentedMonthView: CVCalendarMonthView?
    var presentedDate: NSDate?
    
    let calendarView: CVCalendarView?
    
    // MARK: - Initialization
   
    override init() {
        super.init()
    }
    
    init(frame: CGRect, calendarView: CVCalendarView, presentedMonthView: CVCalendarMonthView) {
        super.init(frame: frame)
        
        self.calendarView = calendarView
        
        self.contentSize = CGSizeMake(self.frame.width * 3, self.frame.height)
        self.showsHorizontalScrollIndicator = true
        self.pagingEnabled = true
        self.delegate = self
        
        self.monthViews = [Int : CVCalendarMonthView]()
        self.presentedMonthView = presentedMonthView
        self.presentedDate = self.presentedMonthView!.date!
        
        self.initialLoad()
        scrollRectToVisible(self.presentedMonthView!.frame, animated: false)
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
            
        } else {
            // TODO: make top markers on current page hidden
        }
        
        if self.lastContentOffset > scrollView.contentOffset.x {
            self.direction = .Right
        } else if self.lastContentOffset < self.contentOffset.x {
            self.direction = .Left
        }
        
        self.lastContentOffset = scrollView.contentOffset.x
    }
    
    func preloadMonthView() -> CVCalendarMonthView {
        var preloadedMonthView: CVCalendarMonthView? = nil
        let date = self.presentedDate!
        
        if self.direction == .Right {
            let nextMonth = self.getNextMonth(date)
            preloadedMonthView = nextMonth
        } else if self.direction == .Left {
            let previousMonth = self.getPreviousMonth(date)
            preloadedMonthView = previousMonth
        }

        return preloadedMonthView!
    }
    
    // MARK: - Page control
    
    func initialLoad() {
        let previousMonth = self.getPreviousMonth(self.presentedDate!)
        let nextMonth = self.getNextMonth(self.presentedDate!)
        
        self.monthViews!.updateValue(previousMonth, forKey: 0)
        self.monthViews!.updateValue(self.presentedMonthView!, forKey: 1)
        self.monthViews!.updateValue(nextMonth, forKey: 2)
        
        self.insertMonthView(previousMonth, atIndex: self.page - 1)
        self.insertMonthView(self.presentedMonthView!, atIndex: self.page)
        self.insertMonthView(nextMonth, atIndex: self.page + 1)
    }
    
    func getNextMonth(date: NSDate) -> CVCalendarMonthView {
        let calendar = NSCalendar.currentCalendar()
        let calendarManager = CVCalendarManager.sharedManager
        
        let firstDate = calendarManager.monthDateRange(date).monthStartDate
        
        let components = CVCalendarManager.sharedManager.componentsForDate(firstDate)
        components.month += 1
        
        let _date = calendar.dateFromComponents(components)!
        
        let monthView = CVCalendarMonthView(calendarView: self.calendarView!, date: _date)
        monthView.updateAppearance(self.presentedMonthView!.frame)
        
        return monthView
    }
    
    func getPreviousMonth(date: NSDate) -> CVCalendarMonthView {
        let calendar = NSCalendar.currentCalendar()
        let calendarManager = CVCalendarManager.sharedManager
        
        let firstDate = calendarManager.monthDateRange(date).monthStartDate
        
        let components = CVCalendarManager.sharedManager.componentsForDate(firstDate)
        components.month -= 1
        
        let _date = calendar.dateFromComponents(components)!
        
        let monthView = CVCalendarMonthView(calendarView: self.calendarView!, date: _date)
        monthView.updateAppearance(self.presentedMonthView!.frame)
        
        return monthView
    }
    
    func replaceMonthView(monthView: CVCalendarMonthView, toPage page: Int, animatable: Bool) {
        var frame = monthView.frame
        frame.origin.x = frame.width * CGFloat(page)
        monthView.frame = frame
        if animatable {
           self.scrollRectToVisible(frame, animated: false)
        }
    }
    
    func scrolledLeft() {
        if self.page != 1 {
            println("Scrolled to LEFT: Page = \(page)")
            
            let leftMonthView = self.presentedMonthView!
            self.presentedMonthView = self.monthViews![self.page]
            self.presentedDate = self.presentedMonthView!.date!
            
            self.replaceMonthView(leftMonthView, toPage: 0, animatable: false)
            self.replaceMonthView(self.presentedMonthView!, toPage: 1, animatable: true)
            
            var extraMonthView: CVCalendarMonthView? = self.monthViews!.removeValueForKey(0)
            extraMonthView!.removeFromSuperview()
            extraMonthView!.destroy()
            extraMonthView = nil
            
            let rightMonthView = self.preloadMonthView()
            
            self.monthViews!.updateValue(leftMonthView, forKey: 0)
            self.monthViews!.updateValue(self.presentedMonthView!, forKey: 1)
            self.monthViews!.updateValue(rightMonthView, forKey: 2)
            
            self.insertMonthView(rightMonthView, atIndex: 2)
        }
    }
    
    func scrolledRight() {
        println("Scrolled to RIGHT: Page = \(page)")
        
        let rightMonthView = self.presentedMonthView!
        self.presentedMonthView = self.monthViews![self.page]
        self.presentedDate = self.presentedMonthView!.date!
        
        self.replaceMonthView(rightMonthView, toPage: 2, animatable: false)
        self.replaceMonthView(self.presentedMonthView!, toPage: 1, animatable: true)
        
        var extraMonthView: CVCalendarMonthView? = self.monthViews!.removeValueForKey(2)
        extraMonthView!.removeFromSuperview()
        extraMonthView!.destroy()
        extraMonthView = nil
        
        let leftMonthView = self.getPreviousMonth(self.presentedDate!)
        
        self.monthViews!.updateValue(leftMonthView, forKey: 0)
        self.monthViews!.updateValue(self.presentedMonthView!, forKey: 1)
        self.monthViews!.updateValue(rightMonthView, forKey: 2)
        
        
        self.insertMonthView(leftMonthView, atIndex: 0)
    }
    

    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        println("scrollViewDidEndDecelerating")
        
        if self.pageChanged {
            if self.direction == .Left {
                self.scrolledLeft()
            } else if self.direction == .Right {
                self.scrolledRight()
            }
        }

        self.pageChanged = false
        
        self.direction = .None
        println("Presented date month: \(CVCalendarManager.sharedManager.dateRange(self.presentedDate!).month)")
        
        // TODO: make top markers on current page visible
    }
    
}
