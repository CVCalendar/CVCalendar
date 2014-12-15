//
//  WeekView.swift
//  Calendar
//
//  Created by E. Mozharovsky on 12/15/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class WeekView: UIView {
    let index: Int?
    let monthView: MonthView?
    var days: [DayView]?
    
    lazy var calendarViewData: CalendarViewData = {
        return self.monthView!.calendarViewData
    }()
    
    init(monthView: MonthView, index: Int) {
        super.init()
        
        self.monthView = monthView
        self.index = index
        self.frame = self.makeFrame()
        self.makeDayViews()
        
        self.backgroundColor = UIColor.greenColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.makeDayViews()
    }
    
    func makeFrame() -> CGRect {
        let width = CGFloat(self.monthView!.calendarView!.frame.width)
        let height = CGFloat(self.calendarViewData.weekViewHeight!)
        let space = CGFloat(self.calendarViewData.verticalSpaceBetweenWeekViews!)
        
        var y = CGFloat(self.index!) * (height + space) + space/2
        
        let frame = CGRectMake(0, y, width, height)
        
        return frame
    }

    // MARK: - Day View build
    
    func makeDayViews() {
        println("Creating days...")
        
        self.days = [DayView]()
        for i in 0..<7 {
            let day = DayView(weekView: self, indexPath: NSIndexPath(forRow: i, inSection: self.index!))
            self.addSubview(day)
        }
    }
}
