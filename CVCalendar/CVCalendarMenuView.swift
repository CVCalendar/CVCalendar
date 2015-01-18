//
//  CVCalendarMenuView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarMenuView: UIView {
    
    var starterWeekday = 1
    
    var symbols = [String]()
    var symbolViews: [UILabel]?

    override init() {
        super.init()
        
        self.setupWeekdaySymbols()
        self.createDaySymbols()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupWeekdaySymbols()
        self.createDaySymbols()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        

        self.setupWeekdaySymbols()
        self.createDaySymbols()
    }
    
    func setupWeekdaySymbols() {
        let propertyName = "CVCalendarStarterWeekday"
        let firstWeekday = NSBundle.mainBundle().objectForInfoDictionaryKey(propertyName) as? Int
        if firstWeekday != nil {
            self.starterWeekday = firstWeekday!
        } else {
            let currentCalendar = NSCalendar.currentCalendar()
            let firstWeekday = currentCalendar.firstWeekday
            self.starterWeekday = firstWeekday
        }
        
        
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        calendar.components(NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit, fromDate: NSDate())
        calendar.firstWeekday = self.starterWeekday
        
        symbols = calendar.weekdaySymbols as [String]
    }
    
    func createDaySymbols() {
        // Change symbols with their places if needed.
        let dateFormatter = NSDateFormatter()
        var weekdays = dateFormatter.shortWeekdaySymbols as NSArray
        
        let firstWeekdayIndex = starterWeekday - 1
        if (firstWeekdayIndex > 0) {
            let copy = weekdays
            weekdays = (weekdays.subarrayWithRange(NSMakeRange(firstWeekdayIndex, 7 - firstWeekdayIndex)))
            weekdays = weekdays.arrayByAddingObjectsFromArray(copy.subarrayWithRange(NSMakeRange(0, firstWeekdayIndex)))
        }
        
        self.symbols = weekdays as [String]
        
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
            symbol.text = (self.symbols[i]).uppercaseString
            symbol.font = UIFont.boldSystemFontOfSize(10) // may be provided as a delegate property
            symbol.textColor = UIColor.darkGrayColor()
            
            self.symbolViews?.append(symbol)
            self.addSubview(symbol)
        }
    }
    
    func commitMenuViewUpdate() {
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
