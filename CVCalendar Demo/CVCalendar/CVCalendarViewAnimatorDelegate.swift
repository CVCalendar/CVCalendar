//
//  CVCalendarViewAnimatorDelegate.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

@objc
protocol CVCalendarViewAnimatorDelegate {
    func animateSelection(dayView: CVCalendarDayView, withControlCoordinator coordinator: CVCalendarDayViewControlCoordinator)
    func animateDeselection(dayView: CVCalendarDayView, withControlCoordinator coordinator: CVCalendarDayViewControlCoordinator)
}