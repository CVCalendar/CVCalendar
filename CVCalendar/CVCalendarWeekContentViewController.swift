//
//  CVCalendarWeekContentViewController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 12/04/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarWeekContentViewController: CVCalendarContentViewController {
    fileprivate var weekViews: [Identifier : WeekView]
    fileprivate var monthViews: [Identifier : MonthView]

    public override init(calendarView: CalendarView, frame: CGRect) {
        weekViews = [Identifier : WeekView]()
        monthViews = [Identifier : MonthView]()
        super.init(calendarView: calendarView, frame: frame)
        initialLoad(Foundation.Date())
    }

    public init(calendarView: CalendarView, frame: CGRect, presentedDate: Foundation.Date) {
        weekViews = [Identifier : WeekView]()
        monthViews = [Identifier : MonthView]()
        super.init(calendarView: calendarView, frame: frame)
        presentedMonthView = MonthView(calendarView: calendarView, date: presentedDate)
        presentedMonthView.updateAppearance(bounds)
        initialLoad(presentedDate)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Load & Reload

    public func initialLoad(_ date: Foundation.Date) {
        monthViews[previous] = getPreviousMonth(presentedMonthView.date)
        monthViews[presented] = presentedMonthView
        monthViews[following] = getFollowingMonth(presentedMonthView.date)

        presentedMonthView.mapDayViews { dayView in
            if self.matchedDays(dayView.date, CVDate(date: date)) {
                self.insertWeekView(dayView.weekView, withIdentifier: self.presented)
                self.calendarView.coordinator.flush()
                if self.calendarView.shouldAutoSelectDayOnWeekChange {
                    self.calendarView.touchController.receiveTouchOnDayView(dayView)
                    dayView.selectionView?.removeFromSuperview()
                }
            }
        }

        if let presented = weekViews[presented] {
            insertWeekView(getPreviousWeek(presented), withIdentifier: previous)
            insertWeekView(getFollowingWeek(presented), withIdentifier: following)
        }
    }

    public func reloadWeekViews() {
        for (identifier, weekView) in weekViews {
            weekView.frame.origin = CGPoint(x: CGFloat(indexOfIdentifier(identifier)) *
                scrollView.frame.width, y: 0)
            weekView.removeFromSuperview()
            scrollView.addSubview(weekView)
        }
    }

    // MARK: - Insertion

    public func insertWeekView(_ weekView: WeekView, withIdentifier identifier: Identifier) {
        let index = CGFloat(indexOfIdentifier(identifier))
        weekView.frame.origin = CGPoint(x: scrollView.bounds.width * index, y: 0)
        weekViews[identifier] = weekView
        scrollView.addSubview(weekView)
    }

    public func replaceWeekView(_ weekView: WeekView,
                                withIdentifier identifier: Identifier, animatable: Bool) {
        var weekViewFrame = weekView.frame
        weekViewFrame.origin.x = weekViewFrame.width * CGFloat(indexOfIdentifier(identifier))
        weekView.frame = weekViewFrame

        weekViews[identifier] = weekView

        if animatable {
            scrollView.scrollRectToVisible(weekViewFrame, animated: false)
        }
    }

    // MARK: - Load management

    public func scrolledLeft() {
        if let presentedWeek = weekViews[presented], let followingWeek = weekViews[following] {
            if pageLoadingEnabled {
                pageLoadingEnabled = false

                weekViews[previous]?.removeFromSuperview()
                replaceWeekView(presentedWeek, withIdentifier: previous, animatable: false)
                replaceWeekView(followingWeek, withIdentifier: self.presented, animatable: true)

                insertWeekView(getFollowingWeek(followingWeek), withIdentifier: following)
            }
        }
    }

    public func scrolledRight() {
        if let presentedWeek = weekViews[presented], let previousWeek = weekViews[previous] {
            if pageLoadingEnabled {
                pageLoadingEnabled = false

                weekViews[following]?.removeFromSuperview()
                replaceWeekView(presentedWeek, withIdentifier: following, animatable: false)
                replaceWeekView(previousWeek, withIdentifier: presented, animatable: true)

                insertWeekView(getPreviousWeek(previousWeek), withIdentifier: previous)
            }
        }
    }

    // MARK: - Override methods

    public override func updateFrames(_ rect: CGRect) {
        super.updateFrames(rect)

        for monthView in monthViews.values {
            monthView.reloadViewsWithRect(rect != CGRect.zero ? rect : scrollView.bounds)
        }

        reloadWeekViews()

        if let presented = weekViews[presented] {
            scrollView.scrollRectToVisible(presented.frame, animated: false)
        }
    }

    public override func performedDayViewSelection(_ dayView: DayView) {
        if dayView.isOut && calendarView.shouldScrollOnOutDayViewSelection {
            if dayView.date.day > 20 {
                let presentedDate = dayView.monthView.date
                calendarView.presentedDate = CVDate(date: self.dateBeforeDate(presentedDate!))
                presentPreviousView(dayView)
            } else {
                let presentedDate = dayView.monthView.date
                calendarView.presentedDate = CVDate(date: self.dateAfterDate(presentedDate!))
                presentNextView(dayView)
            }
        }
    }

    public override func presentPreviousView(_ view: UIView?) {
        if presentationEnabled {
            presentationEnabled = false
            guard let extra = weekViews[following],
                let presented = weekViews[presented],
                let previous = weekViews[previous] else {
                    return
            }

            UIView.animate(withDuration: toggleDateAnimationDuration, delay: 0,
                                       options: UIViewAnimationOptions.curveEaseInOut,
                                       animations: {
                self.prepareTopMarkersOnWeekView(presented, hidden: false)

                extra.frame.origin.x += self.scrollView.frame.width
                presented.frame.origin.x += self.scrollView.frame.width
                previous.frame.origin.x += self.scrollView.frame.width

                self.replaceWeekView(presented, withIdentifier: self.following, animatable: false)
                self.replaceWeekView(previous, withIdentifier: self.presented, animatable: false)
            }) { _ in
                extra.removeFromSuperview()
                self.insertWeekView(self.getPreviousWeek(previous), withIdentifier: self.previous)
                self.updateSelection()
                self.presentationEnabled = true

                for weekView in self.weekViews.values {
                    self.prepareTopMarkersOnWeekView(weekView, hidden: false)
                }
            }
        }
    }

    public override func presentNextView(_ view: UIView?) {
        if presentationEnabled {
            presentationEnabled = false
            guard let extra = weekViews[previous],
                let presented = weekViews[presented],
                let following = weekViews[following] else {
                    return
            }

            UIView.animate(withDuration: 0.5, delay: 0,
                                       options: UIViewAnimationOptions(),
                                       animations: {
                self.prepareTopMarkersOnWeekView(presented, hidden: false)

                extra.frame.origin.x -= self.scrollView.frame.width
                presented.frame.origin.x -= self.scrollView.frame.width
                following.frame.origin.x -= self.scrollView.frame.width

                self.replaceWeekView(presented, withIdentifier: self.previous, animatable: false)
                self.replaceWeekView(following, withIdentifier: self.presented, animatable: false)
            }) { _ in
                extra.removeFromSuperview()
                self.insertWeekView(self.getFollowingWeek(following),
                                    withIdentifier: self.following)
                self.updateSelection()
                self.presentationEnabled = true

                for weekView in self.weekViews.values {
                    self.prepareTopMarkersOnWeekView(weekView, hidden: false)
                }
            }
        }

    }

    public override func updateDayViews(_ hidden: Bool) {
        setDayOutViewsVisible(hidden)
    }

    fileprivate var togglingBlocked = false
    public override func togglePresentedDate(_ date: Foundation.Date) {
        let presentedDate = CVDate(date: date)
        guard let _ = monthViews[presented],
            let presentedWeekView = weekViews[presented],
            let selectedDate = calendarView.coordinator.selectedDayView?.date else {
                return
        }

        if !matchedDays(selectedDate, CVDate(date: date)) && !togglingBlocked {
            if !matchedWeeks(presentedDate, selectedDate) {
                togglingBlocked = true

                weekViews[previous]?.removeFromSuperview()
                weekViews[following]?.removeFromSuperview()

                let currentMonthView = MonthView(calendarView: calendarView, date: date)
                currentMonthView.updateAppearance(scrollView.bounds)

                monthViews[presented] = currentMonthView
                monthViews[previous] = getPreviousMonth(date)
                monthViews[following] = getFollowingMonth(date)

                let currentDate = CVDate(date: date)
                calendarView.presentedDate = currentDate

                var currentWeekView: WeekView!
                currentMonthView.mapDayViews { dayView in
                    if self.matchedDays(currentDate, dayView.date) {
                        if let weekView = dayView.weekView {
                            currentWeekView = weekView
                            currentWeekView.alpha = 0
                        }
                    }
                }

                insertWeekView(getPreviousWeek(currentWeekView), withIdentifier: previous)
                insertWeekView(currentWeekView, withIdentifier: presented)
                insertWeekView(getFollowingWeek(currentWeekView), withIdentifier: following)

                UIView.animate(withDuration: 0.8, delay: 0,
                                           options: UIViewAnimationOptions(),
                                           animations: {
                    presentedWeekView.alpha = 0
                    currentWeekView.alpha = 1
                }) {  _ in
                    presentedWeekView.removeFromSuperview()
                    self.selectDayViewWithDay(currentDate.day, inWeekView: currentWeekView)
                    self.togglingBlocked = false
                }
            } else {
                if let currentWeekView = weekViews[presented] {
                    selectDayViewWithDay(presentedDate.day, inWeekView: currentWeekView)
                }
            }
        }
    }
}

