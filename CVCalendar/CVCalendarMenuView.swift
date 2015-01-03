//
//  CVCalendarMenuView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarMenuView: UIView {
    
    let symbols = CVCalendarManager.sharedManager.shortWeekdaySymbols() as [String]
    var symbolViews: [UILabel]?

    override init() {
        super.init()
        
        self.createDaySymbols()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.createDaySymbols()
    }
    
    func createDaySymbols() {
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
