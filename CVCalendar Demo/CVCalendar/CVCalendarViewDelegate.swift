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
    
    func didSelectDayView(dayView: CVCalendarDayView)
    func presentedDateUpdated(date: CVDate)
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> UIColor
}