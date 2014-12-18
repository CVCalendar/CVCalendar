//
//  DayView.swift
//  Calendar
//
//  Created by E. Mozharovsky on 12/15/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class DayView: UIView {

    var weekView: WeekView?
    var index: Int?
    var date: NSDate?
    var dateLabel: UILabel?
    var weekSymbols: Array<String>?
    
    lazy var calendarManager: CalendarManager = {
        return CalendarManager.sharedManager()
    }()
    
    lazy var calendarViewData: CalendarViewData = {
       return self.weekView!.calendarViewData
    }()

    
    init(weekView: WeekView, frame: CGRect, index: Int, date: NSDate) {
        super.init(frame: frame)
        
        self.weekView = weekView
        self.index = index
        self.date = date
        
        self.commonInit()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.backgroundColor = UIColor.colorFromCode(0x926CD6)
        self.alpha = 0.5
        
        self.dateLabel = UILabel()
        self.weekSymbols = (self.calendarManager.shortWeekdaySymbols() as [String])
        
        if let index = self.weekView?.index {
            if index == 0 {
                self.dateLabel?.text = self.weekSymbols![self.index!].uppercaseString
                self.dateLabel?.textAlignment = NSTextAlignment.Center
                
                self.dateLabel?.font = UIFont.boldSystemFontOfSize(10)
                self.backgroundColor = UIColor.clearColor()
            } else {
                self.dateLabel?.text = String(self.calendarManager.dateRange(self.date!).day)
                self.dateLabel?.font = UIFont.boldSystemFontOfSize(20)
                self.dateLabel?.textColor = UIColor.whiteColor()
            }
        }

        
        self.dateLabel?.textAlignment = NSTextAlignment.Center
        self.dateLabel?.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        
        self.addSubview(self.dateLabel!)
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
}
