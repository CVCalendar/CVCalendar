//
//  CVCalendarMonthContentViewController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 12/04/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarMonthContentViewController: CVCalendarContentViewController, CVCalendarContentPresentationCoordinator {
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

        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current

        presentedMonthView.mapDayViews { dayView in
            if self.calendarView.shouldAutoSelectDayOnMonthChange &&
                self.matchedDays(dayView.date, CVDate(date: date, calendar: calendar)) {
                self.calendarView.coordinator.flush()
                self.calendarView.touchController.receiveTouchOnDayView(dayView)
                dayView.selectionView?.removeFromSuperview()
            }
        }

        checkScrollToPreviousDisabled()
        checkScrollToBeyondDisabled()

        calendarView.presentedDate = CVDate(date: presentedMonthView.date, calendar: calendar)
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
        checkScrollToPreviousDisabled()
        checkScrollToBeyondDisabled()
        calendarView.coordinator?.disableDays(in: presentedMonthView)
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
        if let presented = monthViews[presented], let following = monthViews[following] {
            if pageLoadingEnabled {
                pageLoadingEnabled = false

                monthViews[previous]?.removeFromSuperview()

                replaceMonthView(presented, withIdentifier: previous, animatable: false)
                replaceMonthView(following, withIdentifier: self.presented, animatable: true)

                insertMonthView(getFollowingMonth(following.date), withIdentifier: self.following)
                self.calendarView.delegate?.didShowNextMonthView?(following.date)
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
            let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current

            if dayView.date.day > 20 {
                let presentedDate = dayView.monthView.date
                calendarView.presentedDate = CVDate(date: self.dateBeforeDate(presentedDate!), calendar: calendar)
                presentPreviousView(dayView)
            } else {
                let presentedDate = dayView.monthView.date
                calendarView.presentedDate = CVDate(date: self.dateAfterDate(presentedDate!), calendar: calendar)
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

            UIView.animate(withDuration: 0.5, delay: 0,
                           options: UIView.AnimationOptions(),
                           animations: { [weak self] in
                            guard let strongSelf = self else {
                                return
                            }
                            strongSelf.prepareTopMarkersOnMonthView(presented, hidden: self?.calendarView.delegate?.shouldHideTopMarkerOnPresentedView?() ?? true)

                            extra.frame.origin.x += strongSelf.scrollView.frame.width
                            presented.frame.origin.x += strongSelf.scrollView.frame.width
                            previous.frame.origin.x += strongSelf.scrollView.frame.width

                            strongSelf.replaceMonthView(presented, withIdentifier: strongSelf.following, animatable: false)
                            strongSelf.replaceMonthView(previous, withIdentifier: strongSelf.presented, animatable: false)
                            strongSelf.presentedMonthView = previous

                            strongSelf.updateLayoutIfNeeded()
            }) { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                extra.removeFromSuperview()
                strongSelf.insertMonthView(strongSelf.getPreviousMonth(previous.date),
                                     withIdentifier: strongSelf.previous)
                strongSelf.updateSelection()
                strongSelf.presentationEnabled = true

                for monthView in strongSelf.monthViews.values {
                    strongSelf.prepareTopMarkersOnMonthView(monthView, hidden: false)
                }
            }
            self.calendarView.delegate?.didShowPreviousMonthView?(previous.date)
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
                           options: UIView.AnimationOptions(),
                           animations: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.prepareTopMarkersOnMonthView(presented, hidden: self?.calendarView.delegate?.shouldHideTopMarkerOnPresentedView?() ?? true)

                extra.frame.origin.x -= strongSelf.scrollView.frame.width
                presented.frame.origin.x -= strongSelf.scrollView.frame.width
                following.frame.origin.x -= strongSelf.scrollView.frame.width

                strongSelf.replaceMonthView(presented, withIdentifier: strongSelf.previous, animatable: false)
                strongSelf.replaceMonthView(following, withIdentifier: strongSelf.presented, animatable: false)
                strongSelf.presentedMonthView = following

                strongSelf.updateLayoutIfNeeded()
            }) { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }

                extra.removeFromSuperview()
                strongSelf.insertMonthView(strongSelf.getFollowingMonth(following.date), withIdentifier: strongSelf.following)
                strongSelf.updateSelection()
                strongSelf.presentationEnabled = true

                for monthView in strongSelf.monthViews.values {
                    strongSelf.prepareTopMarkersOnMonthView(monthView, hidden: false)
                }
            }
            self.calendarView.delegate?.didShowNextMonthView?(following.date)
        }
    }

    public override func updateDayViews(shouldShow: Bool) {
      setDayOutViewsVisible(monthViews: monthViews, visible: shouldShow)
    }

    fileprivate var togglingBlocked = false
    public override func togglePresentedDate(_ date: Foundation.Date) {
        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current

        let presentedDate = CVDate(date: date, calendar: calendar)
        guard let presentedMonth = monthViews[presented] else {
            return
        }

        var isMatchedDays = false
        var isMatchedMonths = false

        // selectedDayView would be nil if shouldAutoSelectDayOnMonthChange returns false
        // we want to still allow the user to toggle to a date even if there is nothing selected
        if let selectedDate = calendarView.coordinator.selectedDayView?.date {
            isMatchedDays = matchedDays(selectedDate, presentedDate)
            isMatchedMonths = matchedMonths(presentedDate, selectedDate)
        }

        if !isMatchedDays && !togglingBlocked {
            if !isMatchedMonths {
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

                calendarView.presentedDate = CVDate(date: date, calendar: calendar)

                UIView.animate(withDuration: toggleDateAnimationDuration, delay: 0,
                               options: UIView.AnimationOptions(),
                               animations: {
                    presentedMonth.alpha = 0
                    currentMonthView.alpha = 1
                }) { [weak self] _ in
                    presentedMonth.removeFromSuperview()
                    self?.selectDayViewWithDay(presentedDate.day, inMonthView: currentMonthView)
                    self?.togglingBlocked = false
                    self?.updateLayoutIfNeeded()
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
        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current
        let firstDate = calendarView.manager.monthDateRange(date).monthStartDate
        var components = Manager.componentsForDate(firstDate, calendar: calendar)

        components.month! += 1

        let newDate = calendar.date(from: components)!
        let frame = scrollView.bounds
        let monthView = MonthView(calendarView: calendarView, date: newDate)

        monthView.updateAppearance(frame)

        return monthView
    }

    public func getPreviousMonth(_ date: Foundation.Date) -> MonthView {
        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current
        let firstDate = calendarView.manager.monthDateRange(date).monthStartDate
        var components = Manager.componentsForDate(firstDate, calendar: calendar)

        components.month! -= 1

        let newDate = calendar.date(from: components)!
        let frame = scrollView.bounds
        let monthView = MonthView(calendarView: calendarView, date: newDate)

        monthView.updateAppearance(frame)

        return monthView
    }

    func checkScrollToPreviousDisabled() {
        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current

        guard let presentedMonth = monthViews[presented],
            let disableScrollingBeforeDate = calendarView.disableScrollingBeforeDate else {
                return
        }

        let convertedDate = CVDate(date: disableScrollingBeforeDate, calendar: calendar)
        presentedMonth.mapDayViews({ dayView in
            if matchedDays(convertedDate, dayView.date) {
                presentedMonth.allowScrollToPreviousMonth = false
            }
        })
    }

    func checkScrollToBeyondDisabled() {
        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current

        guard let presentedMonth = monthViews[presented],
            let disableScrollingBeyondDate = calendarView.disableScrollingBeyondDate else {
                return
        }

        let convertedDate = CVDate(date: disableScrollingBeyondDate, calendar: calendar)
        presentedMonth.mapDayViews({ dayView in
            if matchedDays(convertedDate, dayView.date) {
                presentedMonth.allowScrollToNextMonth = false
            }
        })
    }
}

// MARK: - Visual preparation

extension CVCalendarMonthContentViewController {
    public func prepareTopMarkersOnMonthView(_ monthView: MonthView, hidden: Bool) {
        monthView.mapDayViews { dayView in
            dayView.topMarker?.isHidden = hidden
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

        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current

        if let presentedMonthView = monthViews[presented] {
            self.presentedMonthView = presentedMonthView
            calendarView.presentedDate = CVDate(date: presentedMonthView.date, calendar: calendar)

            if let selected = coordinator?.selectedDayView,
                let selectedMonthView = selected.monthView ,
                !matchedMonths(CVDate(date: selectedMonthView.date, calendar: calendar),
                               CVDate(date: presentedMonthView.date, calendar: calendar)) &&
                    calendarView.shouldAutoSelectDayOnMonthChange {
                let current = CVDate(date: Date(), calendar: calendar)
                let presented = CVDate(date: presentedMonthView.date, calendar: calendar)

                if matchedMonths(current, presented) {
                    selectDayViewWithDay(current.day, inMonthView: presentedMonthView)
                } else {
                    selectDayViewWithDay(CVDate(date: calendarView.manager
                        .monthDateRange(presentedMonthView.date).monthStartDate, calendar: calendar).day,
                                         inMonthView: presentedMonthView)
                }
            }

            if coordinator?.selectedStartDayView != nil || coordinator?.selectedEndDayView != nil {
                coordinator?.highlightSelectedDays(in: presentedMonthView)
            }

            coordinator?.disableDays(in: presentedMonthView)
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

        //restricts scrolling to previous months
        if monthViews[presented]?.allowScrollToPreviousMonth == false,
            scrollView.contentOffset.x < scrollView.frame.width {
            scrollView.setContentOffset(CGPoint(x: scrollView.frame.width, y: 0), animated: false)
            return
        }

        //restricts scrolling to next months
        if monthViews[presented]?.allowScrollToNextMonth == false,
            scrollView.contentOffset.x > scrollView.frame.width {
            scrollView.setContentOffset(CGPoint(x: scrollView.frame.width, y: 0), animated: false)
            return
        }

        var page = 0
        if (scrollView.contentOffset.x - scrollView.frame.width) == 0 {
                page = 1
        } else {
            page = Int(floor((scrollView.contentOffset.x - scrollView.frame.width / 2) / scrollView.frame.width) + 1)
        }
        
        if currentPage != page {
            currentPage = page
        }

        lastContentOffset = scrollView.contentOffset.x
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let presented = monthViews[presented] {
            prepareTopMarkersOnMonthView(presented, hidden: self.calendarView.delegate?.shouldHideTopMarkerOnPresentedView?() ?? true)
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
