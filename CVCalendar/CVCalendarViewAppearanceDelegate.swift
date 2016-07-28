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
    optional func spaceBetweenWeekViews() -> CGFloat
    optional func spaceBetweenDayViews() -> CGFloat

    // Font options.
    optional func dayLabelFont(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIFont
    optional func dayLabelPresentWeekdayInitallyBold() -> Bool
    optional func dayLabelWeekdayFont() -> UIFont
    optional func dayLabelPresentWeekdayFont() -> UIFont
    optional func dayLabelPresentWeekdayBoldFont() -> UIFont
    optional func dayLabelPresentWeekdayHighlightedFont() -> UIFont
    optional func dayLabelPresentWeekdaySelectedFont() -> UIFont
    optional func dayLabelWeekdayHighlightedFont() -> UIFont
    optional func dayLabelWeekdaySelectedFont() -> UIFont

    // Text color.
    optional func dayLabelColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor?
    optional func dayLabelWeekdayDisabledColor() -> UIColor
    optional func dayLabelWeekdayInTextColor() -> UIColor
    optional func dayLabelWeekdayOutTextColor() -> UIColor
    optional func dayLabelWeekdayHighlightedTextColor() -> UIColor
    optional func dayLabelWeekdaySelectedTextColor() -> UIColor
    optional func dayLabelPresentWeekdayTextColor() -> UIColor
    optional func dayLabelPresentWeekdayHighlightedTextColor() -> UIColor
    optional func dayLabelPresentWeekdaySelectedTextColor() -> UIColor

    // Text size.
    optional func dayLabelSize(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> CGFloat
    optional func dayLabelWeekdayTextSize() -> CGFloat
    optional func dayLabelWeekdayHighlightedTextSize() -> CGFloat
    optional func dayLabelWeekdaySelectedTextSize() -> CGFloat
    optional func dayLabelPresentWeekdayTextSize() -> CGFloat
    optional func dayLabelPresentWeekdayHighlightedTextSize() -> CGFloat
    optional func dayLabelPresentWeekdaySelectedTextSize() -> CGFloat
    
    // Background Color & Alpha
    optional func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor?
    // Highlighted state background & alpha.
    optional func dayLabelWeekdayHighlightedBackgroundColor() -> UIColor
    optional func dayLabelWeekdayHighlightedBackgroundAlpha() -> CGFloat
    optional func dayLabelPresentWeekdayHighlightedBackgroundColor() -> UIColor
    optional func dayLabelPresentWeekdayHighlightedBackgroundAlpha() -> CGFloat

    // Selected state background & alpha.
    optional func dayLabelWeekdaySelectedBackgroundColor() -> UIColor
    optional func dayLabelWeekdaySelectedBackgroundAlpha() -> CGFloat
    optional func dayLabelPresentWeekdaySelectedBackgroundColor() -> UIColor
    optional func dayLabelPresentWeekdaySelectedBackgroundAlpha() -> CGFloat

    // Dot marker default color.
    optional func dotMarkerColor() -> UIColor
}
