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
    fileprivate unowned let calendarView: CalendarView

    // MARK: - Public properties
    public var selectedStartDayView: DayView?
    public var selectedEndDayView: DayView?
    public weak var selectedDayView: CVCalendarDayView?
    public var animator: CVCalendarViewAnimator! {
        return calendarView.animator
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
        if dayView != selectedDayView && calendarView.shouldSelectRange == false {
            selectionSet.remove(dayView)
            dayView.setDeselectedWithClearing(true)
        }
    }

    public func dequeueDayView(_ dayView: DayView) {
        selectionSet.remove(dayView)
    }

    public func flush() {
        selectedDayView = nil
        selectedEndDayView = nil
        selectedStartDayView = nil
        selectionSet.removeAll()
    }
}

// MARK: - Animator reference

private extension CVCalendarDayViewControlCoordinator {
    func presentSelectionOnDayView(_ dayView: DayView) {
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
        if selectionSet.count == 2 {
            clearSelection(in: dayView.monthView)
            flush()

            select(dayView: dayView)
        } else if selectionSet.count == 1 {
            guard let previouslySelectedDayView = selectionSet.first,
                let previouslySelectedDate = selectionSet.first?.date.convertedDate(),
                let currentlySelectedDate = dayView.date.convertedDate() else {
                    return
            }

            //prevent selection of same day twice for range
            if previouslySelectedDayView === dayView {
                return
            }

            //allows selection in reverse order (like selecting 5-10-16 first then 5-5-16) when maxselectable range is not present
            if previouslySelectedDate < currentlySelectedDate {
                selectedStartDayView = previouslySelectedDayView
                selectedEndDayView = dayView
                self.calendarView.delegate?.didSelectRange?(from: previouslySelectedDayView, to: dayView)
            } else {
                selectedStartDayView = dayView
                selectedEndDayView = previouslySelectedDayView
                self.calendarView.delegate?.didSelectRange?(from: dayView, to: previouslySelectedDayView)
            }

            selectionSet.insert(dayView)
            highlightSelectedDays(in: dayView.monthView)
        } else {
            select(dayView: dayView)
        }
    }

    public func highlightSelectedDays(in monthView: MonthView) {
        clearSelection(in: monthView)
        let startDate = selectedStartDayView?.date.convertedDate()
        let endDate = selectedEndDayView?.date.convertedDate()

        monthView.mapDayViews { dayView in
            if let currDate = dayView.date.convertedDate() {

                if let startDate = startDate,
                    currDate.compare(startDate) == .orderedSame {
                    presentSelectionOnDayView(dayView)
                }

                if let startDate = startDate,
                    let endDate = endDate,
                    currDate.compare(startDate) == .orderedDescending && currDate.compare(endDate) == .orderedAscending {
                    presentSelectionOnDayView(dayView)
                }

                if let endDate = endDate,
                    currDate.compare(endDate) == .orderedSame {
                    presentSelectionOnDayView(dayView)
                }
            }
        }
    }

    public func disableDays(in monthView: MonthView) {
        var maxSelectableDate: Date? = nil
        if let startDate = selectedStartDayView?.date.convertedDate() {
            maxSelectableDate = calendarView.manager.date(after: calendarView.maxSelectableRange, from: startDate)
        }

        let startDate = selectedStartDayView?.date.convertedDate()

        disableDays(inMonth: monthView, beforeDate: startDate, afterDate: maxSelectableDate)
    }

}

// MARK: - private selection and disabling methods

private extension CVCalendarDayViewControlCoordinator {

    func select(dayView: DayView) {
        selectedStartDayView = dayView
        selectionSet.insert(dayView)
        presentSelectionOnDayView(dayView)

        if calendarView.maxSelectableRange > 0 {
            disableDays(in: dayView.weekView.monthView)
        }
    }

    func disableDays(inMonth monthView:MonthView, beforeDate: Date?, afterDate: Date?) {
        monthView.mapDayViews { dayView in
            if let currDate = dayView.date.convertedDate() {

                if let earliestDate = calendarView.earliestSelectableDate,
                    currDate.compare(earliestDate) == .orderedAscending {
                    disableUserInteraction(for: dayView)
                }

                if let beforeDate = beforeDate,
                   currDate.compare(beforeDate) == .orderedAscending {
                    disableUserInteraction(for: dayView)
                }

                if let afterDate = afterDate,
                   currDate.compare(afterDate) == .orderedDescending || currDate.compare(afterDate) == .orderedSame {
                    disableUserInteraction(for: dayView)
                }

                if let latestDate = calendarView.latestSelectableDate,
                    currDate.compare(latestDate) == .orderedDescending {
                    disableUserInteraction(for: dayView)
                }
            }
        }
    }

    func disableUserInteraction(for dayView: DayView) {
        dayView.isUserInteractionEnabled = false
        presentDeselectionOnDayView(dayView)
    }

    func clearSelection(in monthView: MonthView) {
        monthView.mapDayViews { dayView in
            if let currDate = dayView.date.convertedDate() {
                var shouldEnable = true
                if let earliestDate = calendarView.earliestSelectableDate,
                    currDate.compare(earliestDate) == .orderedAscending {
                    shouldEnable = false
                }

                if let latestDate = calendarView.latestSelectableDate,
                    currDate.compare(latestDate) == .orderedDescending {
                    shouldEnable = false
                }
                if shouldEnable {
                    dayView.isUserInteractionEnabled = true
                }
                presentDeselectionOnDayView(dayView)
            }
        }
    }
}
