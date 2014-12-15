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
    var monthView: MonthView?
    
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
    
    func updateAppearance() {
        self.data?.dataSource = self
        self.data?.delegate = self
        self.monthView = MonthView(calendarView: self)
        self.addSubview(self.monthView!)
    }
    
    // MARK: - Calendar View Data Source 
    
    func calendarView(calendarViewData: CalendarViewData, numberOfDaysForCalendarView calendarView: CalendarView) -> Int {
        return 29
    }

    func calendarView(calendarViewData: CalendarViewData, numberOfWeeksForCalendarView calendarView: CalendarView) -> Int {
        return 5
    }
    
    func calendarView(calendarViewData: CalendarViewData, shouldShowDaysOutForCalendarView calendarView: CalendarView) -> Bool {
        return true
    }
    
    
    func calendarView(calendarViewData: CalendarViewData, presentedModeForCalendarView calendarView: CalendarView) -> CalendarViewMode {
        return .Month
    }
    
    // MARK: - Calendar View Delegate
    

    func calendarView(calendarViewData: CalendarViewData, firstWeekdayForCalendarView calendarView: CalendarView) -> Int {
        return CalendarWeekday.Sunday.rawValue
    }
}



