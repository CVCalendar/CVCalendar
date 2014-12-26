//
//  CVCalendarMonthView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarMonthView: UIView {

    var calendarView: CVCalendarView?
    var date: NSDate?
    var numberOfWeeks: Int?
    var menuView: CVCalendarMenuView?
    var weekViews: [CVCalendarWeekView]?
    
    var weeksIn: [[Int : [Int]]]?
    var weeksOut: [[Int : [Int]]]?
    
    var currentDay: Int?

    init(calendarView: CVCalendarView, date: NSDate) {
        super.init()
        
        self.calendarView = calendarView
        self.date = date
        
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        let calendarManager = CVCalendarManager.sharedManager()
        self.numberOfWeeks = calendarManager.monthDateRange(self.date!).countOfWeeks
        self.weeksIn = calendarManager.weeksWithWeekdaysForMonthDate(self.date!).weeksIn
        self.weeksOut = calendarManager.weeksWithWeekdaysForMonthDate(self.date!).weeksOut
        
        self.currentDay = calendarManager.dateRange(NSDate()).day
    }
    
    func updateAppearance(frame: CGRect) {
        self.frame = frame
        self.createWeekViews()
    }
    
    func createWeekViews() {
        let renderer = CVCalendarRenderer.sharedRenderer()
        
        for i in 0..<self.numberOfWeeks! {
            let frame = renderer.renderWeekFrameForMonthView(self, weekIndex: i)
            let weekView = CVCalendarWeekView(monthView: self, frame: frame, index: i)
            self.addSubview(weekView)
        }
    }
}
