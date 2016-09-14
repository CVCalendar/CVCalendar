//
//  CVCalendarViewAppearanceDelegate.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

@objc
public protocol CVCalendarViewAppearanceDelegate {
    // Rendering options.
    @objc optional func spaceBetweenWeekViews() -> CGFloat
    @objc optional func spaceBetweenDayViews() -> CGFloat

    // Font options.
    @objc optional func dayLabelFont(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIFont
    @objc optional func dayLabelPresentWeekdayInitallyBold() -> Bool
    @objc optional func dayLabelWeekdayFont() -> UIFont
    @objc optional func dayLabelPresentWeekdayFont() -> UIFont
    @objc optional func dayLabelPresentWeekdayBoldFont() -> UIFont
    @objc optional func dayLabelPresentWeekdayHighlightedFont() -> UIFont
    @objc optional func dayLabelPresentWeekdaySelectedFont() -> UIFont
    @objc optional func dayLabelWeekdayHighlightedFont() -> UIFont
    @objc optional func dayLabelWeekdaySelectedFont() -> UIFont

    // Text color.
    @objc optional func dayLabelColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor?
    @objc optional func dayLabelWeekdayDisabledColor() -> UIColor
    @objc optional func dayLabelWeekdayInTextColor() -> UIColor
    @objc optional func dayLabelWeekdayOutTextColor() -> UIColor
    @objc optional func dayLabelWeekdayHighlightedTextColor() -> UIColor
    @objc optional func dayLabelWeekdaySelectedTextColor() -> UIColor
    @objc optional func dayLabelPresentWeekdayTextColor() -> UIColor
    @objc optional func dayLabelPresentWeekdayHighlightedTextColor() -> UIColor
    @objc optional func dayLabelPresentWeekdaySelectedTextColor() -> UIColor

    // Text size.
    @objc optional func dayLabelSize(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> CGFloat
    @objc optional func dayLabelWeekdayTextSize() -> CGFloat
    @objc optional func dayLabelWeekdayHighlightedTextSize() -> CGFloat
    @objc optional func dayLabelWeekdaySelectedTextSize() -> CGFloat
    @objc optional func dayLabelPresentWeekdayTextSize() -> CGFloat
    @objc optional func dayLabelPresentWeekdayHighlightedTextSize() -> CGFloat
    @objc optional func dayLabelPresentWeekdaySelectedTextSize() -> CGFloat
    
    // Background Color & Alpha
    @objc optional func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor?
    // Highlighted state background & alpha.
    @objc optional func dayLabelWeekdayHighlightedBackgroundColor() -> UIColor
    @objc optional func dayLabelWeekdayHighlightedBackgroundAlpha() -> CGFloat
    @objc optional func dayLabelPresentWeekdayHighlightedBackgroundColor() -> UIColor
    @objc optional func dayLabelPresentWeekdayHighlightedBackgroundAlpha() -> CGFloat

    // Selected state background & alpha.
    @objc optional func dayLabelWeekdaySelectedBackgroundColor() -> UIColor
    @objc optional func dayLabelWeekdaySelectedBackgroundAlpha() -> CGFloat
    @objc optional func dayLabelPresentWeekdaySelectedBackgroundColor() -> UIColor
    @objc optional func dayLabelPresentWeekdaySelectedBackgroundAlpha() -> CGFloat

    // Dot marker default color.
    @objc optional func dotMarkerColor() -> UIColor
  
    // Top marker default color.
    @objc optional func topMarkerColor() -> UIColor
}
