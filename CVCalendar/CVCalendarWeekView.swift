//
//  CVCalendarWeekView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarWeekView: UIView {
    
    let monthView: CVCalendarMonthView?
    let index: Int?
    let weekdaysIn: [Int : [Int]]?
    let weekdaysOut: [Int : [Int]]?

    init(monthView: CVCalendarMonthView, frame: CGRect, index: Int) {
        super.init()
        
        self.monthView = monthView
        self.frame = frame
        self.index = index
        
        let weeksIn = self.monthView!.weeksIn!
        if self.index! < weeksIn.count {
            self.weekdaysIn = weeksIn[self.index!]
        }

        let weeksOut = self.monthView!.weeksOut!
        if self.index == 0 {
            self.weekdaysOut = weeksOut[1]
        } else if self.index == self.monthView!.numberOfWeeks! - 1 {
            self.weekdaysOut = weeksOut[0]
        }
        
        //self.backgroundColor = UIColor.redColor()
        println("Week #\(index) created successfully!")
        
        self.createDayViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createDayViews() {
        for i in 1...7 {
            let renderer = CVCalendarRenderer.sharedRenderer()
            let frame = renderer.renderDayFrameForMonthView(self, dayIndex: i-1)
            
            let dayView = CVCalendarDayView(weekView: self, frame: frame, weekdayIndex: i)
            self.addSubview(dayView)
        }
    }
    
}