// MARK: - WeekView management

extension CVCalendarWeekContentViewController {

    public func getPresentedWeek() -> WeekView? {
        guard let currentWeekView = weekViews[presented] else {
            return nil
        }

        return currentWeekView
    }

    public func getPreviousWeek(_ presentedWeekView: WeekView) -> WeekView {
        if let presentedMonthView = monthViews[presented],
            let previousMonthView = monthViews[previous] ,
            presentedWeekView.monthView == presentedMonthView {
                for weekView in presentedMonthView.weekViews {
                    if weekView.index == presentedWeekView.index - 1 {
                        return weekView
                    }
                }

                for weekView in previousMonthView.weekViews {
                    if weekView.index == previousMonthView.weekViews.count - 1 {
                        return weekView
                    }
                }
        } else if let previousMonthView = monthViews[previous] {
            monthViews[following] = monthViews[presented]
            monthViews[presented] = monthViews[previous]
            monthViews[previous] = getPreviousMonth(previousMonthView.date)

            presentedMonthView = monthViews[previous]!
        }

        return getPreviousWeek(presentedWeekView)
    }

    public func getFollowingWeek(_ presentedWeekView: WeekView) -> WeekView {
        if let presentedMonthView = monthViews[presented],
            let followingMonthView = monthViews[following] ,
            presentedWeekView.monthView == presentedMonthView {
                for weekView in presentedMonthView.weekViews {
                    if weekView.index == presentedWeekView.index + 1 {
                        return weekView
                    }
                }

                for weekView in followingMonthView.weekViews {
                    if weekView.index == 0 {
                        return weekView
                    }
                }
        } else if let followingMonthView = monthViews[following] {
            monthViews[previous] = monthViews[presented]
            monthViews[presented] = monthViews[following]
            monthViews[following] = getFollowingMonth(followingMonthView.date)

            presentedMonthView = monthViews[following]!
        }

        return getFollowingWeek(presentedWeekView)
    }
}

