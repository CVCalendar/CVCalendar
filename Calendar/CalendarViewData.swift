//
//  CalendarViewData.swift
//  Calendar
//
//  Created by E. Mozharovsky on 12/15/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CalendarViewData: NSObject {
    
    private let defaultDivIndicator: Float = 3
    private let defaultSpace: Float = 2
    private let defaultSymbolViewHeight: Float = 10
    
    let calendarView: CalendarView?
    
    var dataSource: CalendarViewDataSource? {
        didSet {
            self.setDataSource()
        }
    }
    
    var delegate: CalendarViewDelegate? {
        didSet {
            self.setDelegate()
        }
    }
    
    func setDataSource() {
        println("[CalendarView DataSource]: Setting up...")
        
        if let dataSource = self.dataSource {
            self.numberOfDays = dataSource.calendarView(self, numberOfDaysForCalendarView: self.calendarView!)
            self.numberOfWeeks = dataSource.calendarView(self, numberOfWeeksForCalendarView: self.calendarView!)
            self.shouldShowDaysOut = dataSource.calendarView(self, shouldShowDaysOutForCalendarView: self.calendarView!)
            self.mode = dataSource.calendarView(self, presentedModeForCalendarView: self.calendarView!)
        } else {
            self.numberOfDays = 1
            self.numberOfWeeks = 4
            self.mode = CalendarViewMode.Month
            self.firstWeekday = CalendarWeekday.Sunday
        }
        
        println("[CalendarView DataSource]: Successfully installed.")
    }
    
    func setDelegate() {
        println("[CalendarView Delegate]: Setting up...")
        
        if let delegate = self.delegate {
            self.firstWeekday = CalendarWeekday(rawValue: delegate.calendarView(self, firstWeekdayForCalendarView: self.calendarView!))
            
            if let highlightedDayViewColor = delegate.calendarView?(self, highlightedDayViewColorForCalendarView: self.calendarView!) {
                self.highlightedDayViewColor = highlightedDayViewColor
            } else {
                self.highlightedDayViewColor = UIColor.blueColor()
            }
            
            if let selectedDayViewColor = delegate.calendarView?(self, selectedDayViewColorForCalendarView: self.calendarView!) {
                self.selectedDayViewColor = selectedDayViewColor
            } else {
                self.selectedDayViewColor = UIColor.redColor()
            }
            
            if let textFont = delegate.calendarView?(self, textFontForCalendarView: self.calendarView!) {
                self.textFont = textFont
            } else {
                self.textFont = UIFont.systemFontOfSize(14)
            }
            
            if let textColor = delegate.calendarView?(self, textColorForCalendarView: self.calendarView!) {
                self.textColor = textColor
            }
            
            if let symbolsHeight = delegate.calendarView?(self, symbolsHeightForCalendarView: self.calendarView!) {
                self.symbolsHeight = symbolsHeight
            } else {
                self.symbolsHeight = self.defaultSymbolViewHeight
            }
            
            if let verticalSpaceBetweenWeekViews = delegate.calendarView?(self, verticalSpaceBetweenWeekViewsForCalendarView: self.calendarView!) {
                self.verticalSpaceBetweenWeekViews = verticalSpaceBetweenWeekViews
            } else {
                self.verticalSpaceBetweenWeekViews = 2
            }
            
            if let dayViewWidth = delegate.calendarView?(self, dayViewWidthForCalendarView: self.calendarView!) {
                self.dayViewWidth = dayViewWidth
            } else {
                self.dayViewWidth = self.dayViewSide()
            }
            
            if let horizontalSpaceBetweenDayViews = delegate.calendarView?(self, horizontalSpaceBetweenDayViewsForCalendarView: self.calendarView!) {
                self.horizontalSpaceBetweenDayViews = horizontalSpaceBetweenDayViews
            } else {
                self.horizontalSpaceBetweenDayViews = 2
            }
            
            if let weekViewHeight = delegate.calendarView?(self, weekViewHeightForCalendarView: self.calendarView!) {
                self.weekViewHeight = weekViewHeight
            } else {
                /*var frame = self.calendarView!.frame
                frame.size.height += CGFloat(self.heightForWeekView(frame) - self.symbolsHeight!) + (CGFloat(self.verticalSpaceBetweenWeekViews!) * CGFloat(self.numberOfWeeks! - 1))
         
                
                self.weekViewHeight = self.heightForWeekView(frame)*/
                
                self.weekViewHeight = self.dayViewSide()
            }
            
            
        } else {
            println("SOMETHING GONE WRONG...")
            
            self.shouldShowDaysOut = true
            self.highlightedDayViewColor = UIColor.blueColor()
            self.selectedDayViewColor = UIColor.redColor()
            self.textFont = UIFont.systemFontOfSize(14)
            self.textColor = UIColor.blackColor()
        }
        
        println("[CalendarView Delegate]: Successfully installed.")
    }
    
    // MARK: - Initialization
    
    init(calendarView: CalendarView) {
        self.calendarView = calendarView
    }
    
    // MARK: - Calendar View Data Source
    
    var numberOfDays: Int?
    var numberOfWeeks: Int?
    var shouldShowDaysOut: Bool?
    var mode: CalendarViewMode?
    
    
    // MARK: - Calendar View Delegate
    
    var firstWeekday: CalendarWeekday?
    var highlightedDayViewColor: UIColor?
    var selectedDayViewColor: UIColor?
    var textFont: UIFont?
    var textColor: UIColor?
    
    var symbolsHeight: Float?
    
    var weekViewHeight: Float?
    var verticalSpaceBetweenWeekViews: Float?
    
    var dayViewWidth: Float?
    var horizontalSpaceBetweenDayViews: Float?
    
    func heightForWeekView(frame: CGRect) -> Float {
        var space: Float?
        if let _space = self.verticalSpaceBetweenWeekViews {
            space = Float(_space)
        } else {
            space = self.defaultSpace
        }
        
        return (Float(frame.height) / Float(self.numberOfWeeks!)) - space!
    }
    
    func dayViewSide() -> Float {
        var side: Float = 0
        
        var space: Float?
        if let _space = self.horizontalSpaceBetweenDayViews {
            space = _space
        } else {
            space = self.defaultSpace
        }
        
        side = Float(self.calendarView!.frame.width / 7) - space!
        
        return side
    }
}
