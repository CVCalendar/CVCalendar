//
//  CVCalendarDayViewControlCoordinator.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

/// Singleton
private let instance = CVCalendarDayViewControlCoordinator()

// MARK: - Type work 

typealias DayView = CVCalendarDayView
typealias Appearance = CVCalendarViewAppearance
typealias Coordinator = CVCalendarCoordinator

/// Coordinator's control actions
protocol CVCalendarCoordinator {
    func performDayViewSingleSelection(dayView: DayView)
    func performDayViewRangeSelection(dayView: DayView)
}

class CVCalendarDayViewControlCoordinator: NSObject {
    var inOrderNumber = 0
    
    class var sharedControlCoordinator: CVCalendarDayViewControlCoordinator {
        return instance
    }
   
    var selectedDayView: CVCalendarDayView? = nil
    var animator: CVCalendarViewAnimatorDelegate?
    
    lazy var appearance: Appearance = {
       return Appearance.sharedCalendarViewAppearance
    }()
    
    private override init() {
        super.init()
    }
    
    private func presentSelectionOnDayView(dayView: DayView) {
        animator?.animateSelection(dayView, withControlCoordinator: self)
    }
    
    private func presentDeselectionOnDayView(dayView: DayView) {
        animator?.animateDeselection(dayView, withControlCoordinator: self)
    }
    
    func animationStarted() {
        inOrderNumber++
    }
    
    func animationEnded() {
        inOrderNumber--
    }
}

// MARK: - CVCalendarCoordinator

extension CVCalendarDayViewControlCoordinator: Coordinator {
    func performDayViewSingleSelection(dayView: DayView) {
        if let currentlySelectedDatView = selectedDayView {
            if currentlySelectedDatView != dayView {
                if inOrderNumber < 2 {
                    presentDeselectionOnDayView(selectedDayView!)
                    selectedDayView = dayView
                    presentSelectionOnDayView(selectedDayView!)
                }
            }
        } else {
            selectedDayView = dayView
            if animator == nil {
                animator = selectedDayView!.weekView!.monthView!.calendarView!.animator
            }
            
            presentSelectionOnDayView(selectedDayView!)
        }
    }
    
    func performDayViewRangeSelection(dayView: DayView) {
        println("Day view range selection found")
    }
}
