//
//  CVCalendarViewAppearance.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarViewAppearance: NSObject {
    
    override init() {
        super.init()
    }
    
    /// Default rendering options.
    var spaceBetweenWeekViews: CGFloat? = 0
    var spaceBetweenDayViews: CGFloat? = 0
    
    /// Default text options.
    var dayLabelPresentWeekdayInitallyBold: Bool? = true
    var dayLabelWeekdayFont: UIFont? = UIFont(name: "Avenir", size: 18)
    var dayLabelPresentWeekdayFont: UIFont? = UIFont(name: "Avenir", size: 18)
    var dayLabelPresentWeekdayBoldFont: UIFont? = UIFont(name: "Avenir-Heavy", size: 18)
    var dayLabelPresentWeekdayHighlightedFont: UIFont? = UIFont(name: "Avenir-Heavy", size: 18)
    var dayLabelPresentWeekdaySelectedFont: UIFont? = UIFont(name: "Avenir-Heavy", size: 18)
    var dayLabelWeekdayHighlightedFont: UIFont? = UIFont(name: "Avenir-Heavy", size: 18)
    var dayLabelWeekdaySelectedFont: UIFont? = UIFont(name: "Avenir-Heavy", size: 18)
    
    /// Default text color.
    var dayLabelWeekdayInTextColor: UIColor? = .blackColor()
    var dayLabelWeekdayOutTextColor: UIColor? = .grayColor()
    var dayLabelWeekdayHighlightedTextColor: UIColor? = .whiteColor()
    var dayLabelWeekdaySelectedTextColor: UIColor? = .whiteColor()
    var dayLabelPresentWeekdayTextColor: UIColor? = .redColor()
    var dayLabelPresentWeekdayHighlightedTextColor: UIColor? = .whiteColor()
    var dayLabelPresentWeekdaySelectedTextColor: UIColor? = .whiteColor()
    
    /// Default text size.
    var dayLabelWeekdayTextSize: CGFloat? = 18
    var dayLabelWeekdayHighlightedTextSize: CGFloat? = 20
    var dayLabelWeekdaySelectedTextSize: CGFloat? = 20
    var dayLabelPresentWeekdayTextSize: CGFloat? = 18
    var dayLabelPresentWeekdayHighlightedTextSize: CGFloat? = 20
    var dayLabelPresentWeekdaySelectedTextSize: CGFloat? = 20
    
    /// Default highlighted state background & alpha.
    var dayLabelWeekdayHighlightedBackgroundColor: UIColor? = .colorFromCode(0x34AADC)
    var dayLabelWeekdayHighlightedBackgroundAlpha: CGFloat? = 0.8
    var dayLabelPresentWeekdayHighlightedBackgroundColor: UIColor? = .colorFromCode(0xFF5E3A)
    var dayLabelPresentWeekdayHighlightedBackgroundAlpha: CGFloat? = 0.8
    
    /// Default selected state background & alpha.
    var dayLabelWeekdaySelectedBackgroundColor: UIColor? = .colorFromCode(0x1D62F0)
    var dayLabelWeekdaySelectedBackgroundAlpha: CGFloat? = 0.8
    var dayLabelPresentWeekdaySelectedBackgroundColor: UIColor? = .colorFromCode(0xFF3B30)
    var dayLabelPresentWeekdaySelectedBackgroundAlpha: CGFloat? = 0.8
    
    
    // Default dot marker color.
    var dotMarkerColor: UIColor? = .whiteColor()
    
    var delegate: CVCalendarViewAppearanceDelegate? {
        didSet {
            self.setupAppearance()
        }
    }
    
    func setupAppearance() {
        if let delegate = delegate {
            spaceBetweenWeekViews~>delegate.spaceBetweenWeekViews?()
            spaceBetweenDayViews~>delegate.spaceBetweenDayViews?()
            
            dayLabelPresentWeekdayInitallyBold~>delegate.dayLabelPresentWeekdayInitallyBold?()
            dayLabelWeekdayFont~>delegate.dayLabelWeekdayFont?()
            dayLabelPresentWeekdayFont~>delegate.dayLabelPresentWeekdayFont?()
            dayLabelPresentWeekdayBoldFont~>delegate.dayLabelPresentWeekdayBoldFont?()
            dayLabelPresentWeekdayHighlightedFont~>delegate.dayLabelPresentWeekdayHighlightedFont?()
            dayLabelPresentWeekdaySelectedFont~>delegate.dayLabelPresentWeekdaySelectedFont?()
            dayLabelWeekdayHighlightedFont~>delegate.dayLabelWeekdayHighlightedFont?()
            dayLabelWeekdaySelectedFont~>delegate.dayLabelWeekdaySelectedFont?()
            
            dayLabelWeekdayInTextColor~>delegate.dayLabelWeekdayInTextColor?()
            dayLabelWeekdayOutTextColor~>delegate.dayLabelWeekdayOutTextColor?()
            dayLabelWeekdayHighlightedTextColor~>delegate.dayLabelWeekdayHighlightedTextColor?()
            dayLabelWeekdaySelectedTextColor~>delegate.dayLabelWeekdaySelectedTextColor?()
            dayLabelPresentWeekdayTextColor~>delegate.dayLabelPresentWeekdayTextColor?()
            dayLabelPresentWeekdayHighlightedTextColor~>delegate.dayLabelPresentWeekdayHighlightedTextColor?()
            dayLabelPresentWeekdaySelectedTextColor~>delegate.dayLabelPresentWeekdaySelectedTextColor?()
            
            dayLabelWeekdayTextSize~>delegate.dayLabelWeekdayTextSize?()
            dayLabelWeekdayHighlightedTextSize~>delegate.dayLabelWeekdayHighlightedTextSize?()
            dayLabelWeekdaySelectedTextSize~>delegate.dayLabelWeekdaySelectedTextSize?()
            dayLabelPresentWeekdayTextSize~>delegate.dayLabelPresentWeekdayTextSize?()
            dayLabelPresentWeekdayHighlightedTextSize~>delegate.dayLabelPresentWeekdayHighlightedTextSize?()
            dayLabelPresentWeekdaySelectedTextSize~>delegate.dayLabelPresentWeekdaySelectedTextSize?()
            
            dayLabelWeekdayHighlightedBackgroundColor~>delegate.dayLabelWeekdayHighlightedBackgroundColor?()
            dayLabelWeekdayHighlightedBackgroundAlpha~>delegate.dayLabelWeekdayHighlightedBackgroundAlpha?()
            dayLabelPresentWeekdayHighlightedBackgroundColor~>delegate.dayLabelPresentWeekdayHighlightedBackgroundColor?()
            dayLabelPresentWeekdayHighlightedBackgroundAlpha~>delegate.dayLabelPresentWeekdayHighlightedBackgroundAlpha?()
            
            dayLabelWeekdaySelectedBackgroundColor~>delegate.dayLabelWeekdaySelectedBackgroundColor?()
            dayLabelWeekdaySelectedBackgroundAlpha~>delegate.dayLabelWeekdaySelectedBackgroundAlpha?()
            dayLabelPresentWeekdaySelectedBackgroundColor~>delegate.dayLabelPresentWeekdaySelectedBackgroundColor?()
            dayLabelPresentWeekdaySelectedBackgroundAlpha~>delegate.dayLabelPresentWeekdaySelectedBackgroundAlpha?()
            
            dotMarkerColor~>delegate.dotMarkerColor?()
        }
    }
}

infix operator ~> { }
func ~><T: Any>(inout lhs: T?, rhs: T?) -> T? {
    if lhs != nil && rhs != nil {
        lhs = rhs
    }

    return lhs
}

extension UIColor {
    class func colorFromCode(code: Int) -> UIColor {
        let red = CGFloat(((code & 0xFF0000) >> 16)) / 255
        let green = CGFloat(((code & 0xFF00) >> 8)) / 255
        let blue = CGFloat((code & 0xFF)) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
