//
//  CVCalendarViewDelegate.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import Foundation

@objc
protocol CVCalendarViewDelegate {
    func shouldShowWeekdaysOut() -> Bool
    func didSelectDayView(dayView: CVCalendarDayView)
}