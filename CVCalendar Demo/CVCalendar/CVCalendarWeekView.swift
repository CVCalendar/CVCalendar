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
    
    
    // MARK: - Initialization

    init(monthView: CVCalendarMonthView, frame: CGRect, index: Int) {
        super.init()
        
        self.monthView = monthView
        self.frame = frame
        self.index = index
        
        
        // TODO: Add weeks in & weeks out
        
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
