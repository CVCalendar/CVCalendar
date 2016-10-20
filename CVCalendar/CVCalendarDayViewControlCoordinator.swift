//
//  CVCalendarDayViewControlCoordinator.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarDayViewControlCoordinator {
    // MARK: - Non public properties
    fileprivate var selectionSet = Set<DayView>()
    fileprivate var highlightedDayViews = [DayView]()
    fileprivate unowned let calendarView: CalendarView

    // MARK: - Public properties
    public weak var selectedDayView: CVCalendarDayView?
    public var animator: CVCalendarViewAnimator! {
        get {
            return calendarView.animator
        }
    }

    // MARK: - initialization
    public init(calendarView: CalendarView) {
        self.calendarView = calendarView
    }
}

// MARK: - Animator side callback

extension CVCalendarDayViewControlCoordinator {
    public func selectionPerformedOnDayView(_ dayView: DayView) {
        // TODO:
    }

    public func deselectionPerformedOnDayView(_ dayView: DayView) {
//        if dayView != selectedDayView {
//            selectionSet.remove(dayView)
//            dayView.setDeselectedWithClearing(true)
//        }
    }

    public func dequeueDayView(_ dayView: DayView) {
        selectionSet.remove(dayView)
    }

    public func flush() {
        selectedDayView = nil
        selectionSet.removeAll()
    }
}

// MARK: - Animator reference

private extension CVCalendarDayViewControlCoordinator {
    func presentSelectionOnDayView(_ dayView: DayView) {
        print("selecting day \(dayView.date.commonDescription)")
        animator.animateSelectionOnDayView(dayView)
        //animator?.animateSelection(dayView, withControlCoordinator: self)
    }

    func presentDeselectionOnDayView(_ dayView: DayView) {
        animator.animateDeselectionOnDayView(dayView)
        //animator?.animateDeselection(dayView, withControlCoordinator: self)
    }
}

// MARK: - Coordinator's control actions

extension CVCalendarDayViewControlCoordinator {
    public func performDayViewSingleSelection(_ dayView: DayView) {
        selectionSet.insert(dayView)

        if selectionSet.count > 1 {
//            let count = selectionSet.count-1
            for dayViewInQueue in selectionSet {
                if dayView != dayViewInQueue {
                    if dayView.calendarView != nil {
                        presentDeselectionOnDayView(dayViewInQueue)
                    }

                }

            }
        }

        if let _ = animator {
            if selectedDayView != dayView {
                selectedDayView = dayView
                presentSelectionOnDayView(dayView)
            }
        }
    }

    public func performDayViewRangeSelection(_ dayView: DayView) {
//        print("Day view range selection found")
//        selectionSet.insert(dayView)

        var dayViewsToHighlight = [DayView]()

        if selectionSet.count == 2 {
            print("Clearing pre selections:")
            for dayViewInQueue in selectionSet {
                if dayView.calendarView != nil {
                    presentDeselectionOnDayView(dayViewInQueue)
                    print("Deselecting: \(dayViewInQueue.date.commonDescription)")
                }

            }
            for highlightedDayView in highlightedDayViews {
                if dayView.calendarView != nil {
                    presentDeselectionOnDayView(highlightedDayView)
                }
            }
            flush()
        } else if selectionSet.count == 1 {
            print("second selection")
            guard let previouslySelectedDayView = selectionSet.first,
                let previouslySelectedDate = selectionSet.first?.date.convertedDate(),
                let currentlySelectedDate = dayView.date.convertedDate() else {
                    return
            }

            if previouslySelectedDate < currentlySelectedDate {
                dayViewsToHighlight = findRangeToHighlight(from: previouslySelectedDayView, to: dayView)
                print("RANGE SELECTED: \(previouslySelectedDayView.date.commonDescription) to \(dayView.date.commonDescription)")
            } else {
                dayViewsToHighlight = findRangeToHighlight(from: dayView, to: previouslySelectedDayView)
                print("RANGE SELECTED: \(dayView.date.commonDescription) to \(previouslySelectedDayView.date.commonDescription)")
            }
        }
        print("adding selection: \(dayView.date.commonDescription)")
        selectionSet.insert(dayView)

        if let _ = animator {
            presentSelectionOnDayView(dayView)

            for dayViewToHighlight in dayViewsToHighlight {
                presentSelectionOnDayView(dayViewToHighlight)
            }
            highlightedDayViews = dayViewsToHighlight
        }
    }

    func findRangeToHighlight(from startDayView: DayView, to endDayView: DayView) -> [DayView] {

        var dayViewsToHighlight = [DayView]()
        var shouldAddToArray = false

        var allDayViews = [DayView]()
        for weekView in startDayView.weekView.monthView.weekViews {
            allDayViews += weekView.dayViews
        }
        for dayView in allDayViews {
            if dayView === startDayView {
                shouldAddToArray = true
                continue
            } else if dayView === endDayView {
                shouldAddToArray = false
                break
            }

            if shouldAddToArray {
                dayViewsToHighlight.append(dayView)
            }
        }
        return dayViewsToHighlight
    }
}
