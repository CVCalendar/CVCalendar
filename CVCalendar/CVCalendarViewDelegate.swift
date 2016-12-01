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

    /*
    Determines whether resizing should cause related views' animation.
    */
    @objc optional func shouldAnimateResizing() -> Bool
    @objc optional func toggleDateAnimationDuration() -> Double

    @objc optional func shouldScrollOnOutDayViewSelection() -> Bool
    @objc optional func shouldAutoSelectDayOnWeekChange() -> Bool
    @objc optional func shouldAutoSelectDayOnMonthChange() -> Bool
    @objc optional func shouldShowWeekdaysOut() -> Bool
    @objc optional func shouldSelectDayView(_ dayView: DayView) -> Bool
    @objc optional func didSelectDayView(_ dayView: DayView, animationDidFinish: Bool)
    @objc optional func presentedDateUpdated(_ date: CVDate)
    @objc optional func topMarker(shouldDisplayOnDayView dayView: DayView) -> Bool
    @objc optional func dotMarker(shouldMoveOnHighlightingOnDayView dayView: DayView) -> Bool
    @objc optional func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool
    @objc optional func dotMarker(colorOnDayView dayView: DayView) -> [UIColor]
    @objc optional func dotMarker(moveOffsetOnDayView dayView: DayView) -> CGFloat
    @objc optional func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat

    @objc optional func selectionViewPath() -> ((CGRect) -> (UIBezierPath))
    @objc optional func shouldShowCustomSingleSelection() -> Bool

    @objc optional func preliminaryView(viewOnDayView dayView: DayView) -> UIView
    @objc optional func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool

    @objc optional func supplementaryView(viewOnDayView dayView: DayView) -> UIView
    @objc optional func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool
    

    @objc optional func didShowNextMonthView(_ date: Foundation.Date)
    @objc optional func didShowPreviousMonthView(_ date: Foundation.Date)
    
    // Localization
    @objc optional func calendar() -> Calendar?
    
    // Range selection
    @objc optional func shouldSelectRange() -> Bool
    @objc optional func didSelectRange(from startDayView: DayView, to endDayView: DayView)
    @objc optional func disableScrollingBeforeDate() -> Date
    @objc optional func maxSelectableRange() -> Int
    @objc optional func earliestSelectableDate() -> Date
    @objc optional func latestSelectableDate() -> Date
}
