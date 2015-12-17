//
//  CVCalendarViewDelegate.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

@objc
public protocol CVCalendarViewDelegate {
    func presentationMode() -> CalendarMode
    func firstWeekday() -> Weekday
    
    /**
    Determines whether resizing should cause related views' animation.
    */
    optional func shouldAnimateResizing() -> Bool
    
    optional func shouldScrollOnOutDayViewSelection() -> Bool
    optional func shouldAutoSelectDayOnWeekChange() -> Bool
    optional func shouldAutoSelectDayOnMonthChange() -> Bool
    optional func shouldShowWeekdaysOut() -> Bool
    optional func didSelectDayView(dayView: DayView, animationDidFinish: Bool)
    optional func presentedDateUpdated(date: Date)
    optional func topMarker(shouldDisplayOnDayView dayView: DayView) -> Bool
    optional func dotMarker(shouldMoveOnHighlightingOnDayView dayView: DayView) -> Bool
    optional func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool
    optional func dotMarker(colorOnDayView dayView: DayView) -> [UIColor]
    optional func dotMarker(moveOffsetOnDayView dayView: DayView) -> CGFloat
    optional func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat
    
    optional func selectionViewPath() -> ((CGRect) -> (UIBezierPath))
    optional func shouldShowCustomSingleSelection() -> Bool

    optional func preliminaryView(viewOnDayView dayView: DayView) -> UIView
    optional func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool
    
    optional func supplementaryView(viewOnDayView dayView: DayView) -> UIView
    optional func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool
    
    optional func didShowNextMonthView(date: NSDate)
    optional func didShowPreviousMonthView(date: NSDate)
}