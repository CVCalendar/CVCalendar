//
//  CVCalendarMonthView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarMonthView: UIView {
    
    // MARK: - Public properties

    var calendarView: CVCalendarView?
    var date: NSDate?
    var numberOfWeeks: Int?
    var weekViews: [CVCalendarWeekView]?
    
    var weeksIn: [[Int : [Int]]]?
    var weeksOut: [[Int : [Int]]]?
    
    var currentDay: Int?
    
    // MARK: - Initialization 

    init(calendarView: CVCalendarView, date: NSDate) {
        super.init()
        
        self.calendarView = calendarView
        self.date = date
        
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        let calendarManager = CVCalendarManager.sharedManager
        self.numberOfWeeks = calendarManager.monthDateRange(self.date!).countOfWeeks
        self.weeksIn = calendarManager.weeksWithWeekdaysForMonthDate(self.date!).weeksIn
        self.weeksOut = calendarManager.weeksWithWeekdaysForMonthDate(self.date!).weeksOut
        
        self.currentDay = calendarManager.dateRange(NSDate()).day
    }
    
    // MARK: - Content filling
    
    func updateAppearance(frame: CGRect) {
        self.frame = frame
        self.createWeekViews()
    }
    
    func createWeekViews() {
        let renderer = CVCalendarRenderer.sharedRenderer()
        self.weekViews = [CVCalendarWeekView]()
        
        for i in 0..<self.numberOfWeeks! {
            let frame = renderer.renderWeekFrameForMonthView(self, weekIndex: i)
            let weekView = CVCalendarWeekView(monthView: self, frame: frame, index: i)
            self.weekViews?.append(weekView)
            self.addSubview(weekView)
        }
    }
    
    
    // MARK: - Events receiving
    
    func receiveDayViewTouch(dayView: CVCalendarDayView) {
        let controlCoordinator = CVCalendarDayViewControlCoordinator.sharedControlCoordinator
        controlCoordinator.performDayViewSelection(dayView)
        
        self.calendarView!.didSelectDayView(dayView)
    }
    
    // MARK: - View Destruction
    
    func destroy() {
        let coordinator = CVCalendarDayViewControlCoordinator.sharedControlCoordinator
        if self.weekViews != nil {
            for weekView in self.weekViews! {
                for dayView in weekView.dayViews! {
                    if dayView == coordinator.selectedDayView {
                        coordinator.selectedDayView = nil
                    }
                }
                
                weekView.destroy()
            }
            
            self.weekViews = nil
        }
    }
    
    // MARK: Content reload 
    
    func reloadWeekViewsWithMonthFrame(frame: CGRect) {
        self.frame = frame
        for i in 0..<self.weekViews!.count {
            let frame = CVCalendarRenderer.sharedRenderer().renderWeekFrameForMonthView(self, weekIndex: i)
            let weekView = self.weekViews![i]
            weekView.frame = frame
            weekView.reloadDayViews()
        }
    }
}
