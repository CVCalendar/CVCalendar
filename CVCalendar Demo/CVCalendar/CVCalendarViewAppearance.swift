//
//  CVCalendarViewAppearance.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

private let sharedInstance = CVCalendarViewAppearance()

class CVCalendarViewAppearance: NSObject {
    
    class var sharedCalendarViewAppearance: CVCalendarViewAppearance {
        return sharedInstance
    }

    var spaceBetweenWeekViews: CGFloat? = 0
    var spaceBetweenDayViews: CGFloat? = 0
    
    var dayLabelWeekdayTextSize: CGFloat? = 18
    var dayLabelPresentWeekdayTextSize: CGFloat? = 18
    var dayLabelWeekdayHighlightedTextSize: CGFloat? = 20
    var dayLabelPresentWeekdayHighlightedTextSize: CGFloat? = 20
    
    var dayLabelPresentWeekdayInitallyBold: Bool = true
    
    var dayLabelWeekdayInTextColor: UIColor? = .blackColor()
    var dayLabelWeekdayOutTextColor: UIColor? = .grayColor()
    var dayLabelWeekdayHighlightedBackgroundColor: UIColor? = .blueColor()
    var dayLabelWeekdayHighlightedBackgroundAlpha: CGFloat? = 0.6
    var dayLabelPresentWeekdayTextColor: UIColor? = .redColor()
    var dayLabelPresentWeekdayHighlightedBackgroundColor: UIColor? = .redColor()
    var dayLabelPresentWeekdayHighlightedBackgroundAlpha: CGFloat? = 0.6
    
    var dayLabelWeekdayHighlightedTextColor: UIColor? = .whiteColor()
    var dayLabelPresentWeekdayHighlightedTextColor: UIColor? = .whiteColor()
    
    var dotMarkerColor: UIColor? = .whiteColor()
    var dotMarkerOffset: CGFloat? = 3.5
    
    var delegate: CVCalendarViewAppearanceDelegate? {
        didSet {
            self.setupAppearance()
        }
    }
    
    func setupAppearance() {
        if let spaceBetweenWeekViews = self.delegate!.spaceBetweenWeekViews?() {
            self.spaceBetweenWeekViews = spaceBetweenWeekViews
        }
        
        if let spaceBetweenDayViews = self.delegate!.spaceBetweenDayViews?() {
            self.spaceBetweenDayViews = spaceBetweenDayViews
        }
        
        if let dayLabelWeekdayTextSize = self.delegate!.dayLabelWeekdayTextSize?() {
            self.dayLabelWeekdayTextSize = dayLabelWeekdayTextSize
        }
        
        if let dayLabelPresentWeekdayTextSize = self.delegate!.dayLabelPresentWeekdayTextSize?() {
            self.dayLabelPresentWeekdayTextSize = dayLabelPresentWeekdayTextSize
        }
        
        if let dayLabelWeekdayHighlightedTextSize = self.delegate!.dayLabelWeekdayHighlightedTextSize?() {
            self.dayLabelWeekdayHighlightedTextSize = dayLabelWeekdayHighlightedTextSize
        }
        
        if let dayLabelPresentWeekdayHighlightedTextSize = self.delegate!.dayLabelPresentWeekdayHighlightedTextSize?() {
            self.dayLabelPresentWeekdayHighlightedTextSize = dayLabelPresentWeekdayHighlightedTextSize
        }
        
        if let dayLabelPresentWeekdayInitallyBold = self.delegate!.dayLabelPresentWeekdayInitallyBold?() {
            self.dayLabelPresentWeekdayInitallyBold = dayLabelPresentWeekdayInitallyBold
        }
        
        if let dayLabelWeekdayTextSize = self.delegate!.dayLabelWeekdayTextSize?() {
            self.dayLabelWeekdayTextSize = dayLabelWeekdayTextSize
        }
        
        if let dayLabelWeekdayInTextColor = self.delegate!.dayLabelWeekdayInTextColor?() {
            self.dayLabelWeekdayInTextColor = dayLabelWeekdayInTextColor
        }
        
        if let dayLabelWeekdayOutTextColor = self.delegate!.dayLabelWeekdayOutTextColor?() {
            self.dayLabelWeekdayOutTextColor = dayLabelWeekdayOutTextColor
        }
        
        if let dayLabelWeekdayHighlightedBackgroundColor = self.delegate!.dayLabelWeekdayHighlightedBackgroundColor?() {
            self.dayLabelWeekdayHighlightedBackgroundColor = dayLabelWeekdayHighlightedBackgroundColor
        }
        
        if let dayLabelWeekdayHighlightedBackgroundAlpha = self.delegate!.dayLabelWeekdayHighlightedBackgroundAlpha?() {
            self.dayLabelWeekdayHighlightedBackgroundAlpha = dayLabelWeekdayHighlightedBackgroundAlpha
        }
        
        if let dayLabelPresentWeekdayTextColor = self.delegate!.dayLabelPresentWeekdayTextColor?() {
            self.dayLabelPresentWeekdayTextColor = dayLabelPresentWeekdayTextColor
        }
        
        if let dayLabelPresentWeekdayHighlightedBackgroundColor = self.delegate!.dayLabelPresentWeekdayHighlightedBackgroundColor?() {
            self.dayLabelPresentWeekdayHighlightedBackgroundColor = dayLabelPresentWeekdayHighlightedBackgroundColor
        }
        
        if let dayLabelPresentWeekdayHighlightedBackgroundAlpha = self.delegate!.dayLabelPresentWeekdayHighlightedBackgroundAlpha?() {
            self.dayLabelPresentWeekdayHighlightedBackgroundAlpha = dayLabelPresentWeekdayHighlightedBackgroundAlpha
        }
        
        if let dayLabelWeekdayHighlightedTextColor = self.delegate!.dayLabelWeekdayHighlightedTextColor?() {
            self.dayLabelWeekdayHighlightedTextColor = dayLabelWeekdayHighlightedTextColor
        }
        
        if let dayLabelPresentWeekdayHighlightedTextColor = self.delegate!.dayLabelPresentWeekdayHighlightedTextColor?() {
            self.dayLabelPresentWeekdayHighlightedTextColor = dayLabelPresentWeekdayHighlightedTextColor
        }
        
        if let dotMarkerColor = self.delegate!.dotMarkerColor?() {
            self.dotMarkerColor = dotMarkerColor
        }
        
        if let dotMarkerOffset = self.delegate!.dotMarkerOffset?() {
            self.dotMarkerOffset = dotMarkerOffset
        }
    }
    
    private override init() {
        super.init()
    }
}
