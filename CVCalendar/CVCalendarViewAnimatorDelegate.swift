//
//  CVCalendarViewAnimatorDelegate.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

@objc
public protocol CVCalendarViewAnimatorDelegate {
    func selectionAnimation() -> ((DayView, @escaping ((Bool) -> ())) -> ())
    func deselectionAnimation() -> ((DayView, @escaping ((Bool) -> ())) -> ())
}
