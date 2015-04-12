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

class CVCalendarDayViewControlCoordinator: NSObject {
    // MARK: - Non public properties
    private var selectionSet = Set<DayView>()
    
    lazy var appearance: Appearance = {
        return Appearance.sharedCalendarViewAppearance
    }()
    
    // MARK: - Public properties
    weak var selectedDayView: CVCalendarDayView?
    var animator: CVCalendarViewAnimator! {
        return CVCalendarViewAnimator.sharedAnimator
    }
    
    class var sharedControlCoordinator: CVCalendarDayViewControlCoordinator {
        return instance
    }

    // MARK: - Private initialization
    private override init() { }
}

// MARK: - Animator side callback

extension CVCalendarDayViewControlCoordinator {
    func selectionPerformedOnDayView(dayView: DayView) {
        // TODO:
    }
    
    func deselectionPerformedOnDayView(dayView: DayView) {
        if dayView != selectedDayView {
            selectionSet.remove(dayView)
            dayView.setDayLabelDeselectedDismissingState(true)
        }
    }
    
    func dequeueDayView(dayView: DayView) {
        selectionSet.remove(dayView)
    }
    
    func flush() {
       selectionSet.removeAll()
    }
}

// MARK: - Animator reference 

private extension CVCalendarDayViewControlCoordinator {
    func presentSelectionOnDayView(dayView: DayView) {
        animator.animateSelectionOnDayView(dayView)
        //animator?.animateSelection(dayView, withControlCoordinator: self)
    }
    
    func presentDeselectionOnDayView(dayView: DayView) {
        animator.animateDeselectionOnDayView(dayView)
        //animator?.animateDeselection(dayView, withControlCoordinator: self)
    }
}

// MARK: - Coordinator's control actions

extension CVCalendarDayViewControlCoordinator {
    func performDayViewSingleSelection(dayView: DayView) {
        selectionSet.insert(dayView)
        
        if selectionSet.count > 1 {
            let count = selectionSet.count-1
            for dayViewInQueue in selectionSet {
                if dayView != dayViewInQueue {
                    if dayView.calendarView != nil {
                        presentDeselectionOnDayView(dayViewInQueue)
                    }
                    
                }
                
            }
        }
        
        if let animator = animator {
            if selectedDayView != dayView {
                selectedDayView = dayView
                presentSelectionOnDayView(dayView)
            }
        } 
    }
    
    func performDayViewRangeSelection(dayView: DayView) {
        println("Day view range selection found")
    }
}