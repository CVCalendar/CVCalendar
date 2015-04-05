//
//  CVCalendarContentDelegate.swift
//  CVCalendar Demo
//
//  Created by E. Mozharovsky on 1/28/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

protocol CVCalendarContentDelegate: UIScrollViewDelegate {
    func updateFrames()
    func performedDayViewSelection(dayView: DayView)
    func presentNextView(dayView: DayView?)
    func presentPreviousView(dayView: DayView?)
    func updateDayViews(hidden: Bool)
    func togglePresentedDate(date: NSDate)
}