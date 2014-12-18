//
//  CalendarView.swift
//  Calendar
//
//  Created by E. Mozharovsky on 12/15/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CalendarView: UIView, CalendarViewDataSource, CalendarViewDelegate {
    var data: CalendarViewData?
    var date: NSDate?
    var monthView: MonthView?
    
    // Data Source
    var shouldShowDaysOut = true
    var presentedMode: CalendarViewMode? = .Month
    var firstWeekday: CalendarWeekday = .Sunday
    
    lazy var calendarManager: CalendarManager = {
        return CalendarManager.sharedManager()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        self.data = CalendarViewData(calendarView: self)
    }
    
    func completeInitializationOnAppearing() {
        if self.date == nil {
            self.date = NSDate()
        }
        
        self.data?.dataSource = self
        self.data?.delegate = self
        self.monthView = MonthView(calendarView: self)
        
        self.addSubview(self.monthView!)
        
        self.validateFrame()
    }
    
    func validateFrame() {
        let diff = (self.frame.height - CGFloat(self.data!.symbolsHeight! + self.data!.weekViewHeight! * Float(self.data!.numberOfWeeks! - 1) + self.data!.verticalSpaceBetweenWeekViews! * Float(self.data!.numberOfWeeks! + 1)))
        
        var frame = self.frame
        
        if diff < 0 {
            frame.size.height += abs(diff)
        } else if diff > 0 {
            frame.size.height -= diff
        }
        
        self.frame = frame
        
        if self.monthView?.frame != self.frame {
            self.monthView?.frame = CGRectMake(0, 0, frame.width, frame.height)
        }
        
        
        println("Diff is: \(diff)")
    }
    
    // MARK: - Calendar View Data Source 
    
    func calendarView(calendarViewData: CalendarViewData, numberOfDaysForCalendarView calendarView: CalendarView) -> Int {
        return self.calendarManager.dateRange(self.calendarManager.monthDateRange(self.date!).monthEndDate).day
    }

    func calendarView(calendarViewData: CalendarViewData, numberOfWeeksForCalendarView calendarView: CalendarView) -> Int {
        return self.calendarManager.monthDateRange(NSDate()).countOfWeeks + 1
    }
    
    func calendarView(calendarViewData: CalendarViewData, shouldShowDaysOutForCalendarView calendarView: CalendarView) -> Bool {
        return self.shouldShowDaysOut
    }
    
    func calendarView(calendarViewData: CalendarViewData, presentedModeForCalendarView calendarView: CalendarView) -> CalendarViewMode {
        return self.presentedMode!
    }
    
    // MARK: - Calendar View Delegate
    
    func calendarView(calendarViewData: CalendarViewData, firstWeekdayForCalendarView calendarView: CalendarView) -> Int {
        return CalendarWeekday.Sunday.rawValue
    }
}



