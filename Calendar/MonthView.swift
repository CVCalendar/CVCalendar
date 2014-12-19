//
//  MonthView.swift
//  Calendar
//
//  Created by E. Mozharovsky on 12/15/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class MonthView: UIView {
    let calendarView: CalendarView?
    
    var date: NSDate?
    var weekdaysIn: [Int : [Int]]?
    var weekdaysOut: [Int : [Int]]?
    
    lazy var calendarViewData: CalendarViewData = {
       return self.calendarView!.data!
    }()
    
    var weekViews: [WeekView]?
    var weeks: [[Int]]?
    
    lazy var countOfWeeks: Int? = {
        if let _weeks = self.calendarView?.data?.numberOfWeeks {
            return _weeks
        } else {
            return 0
        }
    }()
    
    init(calendarView: CalendarView, date: NSDate) {
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
        self.weekdaysIn = self.calendarView?.calendarManager.sortedWeekdaysForDate(self.date!).weekdaysIn

        if self.calendarViewData.shouldShowDaysOut! {
            self.weekdaysOut = self.calendarView?.calendarManager.sortedWeekdaysForDate(self.date!).weekdaysOut
        }
        
        self.frame = CGRectMake(0, 0, self.calendarView!.frame.width, self.calendarView!.frame.height)
        self.makeWeekViews()
    }
    
    // MARK: - Weeks making
    
    func makeWeekViews() {
        self.weekViews = [WeekView]()
        for i in 0..<self.countOfWeeks! {
            let week = WeekView(monthView: self, index: i)
            self.weekViews?.append(week)
            self.addSubview(week)
        }
        
        self.makeWeekFrames()
    }
    
    func makeWeekFrames() {
        if let weeks = self.weekViews {

            let width = CGFloat(self.calendarView!.frame.width)
            let space = CGFloat(self.calendarViewData.verticalSpaceBetweenWeekViews!)
            var height: CGFloat
            var y: CGFloat = 0
            var x: CGFloat = 0
            
            let weekHeight = self.calendarViewData.weekViewHeight!
            let symbolsHeight = self.calendarViewData.symbolsHeight!
            
            for i in 0..<weeks.count {
                let week = weeks[i]
                
                if i != 0 {
                    height = CGFloat(weekHeight)
                    
                    if i == 1 {
                        y += CGFloat(symbolsHeight)
                    } else {
                        y += CGFloat(weekHeight)
                    }
                } else {
                    height = CGFloat(symbolsHeight)
                    y = 0
                }
                
                y += space
                week.frame = CGRectMake(x, y, width, height)
            }
        }
    }
    
}
