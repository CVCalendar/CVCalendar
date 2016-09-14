//
//  CVCalendarMonthContentViewController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 12/04/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarMonthContentViewController: CVCalendarContentViewController {
    fileprivate var monthViews: [Identifier : MonthView]

    public override init(calendarView: CalendarView, frame: CGRect) {
        monthViews = [Identifier : MonthView]()
        super.init(calendarView: calendarView, frame: frame)
        initialLoad(presentedMonthView.date)
    }

    public init(calendarView: CalendarView, frame: CGRect, presentedDate: Foundation.Date) {
        monthViews = [Identifier : MonthView]()
        super.init(calendarView: calendarView, frame: frame)
        presentedMonthView = MonthView(calendarView: calendarView, date: presentedDate)
        presentedMonthView.updateAppearance(scrollView.bounds)
        initialLoad(presentedDate)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Load & Reload

    public func initialLoad(_ date: Foundation.Date) {
        insertMonthView(getPreviousMonth(date), withIdentifier: previous)
        insertMonthView(presentedMonthView, withIdentifier: presented)
        insertMonthView(getFollowingMonth(date), withIdentifier: following)

        presentedMonthView.mapDayViews { dayView in
            if self.calendarView.shouldAutoSelectDayOnMonthChange &&
                self.matchedDays(dayView.date, CVDate(date: date)) {
                    self.calendarView.coordinator.flush()
                    self.calendarView.touchController.receiveTouchOnDayView(dayView)
                    dayView.selectionView?.removeFromSuperview()
            }
        }

        calendarView.presentedDate = CVDate(date: presentedMonthView.date)
    }

    public func reloadMonthViews() {
        for (identifier, monthView) in monthViews {
            monthView.frame.origin.x =
                CGFloat(indexOfIdentifier(identifier)) * scrollView.frame.width
            monthView.removeFromSuperview()
            scrollView.addSubview(monthView)
        }
    }

    // MARK: - Insertion

    public func insertMonthView(_ monthView: MonthView, withIdentifier identifier: Identifier) {
        let index = CGFloat(indexOfIdentifier(identifier))

        monthView.frame.origin = CGPoint(x: scrollView.bounds.width * index, y: 0)
        monthViews[identifier] = monthView
        scrollView.addSubview(monthView)
    }

    public func replaceMonthView(_ monthView: MonthView,
                                 withIdentifier identifier: Identifier, animatable: Bool) {
        var monthViewFrame = monthView.frame
        monthViewFrame.origin.x = monthViewFrame.width * CGFloat(indexOfIdentifier(identifier))
        monthView.frame = monthViewFrame

        monthViews[identifier] = monthView

        if animatable {
            scrollView.scrollRectToVisible(monthViewFrame, animated: false)
        }
    }

    // MARK: - Load management

    public func scrolledLeft() {
        if let presentedMonth = monthViews[presented], let followingMonth = monthViews[following] {
            if pageLoadingEnabled {
                pageLoadingEnabled = false

                monthViews[previous]?.removeFromSuperview()
                replaceMonthView(presentedMonth, withIdentifier: previous, animatable: false)
                replaceMonthView(followingMonth, withIdentifier: presented, animatable: true)

                insertMonthView(getFollowingMonth(followingMonth.date),
                                withIdentifier: following)
                self.calendarView.delegate?.didShowNextMonthView?(followingMonth.date)
            }
        }
    }

    public func scrolledRight() {
        if let previous = monthViews[previous], let presented = monthViews[presented] {
            if pageLoadingEnabled {
                pageLoadingEnabled = false

                monthViews[following]?.removeFromSuperview()
                replaceMonthView(previous, withIdentifier: self.presented, animatable: true)
                replaceMonthView(presented, withIdentifier: following, animatable: false)

                insertMonthView(getPreviousMonth(previous.date), withIdentifier: self.previous)
                self.calendarView.delegate?.didShowPreviousMonthView?(previous.date)
            }
        }
    }

    // MARK: - Override methods

    public override func updateFrames(_ rect: CGRect) {
        super.updateFrames(rect)

        for monthView in monthViews.values {
            monthView.reloadViewsWithRect(rect != CGRect.zero ? rect : scrollView.bounds)
        }

        reloadMonthViews()

        if let presented = monthViews[presented] {
            if scrollView.frame.height != presented.potentialSize.height {
                updateHeight(presented.potentialSize.height, animated: false)
            }

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

            guard let extra = monthViews[following],
                let presented = monthViews[presented],
                let previous = monthViews[previous] else {
                    return
            }

            UIView.animate(withDuration: toggleDateAnimationDuration, delay: 0,
                                       options: UIViewAnimationOptions.curveEaseInOut,
                                       animations: {
                self.prepareTopMarkersOnMonthView(presented, hidden: true)

                extra.frame.origin.x += self.scrollView.frame.width
                presented.frame.origin.x += self.scrollView.frame.width
                previous.frame.origin.x += self.scrollView.frame.width

                self.replaceMonthView(presented, withIdentifier: self.following, animatable: false)
                self.replaceMonthView(previous, withIdentifier: self.presented, animatable: false)
                self.presentedMonthView = previous

                self.updateLayoutIfNeeded()
            }) { _ in
                extra.removeFromSuperview()
                self.insertMonthView(self.getPreviousMonth(previous.date),
                                     withIdentifier: self.previous)
                self.updateSelection()
                self.presentationEnabled = true

                for monthView in self.monthViews.values {
                    self.prepareTopMarkersOnMonthView(monthView, hidden: false)
                }
            }
        }
    }

    public override func presentNextView(_ view: UIView?) {
        if presentationEnabled {
            presentationEnabled = false
            guard let extra = monthViews[previous],
                let presented = monthViews[presented],
                let following = monthViews[following] else {
                    return
            }

            UIView.animate(withDuration: 0.5, delay: 0,
                                       options: UIViewAnimationOptions(),
                                       animations: {
                self.prepareTopMarkersOnMonthView(presented, hidden: true)

                extra.frame.origin.x -= self.scrollView.frame.width
                presented.frame.origin.x -= self.scrollView.frame.width
                following.frame.origin.x -= self.scrollView.frame.width

                self.replaceMonthView(presented, withIdentifier: self.previous, animatable: false)
                self.replaceMonthView(following, withIdentifier: self.presented, animatable: false)
                self.presentedMonthView = following

                self.updateLayoutIfNeeded()
            }) { _ in
                extra.removeFromSuperview()
                self.insertMonthView(self.getFollowingMonth(following.date),
                                     withIdentifier: self.following)
                self.updateSelection()
                self.presentationEnabled = true

                for monthView in self.monthViews.values {
                    self.prepareTopMarkersOnMonthView(monthView, hidden: false)
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
        guard let presentedMonth = monthViews[presented],
            let selectedDate = calendarView.coordinator.selectedDayView?.date else {
                return
        }

        if !matchedDays(selectedDate, presentedDate) && !togglingBlocked {
            if !matchedMonths(presentedDate, selectedDate) {
                togglingBlocked = true

                monthViews[previous]?.removeFromSuperview()
                monthViews[following]?.removeFromSuperview()
                insertMonthView(getPreviousMonth(date), withIdentifier: previous)
                insertMonthView(getFollowingMonth(date), withIdentifier: following)

                let currentMonthView = MonthView(calendarView: calendarView, date: date)
                currentMonthView.updateAppearance(scrollView.bounds)
                currentMonthView.alpha = 0

                insertMonthView(currentMonthView, withIdentifier: presented)
                presentedMonthView = currentMonthView

                calendarView.presentedDate = CVDate(date: date)

                UIView.animate(withDuration: 0.8, delay: 0,
                                           options: UIViewAnimationOptions(),
                                           animations: {
                    presentedMonth.alpha = 0
                    currentMonthView.alpha = 1
                }) { _ in
                    presentedMonth.removeFromSuperview()
                    self.selectDayViewWithDay(presentedDate.day, inMonthView: currentMonthView)
                    self.togglingBlocked = false
                    self.updateLayoutIfNeeded()
                }
            } else {
                if let currentMonthView = monthViews[presented] {
                    selectDayViewWithDay(presentedDate.day, inMonthView: currentMonthView)
                }
            }
        }
    }

}

// MARK: - Month management

extension CVCalendarMonthContentViewController {
    public func getFollowingMonth(_ date: Foundation.Date) -> MonthView {
        let firstDate = calendarView.manager.monthDateRange(date).monthStartDate
        var components = Manager.componentsForDate(firstDate)

        components.month! += 1

        let newDate = Calendar.current.date(from: components)!
        let frame = scrollView.bounds
        let monthView = MonthView(calendarView: calendarView, date: newDate)

        monthView.updateAppearance(frame)

        return monthView
    }

    public func getPreviousMonth(_ date: Foundation.Date) -> MonthView {
        let firstDate = calendarView.manager.monthDateRange(date).monthStartDate
        var components = Manager.componentsForDate(firstDate)

        components.month! -= 1

        let newDate = Calendar.current.date(from: components)!
        let frame = scrollView.bounds
        let monthView = MonthView(calendarView: calendarView, date: newDate)

        monthView.updateAppearance(frame)

        return monthView
    }
}

// MARK: - Visual preparation

extension CVCalendarMonthContentViewController {
    public func prepareTopMarkersOnMonthView(_ monthView: MonthView, hidden: Bool) {
        monthView.mapDayViews { dayView in
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
                    monthView.mapDayViews {
                        dayView in

                        if dayView == selected {
                            dayView.setDeselectedWithClearing(true)
                            coordinator?.dequeueDayView(dayView)
                        }
                    }
                }
            }
        }

        if let presentedMonthView = monthViews[presented] {
            self.presentedMonthView = presentedMonthView
            calendarView.presentedDate = CVDate(date: presentedMonthView.date)

            if let selected = coordinator?.selectedDayView,
                let selectedMonthView = selected.monthView ,
                !matchedMonths(CVDate(date: selectedMonthView.date),
                               CVDate(date: presentedMonthView.date)) &&
                    calendarView.shouldAutoSelectDayOnMonthChange {
                        let current = CVDate(date: Date())
                        let presented = CVDate(date: presentedMonthView.date)

                        if matchedMonths(current, presented) {
                            selectDayViewWithDay(current.day, inMonthView: presentedMonthView)
                        } else {
                            selectDayViewWithDay(CVDate(date: calendarView.manager
                                .monthDateRange(presentedMonthView.date).monthStartDate).day,
                                                 inMonthView: presentedMonthView)
                        }
            }
        }

    }

    public func selectDayViewWithDay(_ day: Int, inMonthView monthView: CVCalendarMonthView) {
        let coordinator = calendarView.coordinator
        monthView.mapDayViews { dayView in
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

extension CVCalendarMonthContentViewController {
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
        if let presented = monthViews[presented] {
            prepareTopMarkersOnMonthView(presented, hidden: true)
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
        updateLayoutIfNeeded()
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

        for monthView in monthViews.values {
            prepareTopMarkersOnMonthView(monthView, hidden: false)
        }
    }
}
