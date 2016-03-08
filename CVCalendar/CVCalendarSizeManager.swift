//
//  CVCalendarSizeManager.swift
//  CVCalendar Demo
//
//  Created by mac on 09/03/16.
//  Copyright © 2016 GameApp. All rights reserved.
//

import UIKit

public protocol CVCalendarSizeManagerType {
    var calendarView: CVCalendarView { get set }
    func monthViewSize(date: NSDate) -> CGSize
    func dayViewSize() -> CGSize
}

public extension CVCalendarSizeManagerType {
    func monthViewSize(date: NSDate) -> CGSize {
        let weeks = CGFloat(calendarView.manager.monthDateRange(date).numberOfWeeks)
        let offset = (calendarView.appearance.spaceBetweenWeekViews ?? 0) * 7
        return CGSize(width: calendarView.frame.width, height: dayViewSize().height * weeks + offset)
    }
    
    func dayViewSize() -> CGSize {
        let side = (min(calendarView.frame.width, calendarView.frame.height) / 7)
        
        print("Side = \((side))")
        
        let width = side - (calendarView.appearance.spaceBetweenDayViews ?? 0)
        let height = side - (calendarView.appearance.spaceBetweenWeekViews ?? 0) + (calendarView.delegate?.extraHeight?() ?? 0)
        
        return CGSize(width: width, height: height)
    }
}


public struct CVCalendarSizeManager: CVCalendarSizeManagerType {
    public var calendarView: CVCalendarView
    
    public var dayViewWidth: CGFloat {
        return (min(calendarView.frame.width, calendarView.frame.height) / 7) - (calendarView.appearance.spaceBetweenDayViews ?? 0)
    }
}