// MARK: - MonthView management

extension CVCalendarWeekContentViewController {
    public func getFollowingMonth(_ date: Foundation.Date) -> MonthView {
        let calendarManager = calendarView.manager
        let firstDate = calendarManager?.monthDateRange(date).monthStartDate
        var components = Manager.componentsForDate(firstDate!)

        components.month! += 1

        let newDate = Calendar.current.date(from: components)!
        let monthView = MonthView(calendarView: calendarView, date: newDate)
        let frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width,
                           height: scrollView.bounds.height)

        monthView.updateAppearance(frame)

        return monthView
    }

    public func getPreviousMonth(_ date: Foundation.Date) -> MonthView {
        let firstDate = calendarView.manager.monthDateRange(date).monthStartDate
        var components = Manager.componentsForDate(firstDate)

        components.month! -= 1

        let newDate = Calendar.current.date(from: components)!
        let monthView = MonthView(calendarView: calendarView, date: newDate)
        let frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width,
                           height: scrollView.bounds.height)

        monthView.updateAppearance(frame)

        return monthView
    }

}

// MARK: - Visual preparation

extension CVCalendarWeekContentViewController {
    public func prepareTopMarkersOnWeekView(_ weekView: WeekView, hidden: Bool) {
        weekView.mapDayViews { dayView in
            dayView.topMarker?.isHidden = hidden
        }
    }

