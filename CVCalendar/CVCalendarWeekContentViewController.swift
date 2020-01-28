//
//  CVCalendarWeekContentViewController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 12/04/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarWeekContentViewController: CVCalendarContentViewController, CVCalendarContentPresentationCoordinator {
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
            let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current
            if self.matchedDays(dayView.date, CVDate(date: date, calendar: calendar)) {
                self.insertWeekView(dayView.weekView, withIdentifier: self.presented)
                self.calendarView.coordinator.flush()
                if self.calendarView.shouldAutoSelectDayOnWeekChange {
                    self.calendarView.touchController.receiveTouchOnDayView(dayView)
                    dayView.selectionView?.removeFromSuperview()
                }
            }
        }
        
        checkScrollToPreviousDisabled()
        checkScrollToBeyondDisabled()

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
        
        checkScrollToPreviousDisabled()
        checkScrollToBeyondDisabled()
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
                if let dayViews = followingWeek.dayViews,
                   let fromDay = dayViews.first,
                   let toDay = dayViews.last {
                    self.calendarView.delegate?.didShowNextWeekView?(from: fromDay, to: toDay)
                }
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
                if let dayViews = previousWeek.dayViews,
                   let fromDay = dayViews.first,
                   let toDay = dayViews.last{
                    self.calendarView.delegate?.didShowPreviousWeekView?(from: fromDay, to: toDay)
                }
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
        //In a week view mode we don't need to scroll for a next week when dayOut selected
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
                                       options: UIView.AnimationOptions.curveEaseInOut,
                                       animations: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.prepareTopMarkersOnWeekView(presented, hidden: false)

                extra.frame.origin.x += strongSelf.scrollView.frame.width
                presented.frame.origin.x += strongSelf.scrollView.frame.width
                previous.frame.origin.x += strongSelf.scrollView.frame.width

                strongSelf.replaceWeekView(presented, withIdentifier: strongSelf.following, animatable: false)
                strongSelf.replaceWeekView(previous, withIdentifier: strongSelf.presented, animatable: false)
            }) { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                
                extra.removeFromSuperview()
                strongSelf.insertWeekView(strongSelf.getPreviousWeek(previous), withIdentifier: strongSelf.previous)
                strongSelf.updateSelection()
                strongSelf.presentationEnabled = true

                for weekView in strongSelf.weekViews.values {
                    strongSelf.prepareTopMarkersOnWeekView(weekView, hidden: false)
                }
            }
            if let dayViews = previous.dayViews,
               let fromDay = dayViews.first,
               let toDay = dayViews.last {
                self.calendarView.delegate?.didShowPreviousWeekView?(from: fromDay, to: toDay)
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
                                       options: UIView.AnimationOptions(),
                                       animations: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.prepareTopMarkersOnWeekView(presented, hidden: false)

                extra.frame.origin.x -= strongSelf.scrollView.frame.width
                presented.frame.origin.x -= strongSelf.scrollView.frame.width
                following.frame.origin.x -= strongSelf.scrollView.frame.width

                strongSelf.replaceWeekView(presented, withIdentifier: strongSelf.previous, animatable: false)
                strongSelf.replaceWeekView(following, withIdentifier: strongSelf.presented, animatable: false)
            }) { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                
                extra.removeFromSuperview()
                strongSelf.insertWeekView(strongSelf.getFollowingWeek(following), withIdentifier: strongSelf.following)
                strongSelf.updateSelection()
                strongSelf.presentationEnabled = true

                for weekView in strongSelf.weekViews.values {
                    strongSelf.prepareTopMarkersOnWeekView(weekView, hidden: false)
                }
            }
            if let dayViews = following.dayViews,
               let fromDay = dayViews.first,
               let toDay = dayViews.last {
                self.calendarView.delegate?.didShowNextWeekView?(from: fromDay, to: toDay)
            }
        }

    }

    public override func updateDayViews(shouldShow: Bool) {
      setDayOutViewsVisible(monthViews: monthViews, visible: shouldShow)
    }

    fileprivate var togglingBlocked = false
    public override func togglePresentedDate(_ date: Foundation.Date) {
        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current
        
        let presentedDate = CVDate(date: date, calendar: calendar)
        guard let _ = monthViews[presented],
          let presentedWeekView = weekViews[presented] else {
            return
        }
      
        var isMatchedDays = false
        var isMatchedWeeks = false
      
        // selectedDayView would be nil if shouldAutoSelectDayOnMonthChange returns false
        // we want to still allow the user to toggle to a date even if there is nothing selected
        if let selectedDate = calendarView.coordinator.selectedDayView?.date {
          isMatchedDays = matchedDays(selectedDate, presentedDate)
          isMatchedWeeks = matchedWeeks(presentedDate, selectedDate)
        }
      
        if !isMatchedDays && !togglingBlocked {
          if !isMatchedWeeks {
                togglingBlocked = true

                weekViews[previous]?.removeFromSuperview()
                weekViews[following]?.removeFromSuperview()

                let currentMonthView = MonthView(calendarView: calendarView, date: date)
                currentMonthView.updateAppearance(scrollView.bounds)

                monthViews[presented] = currentMonthView
                monthViews[previous] = getPreviousMonth(date)
                monthViews[following] = getFollowingMonth(date)

                let currentDate = CVDate(date: date, calendar: calendar)
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

                UIView.animate(withDuration: toggleDateAnimationDuration, delay: 0,
                                           options: UIView.AnimationOptions(),
                                           animations: {
                    presentedWeekView.alpha = 0
                    currentWeekView.alpha = 1
                }) { [weak self]  _ in
                    presentedWeekView.removeFromSuperview()
                    self?.selectDayViewWithDay(currentDate.day, inWeekView: currentWeekView)
                    self?.togglingBlocked = false
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
                if presentedWeekView.index - 1 >= 0 {
                    return presentedMonthView.weekViews[presentedWeekView.index - 1]
                }

                var expectedWeekIndex = previousMonthView.weekViews.count - 1
                let weekView = previousMonthView.weekViews[expectedWeekIndex]
                //Check if the last week has weekdaysOut, otherwise, take next week to avoid showing duplicates
                if weekView.weekdaysOut != nil {
                  expectedWeekIndex -= 1
                  return previousMonthView.weekViews[expectedWeekIndex]
                }
                return weekView
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
                if presentedMonthView.weekViews.count > presentedWeekView.index + 1 {
                    return presentedMonthView.weekViews[presentedWeekView.index + 1]
                }
                var expectedWeekIndex = 0
                let weekView = followingMonthView.weekViews[expectedWeekIndex]
                //Check if the first week has weekdaysOut, otherwise, take next week to avoid showing duplicates
                if weekView.weekdaysOut != nil {
                  expectedWeekIndex += 1
                  return followingMonthView.weekViews[expectedWeekIndex]
                }
                return weekView
        } else if let followingMonthView = monthViews[following] {
            monthViews[previous] = monthViews[presented]
            monthViews[presented] = monthViews[following]
            monthViews[following] = getFollowingMonth(followingMonthView.date)

            presentedMonthView = monthViews[following]!
        }

        return getFollowingWeek(presentedWeekView)
    }
    
    func checkScrollToPreviousDisabled() {
        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current
        
        guard let presentedWeek = getPresentedWeek(),
            let disableScrollingBeforeDate = calendarView.disableScrollingBeforeDate else {
                return
        }
        
        let convertedDate = CVDate(date: disableScrollingBeforeDate, calendar: calendar)
        presentedWeek.mapDayViews({ dayView in
            if matchedDays(convertedDate, dayView.date) {
                presentedWeek.allowScrollToPreviousWeek = false
            }
        })
    }
    
    func checkScrollToBeyondDisabled() {
        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current
        
        guard let presentedWeek = getPresentedWeek(),
            let disableScrollingBeyondDate = calendarView.disableScrollingBeyondDate else {
                return
        }
        
        let convertedDate = CVDate(date: disableScrollingBeyondDate, calendar: calendar)
        presentedWeek.mapDayViews({ dayView in
            if matchedDays(convertedDate, dayView.date) {
                presentedWeek.allowScrollToNextWeek = false
            }
        })
    }
}

// MARK: - MonthView management

extension CVCalendarWeekContentViewController {
    public func getFollowingMonth(_ date: Foundation.Date) -> MonthView {
        let calendarManager = calendarView.manager
        let firstDate = calendarManager?.monthDateRange(date).monthStartDate
        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current
        var components = Manager.componentsForDate(firstDate!, calendar: calendar)

        components.month! += 1

        let newDate = calendar.date(from: components)!
        let monthView = MonthView(calendarView: calendarView, date: newDate)
        let frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width,
                           height: scrollView.bounds.height)

        monthView.updateAppearance(frame)

        return monthView
    }

    public func getPreviousMonth(_ date: Foundation.Date) -> MonthView {
        let firstDate = calendarView.manager.monthDateRange(date).monthStartDate
        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current
        var components = Manager.componentsForDate(firstDate, calendar: calendar)

        components.month! -= 1

        let newDate = calendar.date(from: components)!
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
        
        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current

        if let presentedWeekView = weekViews[presented],
            let presentedMonthView = monthViews[presented] {
                self.presentedMonthView = presentedMonthView
            calendarView.presentedDate = CVDate(date: presentedMonthView.date, calendar: calendar)

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
                    let current = CVDate(date: Foundation.Date(), calendar: calendar)

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
        
        //restricts scrolling to previous weeks
        if getPresentedWeek()?.allowScrollToPreviousWeek == false,
            scrollView.contentOffset.x < scrollView.frame.width {
            scrollView.setContentOffset(CGPoint(x: scrollView.frame.width, y: 0), animated: false)
            return
        }
        
        //restricts scrolling to next weeks
        if getPresentedWeek()?.allowScrollToNextWeek == false,
            scrollView.contentOffset.x > scrollView.frame.width {
            scrollView.setContentOffset(CGPoint(x: scrollView.frame.width, y: 0), animated: false)
            return
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
            prepareTopMarkersOnWeekView(presented, hidden: self.calendarView.delegate?.shouldHideTopMarkerOnPresentedView?() ?? true)
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
