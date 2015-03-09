//
//  CVCalendarViewDelegate.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

@objc
protocol CVCalendarViewDelegate {
    func shouldShowWeekdaysOut() -> Bool
    
    func didSelectDayView(dayView: DayView)
    func presentedDateUpdated(date: CVDate)
    
    func topMarker(shouldDisplayOnDayView dayView: DayView) -> Bool
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: DayView) -> Bool
    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool
    func dotMarker(colorOnDayView dayView: DayView) -> UIColor
    
    optional func dotMarker(moveOffsetOnDayView dayView: DayView) -> CGFloat
}