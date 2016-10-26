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
    public var selectedStartDayView: DayView?
    public var selectedEndDayView: DayView?
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
//            for dayViewInQueue in selectionSet {
//                if dayView.calendarView != nil {
//                    presentDeselectionOnDayView(dayViewInQueue)
//                }
//            }
//            for highlightedDayView in highlightedDayViews {
//                if dayView.calendarView != nil {
//                    presentDeselectionOnDayView(highlightedDayView)
//                }
//            }

            clearSelection(in: dayView.monthView)
            flush()

            selectedStartDayView = dayView
            selectionSet.insert(dayView)
            presentSelectionOnDayView(dayView)

            if calendarView.maxSelectableRange > 0 {
                disableDays(in: dayView.monthView)
            }

        } else if selectionSet.count == 1 {
            guard let previouslySelectedDayView = selectionSet.first,
                let previouslySelectedDate = selectionSet.first?.date.convertedDate(),
                let currentlySelectedDate = dayView.date.convertedDate() else {
                    return
            }

            if previouslySelectedDayView === dayView {
                return
            }

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
            highlightPreSelectedDates(in: dayView.monthView)

        } else {
            selectedStartDayView = dayView
            selectionSet.insert(dayView)
            presentSelectionOnDayView(dayView)

            if calendarView.maxSelectableRange > 0 {
                disableDays(in: dayView.weekView.monthView)
            }
        }
    }

    func highlightPreSelectedDates(in monthView: MonthView) {
        var startDateInMonthView = false
        var endDateInMonthView = false

        clearSelection(in: monthView)

        monthView.mapDayViews { dayView in
            if dayView.date.convertedDate() == selectedStartDayView?.date.convertedDate() {
                startDateInMonthView = true
            }
            if dayView.date.convertedDate() == selectedEndDayView?.date.convertedDate() {
                endDateInMonthView = true
            }
        }

        var shouldAddToArray = false
        if !startDateInMonthView && endDateInMonthView {
            shouldAddToArray = true
        }

        monthView.mapDayViews { dayView in
            if shouldAddToArray {
                presentSelectionOnDayView(dayView)
                highlightedDayViews.append(dayView)
            }
            if dayView.date.convertedDate() == selectedStartDayView?.date.convertedDate() {
                presentSelectionOnDayView(dayView)
                highlightedDayViews.append(dayView)

                shouldAddToArray = true
            }
            if dayView.date.convertedDate() == selectedEndDayView?.date.convertedDate() {
                presentSelectionOnDayView(dayView)
                highlightedDayViews.append(dayView)
                shouldAddToArray = false
            }
        }
    }

    func disableDays(in monthView: MonthView) {
        var maxSelectableDate: Date? = nil
        if let startDate = selectedStartDayView?.date.convertedDate() {
            maxSelectableDate = calendarView.manager.date(after: calendarView.maxSelectableRange, from: startDate)
        }

        let startDate = selectedStartDayView?.date.convertedDate()

        disableDays(inMonth: monthView, beforeDate: startDate, afterDate: maxSelectableDate)
    }

    func disableDays(inMonth monthView:MonthView, beforeDate: Date?, afterDate: Date?) {
        print("disabling days")
        monthView.mapDayViews { dayView in
            if let currDate = dayView.date.convertedDate(),
               let label = dayView.dayLabel {

                if let earliestDate = calendarView.earliestSelectableDate,
                    currDate.compare(earliestDate) == .orderedAscending {
                    dayView.isUserInteractionEnabled = false
                    presentDeselectionOnDayView(dayView)
                }

                if let beforeDate = beforeDate,
                   currDate.compare(beforeDate) == .orderedAscending {
//                    label.textColor = UIColor.lightGray
                    dayView.isUserInteractionEnabled = false
                    presentDeselectionOnDayView(dayView)
                }

                if let afterDate = afterDate,
                   currDate.compare(afterDate) == .orderedDescending || currDate.compare(afterDate) == .orderedSame {
//                    label.textColor = UIColor.lightGray
                    dayView.isUserInteractionEnabled = false
                    presentDeselectionOnDayView(dayView)
                }

                if let latestDate = calendarView.latestSelectableDate,
                    currDate.compare(latestDate) == .orderedDescending {
                    dayView.isUserInteractionEnabled = false
                    presentDeselectionOnDayView(dayView)
                }
            }
        }
    }

    func clearSelection(in monthView: MonthView) {
        monthView.mapDayViews { dayView in
//            print("clearing day disable in \(dayView.date.commonDescription)")
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
                    presentDeselectionOnDayView(dayView)
                }
            }
        }
    }
}
