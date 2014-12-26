//
//  CVCalendarView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarView: UIView {
    
    var monthView: CVCalendarMonthView?
    
    var monthViewHolder: UIView? {
        didSet {
            self.updateMonthViewsFrames()
        }
    }
    
    func updateMonthViewsFrames() {
        let size = self.monthViewHolder!.frame.size
        self.monthView!.updateAppearance(CGRectMake(0, 0, size.width, size.height))
        self.monthViewHolder!.addSubview(self.monthView!)
    }
    
    let appearance = CVCalendarViewAppearance()
    
    // MARK: - Calendar View Data Source
    
    var monthDates: [NSDate]?
    
    override init() {
        super.init()
        
        self.monthView = CVCalendarMonthView(calendarView: self, date: NSDate())
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
