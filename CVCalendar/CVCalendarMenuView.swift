//
//  CVCalendarMenuView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

public typealias WeekdaySymbolType = CVWeekdaySymbolType

public final class CVCalendarMenuView: UIView {
    public var symbols = [String]()
    public var symbolViews: [UILabel]?

    public var firstWeekday: Weekday? = .Sunday
    public var dayOfWeekTextColor: UIColor? = .darkGrayColor()
    public var dayOfWeekTextUppercase: Bool? = true
    public var dayOfWeekFont: UIFont? = UIFont(name: "Avenir", size: 10)
    public var weekdaySymbolType: WeekdaySymbolType? = .Short

    @IBOutlet public weak var menuViewDelegate: AnyObject? {
        set {
            if let delegate = newValue as? MenuViewDelegate {
                self.delegate = delegate
            }
        }
        
        get {
            return delegate as? AnyObject
        }
    }
    
    public weak var delegate: MenuViewDelegate? {
        didSet {
            setupAppearance()
            setupWeekdaySymbols()
            createDaySymbols()
        }
    }

    public init() {
        super.init(frame: CGRectZero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func setupAppearance() {
        if let delegate = delegate {
            firstWeekday~>delegate.firstWeekday?()
            dayOfWeekTextColor~>delegate.dayOfWeekTextColor?()
            dayOfWeekTextUppercase~>delegate.dayOfWeekTextUppercase?()
            dayOfWeekFont~>delegate.dayOfWeekFont?()
            weekdaySymbolType~>delegate.weekdaySymbolType?()
        }
    }

    public func setupWeekdaySymbols() {
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: NSDate())
        calendar.firstWeekday = firstWeekday!.rawValue

        symbols = calendar.weekdaySymbols 
    }
    
    public func createDaySymbols() {
        // Change symbols with their places if needed.
        let dateFormatter = NSDateFormatter()
        var weekdays: NSArray
        
        switch weekdaySymbolType! {
        case .Normal:
            weekdays = dateFormatter.weekdaySymbols as NSArray
        case .Short:
            weekdays = dateFormatter.shortWeekdaySymbols as NSArray
        case .VeryShort:
            weekdays = dateFormatter.veryShortWeekdaySymbols as NSArray
        }

        let firstWeekdayIndex = firstWeekday!.rawValue - 1
        if (firstWeekdayIndex > 0) {
            let copy = weekdays
            weekdays = (weekdays.subarrayWithRange(NSMakeRange(firstWeekdayIndex, 7 - firstWeekdayIndex)))
            weekdays = weekdays.arrayByAddingObjectsFromArray(copy.subarrayWithRange(NSMakeRange(0, firstWeekdayIndex)))
        }
        
        self.symbols = weekdays as! [String]
        
        // Add symbols.
        self.symbolViews = [UILabel]()
        let space = 0 as CGFloat
        let width = self.frame.width / 7 - space
        let height = self.frame.height
        
        var x: CGFloat = 0
        let y: CGFloat = 0
        
        for i in 0..<7 {
            x = CGFloat(i) * width + space
            
            let symbol = UILabel(frame: CGRectMake(x, y, width, height))
            symbol.textAlignment = .Center
            symbol.text = self.symbols[i]

            if (dayOfWeekTextUppercase!) {
                symbol.text = (self.symbols[i]).uppercaseString
            }

            symbol.font = dayOfWeekFont
            symbol.textColor = dayOfWeekTextColor

            self.symbolViews?.append(symbol)
            self.addSubview(symbol)
        }
    }
    
    public func commitMenuViewUpdate() {
        if let _ = delegate {
            let space = 0 as CGFloat
            let width = self.frame.width / 7 - space
            let height = self.frame.height
            
            var x: CGFloat = 0
            let y: CGFloat = 0
            
            for i in 0..<self.symbolViews!.count {
                x = CGFloat(i) * width + space
                
                let frame = CGRectMake(x, y, width, height)
                let symbol = self.symbolViews![i]
                symbol.frame = frame
            }
        }
    }
}
