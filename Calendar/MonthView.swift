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
    
    lazy var calendarViewData: CalendarViewData = {
       return self.calendarView!.data!
    }()
    
    var weeks: [WeekView]?
    
    lazy var countOfWeeks: Int? = {
        if let _weeks = self.calendarView?.data?.numberOfWeeks {
            return _weeks
        } else {
            return 0
        }
    }()
    
    init(calendarView: CalendarView) {
        super.init()
        
        self.calendarView = calendarView
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.frame = CGRectMake(0, 0, self.calendarView!.frame.width, self.calendarView!.frame.height)
        self.backgroundColor = UIColor.redColor()
        
        self.makeWeekViews()
    }
    
    // MARK: - Weeks build
    
    func makeWeekViews() {
        self.weeks = [WeekView]()
        for i in 0..<self.countOfWeeks! {
            let week = WeekView(monthView: self, index: i)
            self.weeks?.append(week)
            self.addSubview(week)
        }
    }
    
}
