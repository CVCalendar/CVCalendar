//
//  CVCalendarWeekView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarWeekView: UIView {
    
    // MARK: - Public properties
    
    var monthView: CVCalendarMonthView?
    let index: Int?
    let weekdaysIn: [Int : [Int]]?
    let weekdaysOut: [Int : [Int]]?
    
    var dayViews: [CVCalendarDayView]?
    
    // For Recovery service.
    var utilizable = false
    
    // MARK: - Initialization

    init(monthView: CVCalendarMonthView, frame: CGRect, index: Int) {
        super.init()
        
        self.monthView = monthView
        self.frame = frame
        self.index = index
        
        // Get weekdays in.
        let weeksIn = self.monthView!.weeksIn!
        self.weekdaysIn = weeksIn[self.index!]
        
        // Get weekdays out.
        
        if let weeksOut = self.monthView!.weeksOut {
            if self.weekdaysIn?.count < 7 {
                if weeksOut.count > 1 {
                    let daysOut = 7 - self.weekdaysIn!.count
                    
                    var result: [Int : [Int]]?
                    for weekdaysOut in weeksOut {
                        if weekdaysOut.count == daysOut {
                            let manager = CVCalendarManager.sharedManager
                            
                            
                            let key = weekdaysOut.keys.array[0]
                            let value = weekdaysOut[key]![0]
                            if value > 20 {
                                if self.index == 0 {
                                    result = weekdaysOut
                                    break
                                }
                            } else if value < 10 {
                                if self.index == manager.monthDateRange(self.monthView!.date!).countOfWeeks - 1 {
                                    result = weekdaysOut
                                    break
                                }
                            }
                        }
                    }
                    
                    self.weekdaysOut = result!
                } else {
                    self.weekdaysOut = weeksOut[0]
                }
                
            }
        }

        
        self.createDayViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Content filling 

    func createDayViews() {
        self.dayViews = [CVCalendarDayView]()
        for i in 1...7 {
            let renderer = CVCalendarRenderer.sharedRenderer()
            let frame = renderer.renderDayFrameForMonthView(self, dayIndex: i-1)
            
            let dayView = CVCalendarDayView(weekView: self, frame: frame, weekdayIndex: i)
            self.dayViews?.append(dayView)
            self.addSubview(dayView)
        }
    }
    
    // MARK: - View Destruction
    
    func destroy() {
        self.monthView = nil
        
        if dayViews != nil {
            for dayView in dayViews! {
                dayView.removeFromSuperview()
                dayView.destroy()
            }
            
            dayViews = nil
        }

    }
    
     // MARK: - Content reload
    
    func reloadDayViews() {
        for i in 0..<self.dayViews!.count {
            let frame = CVCalendarRenderer.sharedRenderer().renderDayFrameForMonthView(self, dayIndex: i)
            
            let dayView = self.dayViews![i]
            dayView.frame = frame
            dayView.reloadContent()
        }
    }
    
}
