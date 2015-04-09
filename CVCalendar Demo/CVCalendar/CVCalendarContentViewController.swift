//
//  CVCalendarContentViewController.swift
//  CVCalendar Demo
//
//  Created by E. Mozharovsky on 1/28/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

class CVCalendarContentViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Public Properties
    let calendarView: CalendarView
    var presentedMonthView: MonthView
    var bounds: CGRect {
        return scrollView.bounds
    }
    
    // MARK: - Private Properties
    private let scrollView: UIScrollView
    private var delegate: ContentDelegate!

    // MARK: - Initialization 
    
    init(calendarView: CalendarView, frame: CGRect) {
        self.calendarView = calendarView
        scrollView = UIScrollView(frame: frame)
        presentedMonthView = MonthView(calendarView: calendarView, date: NSDate())
        
        super.init(nibName: nil, bundle: nil)
        
        // Setup Scroll View. 
        scrollView.contentSize = CGSizeMake(frame.width * 3, frame.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        
        
        if calendarView.calendarMode == CalendarMode.MonthView {
            delegate = MonthContentView(contentController: self)
        } else {
            delegate = WeekContentView(contentController: self)
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Control 
    
    func preparedScrollView() -> UIScrollView {
        return scrollView
    }
    
    // MARK: - Appearance Update 
    
    func updateFrames(frame: CGRect) {
        presentedMonthView.updateAppearance(frame)
        
        scrollView.frame = frame
        scrollView.contentSize = CGSizeMake(frame.size.width * 3, frame.size.height)
        
        delegate.updateFrames()
        
        calendarView.hidden = false
    }
    
    // MARK: - Scroll View Delegate 
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        delegate.scrollViewDidScroll!(scrollView)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate.scrollViewWillBeginDragging!(scrollView)
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        delegate.scrollViewDidEndDecelerating!(scrollView)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate.scrollViewDidEndDragging!(scrollView, willDecelerate: decelerate)
    }
    
    // MARK: - Day View Selection
    
    func performedDayViewSelection(dayView: DayView) {
        delegate.performedDayViewSelection(dayView)
    }
    
    // MARK: - Toggle Date
    
    func togglePresentedDate(date: NSDate) {
        delegate.togglePresentedDate(date)
    }
    
    // MARK: - Paging 
    
    func presentNextView(dayView: DayView?) {
        delegate.presentNextView(dayView)
    }
    
    func presentPreviousView(dayView: DayView?) {
        delegate.presentPreviousView(dayView)
    }
    
    // MARK: - Days Out Showing
    
    func updateDayViews(hidden: Bool) {
        delegate.updateDayViews(hidden)
    }
}
