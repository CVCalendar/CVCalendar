//
//  CVCalendarContentView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarContentView: UIScrollView, UIScrollViewDelegate {
    
    var lastContentOffset: CGFloat = 0
    var monthViews: [CVCalendarMonthView]?
    var page = 1
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
        let width = self.contentSize.width / CGFloat(self.monthViews!.count)
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
            // right
        } else if self.lastContentOffset < self.contentOffset.x {
            // left
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
        self.insertMonthView(nextMonth, atIndex: self.page + 1)
        self.insertMonthView(self.presentedMonthView!, atIndex: self.page)
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
}
