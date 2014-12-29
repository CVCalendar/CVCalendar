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
    var monthViews: [CVCalendarMonthView]?
    var page: Int = 1
    
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
        self.showsHorizontalScrollIndicator = false
        self.pagingEnabled = true
        self.delegate = self
        
        self.monthViews = [CVCalendarMonthView]()
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
        }
        
        if self.lastContentOffset > scrollView.contentOffset.x {
            self.direction = .Right
        } else if self.lastContentOffset < self.contentOffset.x {
            self.direction = .Left
        }
        
        self.lastContentOffset = scrollView.contentOffset.x
    }
    
    // MARK: - Page control
    
    func initialLoad() {
        let previousMonth = self.getPreviousMonth()
        let nextMonth = self.getNextMonth()
        
        self.monthViews?.append(previousMonth)
        self.monthViews?.append(nextMonth)
        self.monthViews?.append(self.presentedMonthView!)
        
        self.insertMonthView(previousMonth, atIndex: self.page - 1)
        self.insertMonthView(self.presentedMonthView!, atIndex: self.page)
        self.insertMonthView(nextMonth, atIndex: self.page + 1)
    }
    
    // TODO: Add Month Views on the content view
    
    func getNextMonth() -> CVCalendarMonthView {
        let calendar = NSCalendar.currentCalendar()
        let components = CVCalendarManager.sharedManager.componentsForDate(self.presentedDate!)
        components.month += 1
        
        let date = calendar.dateFromComponents(components)!
        
        let monthView = CVCalendarMonthView(calendarView: self.calendarView!, date: date)
        monthView.updateAppearance(self.presentedMonthView!.frame)
        
        return monthView
    }
    
    func getPreviousMonth() -> CVCalendarMonthView {
        let calendar = NSCalendar.currentCalendar()
        let components = CVCalendarManager.sharedManager.componentsForDate(self.presentedDate!)
        components.month -= 1
        
        let date = calendar.dateFromComponents(components)!
        
        let monthView = CVCalendarMonthView(calendarView: self.calendarView!, date: date)
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
        println("Page = \(page)")
        let leftMonthView = self.presentedMonthView!
        self.presentedMonthView = self.monthViews![self.page]
        self.presentedDate = self.presentedMonthView!.date!
        
        let extraMonthView = self.monthViews!.removeAtIndex(0) as CVCalendarMonthView
        extraMonthView.removeFromSuperview()
        
        
        
        self.replaceMonthView(self.presentedMonthView!, toPage: 1, animatable: true)
        self.replaceMonthView(leftMonthView, toPage: 0, animatable: false)
        
        let rightMonthView = self.getNextMonth()
        self.monthViews?.append(rightMonthView)
        self.insertMonthView(rightMonthView, atIndex: 2)
        
        println("MonthViews count: \(monthViews!.count)")
    }
    
    func scrolledRight() {
        
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        println("scrollViewWillBeginDecelerating")
    }

    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if self.direction == .Left {
            self.scrolledLeft()
            
            self.direction = .None
        } else if self.direction == .Right {
            
        }
        
        
    }
    
}