    public func setDayOutViewsVisible(_ visible: Bool) {
        for monthView in monthViews.values {
            monthView.mapDayViews { dayView in
                if dayView.isOut {
                    if !visible {
                        dayView.alpha = 0
                        dayView.isHidden = false
                    }

                    UIView.animate(withDuration: 0.5, delay: 0,
                        options: UIViewAnimationOptions(),
                        animations: {
                            dayView.alpha = visible ? 0 : 1
                            },
                        completion: { _ in
                            if visible {
                                dayView.alpha = 1
                                dayView.isHidden = true
                                dayView.isUserInteractionEnabled = false
                            } else {
                                dayView.isUserInteractionEnabled = true
                            }
                    })
                }
            }
        }
    }

    public func updateSelection() {
        let coordinator = calendarView.coordinator
        if let selected = coordinator?.selectedDayView {
            for (index, monthView) in monthViews {
                if indexOfIdentifier(index) != 1 {
                    monthView.mapDayViews { dayView in
                        if dayView == selected {
                            dayView.setDeselectedWithClearing(true)
                            coordinator?.dequeueDayView(dayView)
                        }
                    }
                }
            }
        }

        if let presentedWeekView = weekViews[presented],
            let presentedMonthView = monthViews[presented] {
                self.presentedMonthView = presentedMonthView
                calendarView.presentedDate = CVDate(date: presentedMonthView.date)

                var presentedDate: CVDate!
                for dayView in presentedWeekView.dayViews {
                    if !dayView.isOut {
                        presentedDate = dayView.date
                        break
                    }
                }

                if let selected = coordinator?.selectedDayView ,
                    !matchedWeeks(selected.date, presentedDate) &&
                        calendarView.shouldAutoSelectDayOnWeekChange {
                            let current = CVDate(date: Foundation.Date())

                            if matchedWeeks(current, presentedDate) {
                                selectDayViewWithDay(current.day, inWeekView: presentedWeekView)
                            } else {
                                selectDayViewWithDay(presentedDate.day,
                                                     inWeekView: presentedWeekView)
                            }
                }
        }
    }

    public func selectDayViewWithDay(_ day: Int, inWeekView weekView: WeekView) {
        let coordinator = calendarView.coordinator
        weekView.mapDayViews { dayView in
            if dayView.date.day == day && !dayView.isOut {
                if let selected = coordinator?.selectedDayView , selected != dayView {
                    self.calendarView.didSelectDayView(dayView)
                }

                coordinator?.performDayViewSingleSelection(dayView)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate

extension CVCalendarWeekContentViewController {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
        }

        let page = Int(floor((scrollView.contentOffset.x -
            scrollView.frame.width / 2) / scrollView.frame.width) + 1)
        if currentPage != page {
            currentPage = page
        }

        lastContentOffset = scrollView.contentOffset.x
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let presented = weekViews[presented] {
            prepareTopMarkersOnWeekView(presented, hidden: true)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if pageChanged {
            switch direction {
            case .left: scrolledLeft()
            case .right: scrolledRight()
            default: break
            }
        }

        updateSelection()
        pageLoadingEnabled = true
        direction = .none
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                         willDecelerate decelerate: Bool) {
        if decelerate {
            let rightBorder = scrollView.frame.width
            if scrollView.contentOffset.x <= rightBorder {
                direction = .right
            } else {
                direction = .left
            }
        }

        for weekView in self.weekViews.values {
            self.prepareTopMarkersOnWeekView(weekView, hidden: false)
        }
    }
}
