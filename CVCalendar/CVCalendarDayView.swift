//
//  CVCalendarDayView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarDayView: UIView {

    let weekView: CVCalendarWeekView?
    let weekdayIndex: Int?
    let day: Int?
    
    let dayLabel: UILabel?
    
    var isOut = false
    var isCurrentDay = false
    
    init(weekView: CVCalendarWeekView, frame: CGRect, weekdayIndex: Int) {
        super.init()
        
        self.weekView = weekView
        self.frame = frame
        self.weekdayIndex = weekdayIndex
        
        func hasDayAtWeekdayIndex(weekdayIndex: Int, weekdaysDictionary: [Int : [Int]]) -> Bool {
            let keys = weekdaysDictionary.keys
            
            for key in keys.array {
                //println("Key: \(key), weekday index:\(weekdayIndex)")
                if key == weekdayIndex {
                    return true
                }
            }
            
            return false
        }
        
        let weekdaysIn = self.weekView!.weekdaysIn!
        if (self.weekView!.index == 0) || (self.weekView!.index == self.weekView!.monthView!.numberOfWeeks! - 1) {
            let weekdaysOut = self.weekView!.weekdaysOut!
            
            if hasDayAtWeekdayIndex(self.weekdayIndex!, weekdaysOut) {
                self.day = weekdaysOut[self.weekdayIndex!]![0]
                self.isOut = true
            } else {
                self.day = weekdaysIn[self.weekdayIndex!]![0]
            }
            
        } else {
            self.day = weekdaysIn[self.weekdayIndex!]![0]
        }
        
        if self.day == self.weekView!.monthView!.currentDay {
            self.isCurrentDay = true
        }
        

        // Label setup 
        let appearance = self.weekView!.monthView!.calendarView!.appearance
        
        self.dayLabel = UILabel()
        self.dayLabel!.text = String(self.day!)
        self.dayLabel!.textAlignment = NSTextAlignment.Center
        self.dayLabel!.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        
        var color: UIColor?
        if self.isOut {
            color = appearance.dayLabelWeekdayOutTextColor
        } else if self.isCurrentDay {
            color = appearance.dayLabelPresentWeekdayTextColor
        } else {
            color = appearance.dayLabelWeekdayInTextColor
        }
        
        var font: UIFont?
        if self.isCurrentDay {
            if appearance.dayLabelPresentWeekdayInitallyBold {
                font = UIFont.boldSystemFontOfSize(appearance.dayLabelPresentWeekdayTextSize!)
            } else {
                font = UIFont.systemFontOfSize(appearance.dayLabelPresentWeekdayTextSize!)
            }
        } else {
            font = UIFont.systemFontOfSize(appearance.dayLabelWeekdayTextSize!)
        }
        
        self.dayLabel!.textColor = color!
        self.dayLabel!.font = font
        
        self.addSubview(self.dayLabel!)
        
        // Sublayer setup
        let height = CGFloat(0.5)
        let layer = CALayer()
        layer.borderColor = UIColor.grayColor().CGColor
        layer.borderWidth = height
        layer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), height)
        
        self.layer.addSublayer(layer)
        
        
        //self.backgroundColor = UIColor.greenColor()
        println("Day #\(self.day!) in Week #\(self.weekView!.index!) successfully created!")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
