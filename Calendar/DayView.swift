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
    var indexPath: NSIndexPath?
    var dateLabel: UILabel?
    
    lazy var calendarViewData: CalendarViewData = {
       return self.weekView!.calendarViewData
    }()

    init(weekView: WeekView, indexPath: NSIndexPath) {
        super.init()
        
        self.weekView = weekView
        self.indexPath = indexPath
        self.backgroundColor = UIColor.yellowColor()
        
        self.frame = self.makeFrame()
        
        self.dateLabel = UILabel()
        self.dateLabel?.text = "Test"
        self.dateLabel?.textAlignment = NSTextAlignment.Center
        self.dateLabel?.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        
        self.addSubview(self.dateLabel!)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeFrame() -> CGRect {
        let space = CGFloat(self.calendarViewData.horizontalSpaceBetweenDayViews!)
        let height = CGFloat(self.calendarViewData.weekViewHeight!)
        let width = CGFloat(self.calendarViewData.dayViewWidth!)
        
        let x = CGFloat(self.indexPath!.row) * (width + space) + space/2
        
        return CGRectMake(x, 0, width, height)
    }
}
