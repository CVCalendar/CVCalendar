//
//  CVCalendarView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarView: UIView {
    
    // MARK: Delegate Management 
    var shouldShowWeekdaysOut: Bool? = false
    var calendarDelegate: CVCalendarViewDelegate? {
        didSet {
            self.setupDelegate()
        }
    }
    
    func setupDelegate() {
        self.shouldShowWeekdaysOut = self.calendarDelegate?.shouldShowWeekdaysOut()
    }
    
    // MARK: - Animator Management
    
    var animator: CVCalendarViewAnimatorDelegate? = CVCalendarViewAnimator()
    
    // MARK: Month View Preparation & Building
    
    var contentView: CVCalendarContentView?
    var monthViewHolder: UIView? {
        didSet {
            let width = self.monthViewHolder!.frame.width
            let height = self.monthViewHolder!.frame.height
            let x = CGFloat(0)
            let y = CGFloat(0)
            
            let frame = CGRectMake(x, y, width, height)
            
            let presentMonthView = CVCalendarMonthView(calendarView: self, date: NSDate())
            presentMonthView.updateAppearance(frame)
            self.contentView = CVCalendarContentView(frame: frame, calendarView: self, presentedMonthView: presentMonthView)
            self.monthViewHolder?.addSubview(self.contentView!)
        }
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
