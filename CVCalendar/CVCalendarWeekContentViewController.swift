//
//  CVCalendarWeekContentViewController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 12/04/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarWeekContentViewController: CVCalendarContentViewController {
    public  var weekViews: [Identifier : WeekView]
    public var monthViews: [Identifier : MonthView]
    
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
        monthViews[Previous] = getPreviousMonth(presentedMonthView.date)
        monthViews[Presented] = presentedMonthView
        monthViews[Following] = getFollowingMonth(presentedMonthView.date)
        
        presentedMonthView.mapDayViews { dayView in
            if self.matchedDays(Date(date: date), dayView.date) {
                self.insertWeekView(dayView.weekView, withIdentifier: self.Presented)
                self.calendarView.coordinator.flush()
                if self.calendarView.shouldAutoSelectDayOnWeekChange{
                    self.calendarView.touchController.receiveTouchOnDayView(dayView)
                    dayView.selectionView?.removeFromSuperview()
                }
            }
        }
        
        if let presented = weekViews[Presented] {
            insertWeekView(getPreviousWeek(presented), withIdentifier: Previous)
            insertWeekView(getFollowingWeek(presented), withIdentifier: Following)
        }
    }
    
    public func reloadWeekViews() {
        for (identifier, weekView) in weekViews {
            weekView.frame.origin = CGPoint(x: CGFloat(indexOfIdentifier(identifier)) * scrollView.frame.width, y: 0)
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
    
    public func replaceWeekView(_ weekView: WeekView, withIdentifier identifier: Identifier, animatable: Bool) {
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
        if let presented = weekViews[Presented], let following = weekViews[Following] {
            if pageLoadingEnabled  {
                pageLoadingEnabled = false
                
                weekViews[Previous]?.removeFromSuperview()
                replaceWeekView(presented, withIdentifier: Previous, animatable: false)
                replaceWeekView(following, withIdentifier: Presented, animatable: true)
                
                insertWeekView(getFollowingWeek(following), withIdentifier: Following)
            }
        }
    }
    
    public func scrolledRight() {
        if let presented = weekViews[Presented], let previous = weekViews[Previous] {
            if pageLoadingEnabled  {
                pageLoadingEnabled = false
                
                weekViews[Following]?.removeFromSuperview()
                replaceWeekView(presented, withIdentifier: Following, animatable: false)
                replaceWeekView(previous, withIdentifier: Presented, animatable: true)
                
                insertWeekView(getPreviousWeek(previous), withIdentifier: Previous)
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
        
        if let presented = weekViews[Presented] {
            scrollView.scrollRectToVisible(presented.frame, animated: false)
        }
    }
    
    public override func performedDayViewSelection(_ dayView: DayView) {
        if dayView.isOut && calendarView.shouldScrollOnOutDayViewSelection {
            if dayView.date.day > 20 {
                let presentedDate = dayView.monthView.date
                calendarView.presentedDate = Date(date: self.dateBeforeDate(presentedDate!))
                presentPreviousView(dayView)
            } else {
                let presentedDate = dayView.monthView.date
                calendarView.presentedDate = Date(date: self.dateAfterDate(presentedDate!))
                presentNextView(dayView)
            }
        }
    }
    
    public override func presentPreviousView(_ view: UIView?) {
        if presentationEnabled {
            presentationEnabled = false
            if let extra = weekViews[Following], let presented = weekViews[Presented], let previous = weekViews[Previous] {
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                    self.prepareTopMarkersOnWeekView(presented, hidden: false)
                    
                    extra.frame.origin.x += self.scrollView.frame.width
                    presented.frame.origin.x += self.scrollView.frame.width
                    previous.frame.origin.x += self.scrollView.frame.width
                    
                    self.replaceWeekView(presented, withIdentifier: self.Following, animatable: false)
                    self.replaceWeekView(previous, withIdentifier: self.Presented, animatable: false)
                }) { _ in
                    extra.removeFromSuperview()
                    self.insertWeekView(self.getPreviousWeek(previous), withIdentifier: self.Previous)
                    self.updateSelection()
                    self.presentationEnabled = true
                    
                    for weekView in self.weekViews.values {
                        self.prepareTopMarkersOnWeekView(weekView, hidden: false)
                    }
                }
            }
        }
    }
    
    public override func presentNextView(_ view: UIView?) {
        if presentationEnabled {
            presentationEnabled = false
            if let extra = weekViews[Previous], let presented = weekViews[Presented], let following = weekViews[Following] {
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                    self.prepareTopMarkersOnWeekView(presented, hidden: false)
                    
                    extra.frame.origin.x -= self.scrollView.frame.width
                    presented.frame.origin.x -= self.scrollView.frame.width
                    following.frame.origin.x -= self.scrollView.frame.width
                    
                    self.replaceWeekView(presented, withIdentifier: self.Previous, animatable: false)
                    self.replaceWeekView(following, withIdentifier: self.Presented, animatable: false)
                }) { _ in
                    extra.removeFromSuperview()
                    self.insertWeekView(self.getFollowingWeek(following), withIdentifier: self.Following)
                    self.updateSelection()
                    self.presentationEnabled = true
                    
                    for weekView in self.weekViews.values {
                        self.prepareTopMarkersOnWeekView(weekView, hidden: false)
                    }
                }
            }
        }

    }
    
    public override func updateDayViews(_ hidden: Bool) {
        setDayOutViewsVisible(hidden)
    }
    
    fileprivate var togglingBlocked = false
    public override func togglePresentedDate(_ date: Foundation.Date) {
        let presentedDate = Date(date: date)
        if let _ = monthViews[Presented], let presentedWeekView = weekViews[Presented], let selectedDate = calendarView.coordinator.selectedDayView?.date {
            if !matchedDays(Date(date: date), selectedDate) && !togglingBlocked {
                if !matchedWeeks(selectedDate, presentedDate) {
                    togglingBlocked = true
                    
                    weekViews[Previous]?.removeFromSuperview()
                    weekViews[Following]?.removeFromSuperview()
                    
                    let currentMonthView = MonthView(calendarView: calendarView, date: date)
                    currentMonthView.updateAppearance(scrollView.bounds)
                    
                    monthViews[Presented] = currentMonthView
                    monthViews[Previous] = getPreviousMonth(date)
                    monthViews[Following] = getFollowingMonth(date)
                    
                    let currentDate = CVDate(date: date)
                    calendarView.presentedDate = currentDate
                    
                    var currentWeekView: WeekView!
                    currentMonthView.mapDayViews { dayView in
                        if self.matchedDays(dayView.date, currentDate) {
                            if let weekView = dayView.weekView {
                                currentWeekView = weekView
                                currentWeekView.alpha = 0
                            }
                        }
                    }
                    
                    insertWeekView(getPreviousWeek(currentWeekView), withIdentifier: Previous)
                    insertWeekView(currentWeekView, withIdentifier: Presented)
                    insertWeekView(getFollowingWeek(currentWeekView), withIdentifier: Following)
                    
                    UIView.animate(withDuration: 0.8, delay: 0, options: UIViewAnimationOptions(), animations: { 
                        presentedWeekView.alpha = 0
                        currentWeekView.alpha = 1
                    }) {  _ in
                        presentedWeekView.removeFromSuperview()
                        self.selectDayViewWithDay(currentDate.day, inWeekView: currentWeekView)
                        self.togglingBlocked = false
                    }
                } else {
                    if let currentWeekView = weekViews[Presented] {
                        selectDayViewWithDay(presentedDate.day, inWeekView: currentWeekView)
                    }
                }
            }
        }
    }
}

