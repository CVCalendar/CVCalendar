//
//  CVCalendarWeekContentRecovery.swift
//  CVCalendar Demo
//
//  Created by E. Mozharovsky on 1/25/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

class CVCalendarWeekContentRecovery: NSObject {
   
    // MARK: - Types work
    
    typealias MonthView = CVCalendarMonthView
    //typealias WeekContentView = CVCalendarWeekContentView
    
    // MARK: - Properties
    
    var weekContentView: CVCalendarWeekContentView!
    
    private var monthViews: [MonthView]!
    private var presentedMonthView: MonthView!
    
    // MARK: - Initialization 
    
    override init() {
        super.init()
        monthViews = [MonthView]()
    }
    
    // MARK: - Recovery Operations
    func recoverMonthView(monthView: MonthView) {
        func hasDuplicate() -> Bool {
            for _monthView in monthViews {
                if monthView == _monthView {
                    return true
                }
            }
            
            return false
        }
        
        if !hasDuplicate() {
            monthViews.append(monthView)
            flushIfNeeded()
        }
    }

    private let limit = 3
    func flushIfNeeded() {
        func recoveryAllowed(monthView: MonthView) -> Bool {
            if let weekViews = monthView.weekViews {
                for weekView in weekViews {
                    for _weekView in weekContentView.weekViews.values {
                        if weekView == _weekView {
                            return false
                        }
                    }
                }
            } 

            
            return true
        }
        
        if monthViews.count == limit {
            var endValue = monthViews.count
            var removalIndexes = [Int]()
            for i in 0 ..< endValue {
                if i < endValue {
                    let monthView = monthViews[i]
                    if recoveryAllowed(monthView) {
                        monthView.removeFromSuperview()
                        monthView.destroy()
                        removalIndexes.append(i)
                    }
                }
            }
            
            for index in removalIndexes {
                monthViews.removeAtIndex(index)
            }
        }
    }
}
