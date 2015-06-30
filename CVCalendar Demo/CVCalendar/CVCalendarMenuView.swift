//
//  CVCalendarMenuView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarMenuView: UIView {
    var symbols = [String]()
    var symbolViews: [UILabel]?

    var firstWeekday: Weekday? = .Sunday
    var dayOfWeekTextColor: UIColor? = .darkGrayColor()
    var dayOfWeekTextUppercase: Bool? = true
    var dayOfWeekFont: UIFont? = UIFont(name: "Avenir", size: 10)

    @IBOutlet weak var menuViewDelegate: AnyObject? {
        set {
            if let delegate = newValue as? MenuViewDelegate {
                self.delegate = delegate
            }
        }
        
        get {
            return delegate as? AnyObject
        }
    }
    
    var delegate: MenuViewDelegate? {
        didSet {
            setupAppearance()
            setupWeekdaySymbols()
            createDaySymbols()
        }
    }

    init() {
        super.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupAppearance() {
        if let delegate = delegate {
            firstWeekday~>delegate.firstWeekday?()
            dayOfWeekTextColor~>delegate.dayOfWeekTextColor?()
            dayOfWeekTextUppercase~>delegate.dayOfWeekTextUppercase?()
            dayOfWeekFont~>delegate.dayOfWeekFont?()
        }
    }

    func setupWeekdaySymbols() {
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        calendar.components(NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay, fromDate: NSDate())
        calendar.firstWeekday = firstWeekday!.rawValue

        symbols = calendar.weekdaySymbols as! [String]
    }
    
    func createDaySymbols() {
        // Change symbols with their places if needed.
        let dateFormatter = NSDateFormatter()
        var weekdays = dateFormatter.shortWeekdaySymbols as NSArray

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
        var y: CGFloat = 0
        
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
    
    func commitMenuViewUpdate() {
        if let delegate = delegate {
            let space = 0 as CGFloat
            let width = self.frame.width / 7 - space
            let height = self.frame.height
            
            var x: CGFloat = 0
            var y: CGFloat = 0
            
            for i in 0..<self.symbolViews!.count {
                x = CGFloat(i) * width + space
                
                let frame = CGRectMake(x, y, width, height)
                let symbol = self.symbolViews![i]
                symbol.frame = frame
            }
        }
    }
}
