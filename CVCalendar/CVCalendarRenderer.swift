//
//  CVCalendarRenderer.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarRenderer: NSObject {
    
    private override init() {
        super.init()
    }
    
    class func sharedRenderer() -> CVCalendarRenderer {
        var _self: CVCalendarRenderer?
        
        var t: dispatch_once_t = 0
        dispatch_once(&t, { () -> Void in
            _self = CVCalendarRenderer()
        })
        
        return _self!
    }
    
    func renderWeekFrameForMonthView(monthView: CVCalendarMonthView, weekIndex: Int) -> CGRect {
        let appearance = monthView.calendarView!.appearance
        
        let width = monthView.frame.width
        let space = appearance.spaceBetweenWeekViews!
        var height = CGFloat((monthView.frame.height / CGFloat(monthView.numberOfWeeks!)) - space) + space / 0.5
        
        let y: CGFloat = CGFloat(weekIndex) * (height + space)
        let x: CGFloat = 0

        return CGRectMake(x, y, width, height)
    }
    
    func renderDayFrameForMonthView(weekView: CVCalendarWeekView, dayIndex: Int) -> CGRect {
        let appearance = weekView.monthView!.calendarView!.appearance
        
        let space = appearance.spaceBetweenDayViews!
        let width = CGFloat((weekView.frame.width / 7) - space)
        let height = weekView.frame.height
        
        let x = CGFloat(dayIndex) * (width + space) + space / 2
        let y = CGFloat(0)
        
        return CGRectMake(x, y, width, height)
    }

}