// MARK: - WeekView management

extension CVCalendarWeekContentViewController {
    
    public func getPresentedWeek() -> WeekView? {
        guard let currentWeekView = weekViews[Presented] else {
            return nil
        }
        
        return currentWeekView
    }
    
    public func getPreviousWeek(_ presentedWeekView: WeekView) -> WeekView {
        if let presentedMonthView = monthViews[Presented], let previousMonthView = monthViews[Previous] , presentedWeekView.monthView == presentedMonthView {
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
        } else if let previousMonthView = monthViews[Previous] {
            monthViews[Following] = monthViews[Presented]
            monthViews[Presented] = monthViews[Previous]
            monthViews[Previous] = getPreviousMonth(previousMonthView.date)
            
            presentedMonthView = monthViews[Previous]!
        }
        
        return getPreviousWeek(presentedWeekView)
    }
    
    public func getFollowingWeek(_ presentedWeekView: WeekView) -> WeekView {
        if let presentedMonthView = monthViews[Presented], let followingMonthView = monthViews[Following] , presentedWeekView.monthView == presentedMonthView {
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
        } else if let followingMonthView = monthViews[Following] {
            monthViews[Previous] = monthViews[Presented]
            monthViews[Presented] = monthViews[Following]
            monthViews[Following] = getFollowingMonth(followingMonthView.date)
            
            presentedMonthView = monthViews[Following]!
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
        let frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
        
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    public func getPreviousMonth(_ date: Foundation.Date) -> MonthView {
        let firstDate = calendarView.manager.monthDateRange(date).monthStartDate
        var components = Manager.componentsForDate(firstDate)
        
        components.month! -= 1
        
        let newDate = Calendar.current.date(from: components)!
        let monthView = MonthView(calendarView: calendarView, date: newDate)
        let frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
        
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
                    
                    UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                        dayView.alpha = visible ? 0 : 1
                        }) { _ in
                            if visible {
                                dayView.alpha = 1
                                dayView.isHidden = true
                                dayView.isUserInteractionEnabled = false
                            } else {
                                dayView.isUserInteractionEnabled = true
                            }
                    }
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
        
        if let presentedWeekView = weekViews[Presented], let presentedMonthView = monthViews[Presented] {
            self.presentedMonthView = presentedMonthView
            calendarView.presentedDate = Date(date: presentedMonthView.date)
            
            var presentedDate: Date!
            for dayView in presentedWeekView.dayViews {
                if !dayView.isOut {
                    presentedDate = dayView.date
                    break
                }
            }
            
            if let selected = coordinator?.selectedDayView , !matchedWeeks(selected.date, presentedDate) && calendarView.shouldAutoSelectDayOnWeekChange {
                let current = Date(date: Foundation.Date())
                
                if matchedWeeks(presentedDate, current) {
                    selectDayViewWithDay(current.day, inWeekView: presentedWeekView)
                } else {
                    selectDayViewWithDay(presentedDate.day, inWeekView: presentedWeekView)
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
        
        var page = Int(floor((scrollView.contentOffset.x - scrollView.frame.width / 2) / scrollView.frame.width))
        page += 1
        if currentPage != page {
            currentPage = page
        }
        
        lastContentOffset = scrollView.contentOffset.x
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let presented = weekViews[Presented] {
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
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            let rightBorder = scrollView.frame.width
            if scrollView.contentOffset.x <= rightBorder {
                direction = .right
            } else  {
                direction = .left
            }
        }
        
        for weekView in self.weekViews.values {
            self.prepareTopMarkersOnWeekView(weekView, hidden: false)
        }
    }
}
