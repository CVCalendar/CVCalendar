//
//  CVCalendarContentDelegate.swift
//  CVCalendar Demo
//
//  Created by E. Mozharovsky on 1/28/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

protocol CVCalendarContentDelegate {
    func updateFrames()
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView)
    func scrollViewDidScroll(scrollView: UIScrollView)
    func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    
    func performedDayViewSelection(dayView: CVCalendarDayView)
    
    func presentNextView(dayView: CVCalendarDayView?)
    func presentPreviousView(dayView: CVCalendarDayView?)
    
    func updateDayViews(hidden: Bool)
    
    func togglePresentedDate(date: NSDate)
}