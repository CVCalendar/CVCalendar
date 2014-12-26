//
//  CVCalendarViewAppearanceDelegate.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

@objc
protocol CVCalendarViewAppearanceDelegate {
    optional func spaceBetweenWeekViews() -> CGFloat
    optional func spaceBetweenDayViews() -> CGFloat
    
    optional func dayLabelWeekdayTextSize() -> CGFloat
    optional func dayLabelPresentWeekdayTextSize() -> CGFloat
    optional func dayLabelWeekdayHighlightedTextSize() -> CGFloat
    optional func dayLabelPresentWeekdayHighlightedTextSize() -> CGFloat
    
    optional func dayLabelPresentWeekdayInitallyBold() -> Bool
    
    optional func dayLabelWeekdayInTextColor() -> UIColor
    optional func dayLabelWeekdayOutTextColor() -> UIColor
    optional func dayLabelWeekdayHighlightedBackgroundColor() -> UIColor
    optional func dayLabelWeekdayHighlightedBackgroundAlpha() -> CGFloat
    
    optional func dayLabelPresentWeekdayTextColor() -> UIColor
    optional func dayLabelPresentWeekdayHighlightedBackgroundColor() -> UIColor
    optional func dayLabelPresentWeekdayHighlightedBackgroundAlpha() -> CGFloat
    
    optional func dayLabelWeekdayHighlightedTextColor() -> UIColor
    optional func dayLabelPresentWeekdayHighlightedTextColor() -> UIColor
    
}
