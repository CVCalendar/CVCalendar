//
//  CVCalendarMonthContentViewController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 12/04/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

class CVCalendarMonthContentViewController: CVCalendarContentViewController {
    private var monthViews: [Identifier : MonthView]
    
    override init(calendarView: CalendarView, frame: CGRect) {
        monthViews = [Identifier : MonthView]()
        super.init(calendarView: calendarView, frame: frame)
        initialLoad(presentedMonthView.date)
    }
    
    init(calendarView: CalendarView, frame: CGRect, presentedDate: NSDate) {
        monthViews = [Identifier : MonthView]()
        super.init(calendarView: calendarView, frame: frame)
        presentedMonthView = MonthView(calendarView: calendarView, date: presentedDate)
        presentedMonthView.updateAppearance(scrollView.bounds)
        initialLoad(presentedDate)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Load & Reload
    
    func initialLoad(date: NSDate) {
        insertMonthView(getPreviousMonth(date), withIdentifier: Previous)
        insertMonthView(presentedMonthView, withIdentifier: Presented)
        insertMonthView(getFollowingMonth(date), withIdentifier: Following)
        
        presentedMonthView.mapDayViews { dayView in
            if self.matchedDays(dayView.date, Date(date: date)) {
                self.calendarView.coordinator.flush()
                self.calendarView.touchController.receiveTouchOnDayView(dayView)
                dayView.circleView?.removeFromSuperview()
            }
        }
        
        calendarView.presentedDate = CVDate(date: presentedMonthView.date)
    }
    
    func reloadMonthViews() {
        for (identifier, monthView) in monthViews {
            monthView.frame.origin.x = CGFloat(indexOfIdentifier(identifier)) * scrollView.frame.width
            monthView.removeFromSuperview()
            scrollView.addSubview(monthView)
        }
    }
    
    // MARK: - Insertion
    
    func insertMonthView(monthView: MonthView, withIdentifier identifier: Identifier) {
        let index = CGFloat(indexOfIdentifier(identifier))
        
        monthView.frame.origin = CGPointMake(scrollView.bounds.width * index, 0)
        monthViews[identifier] = monthView
        scrollView.addSubview(monthView)
    }
    
    func replaceMonthView(monthView: MonthView, withIdentifier identifier: Identifier, animatable: Bool) {
        var monthViewFrame = monthView.frame
        monthViewFrame.origin.x = monthViewFrame.width * CGFloat(indexOfIdentifier(identifier))
        monthView.frame = monthViewFrame
        
        monthViews[identifier] = monthView
        
        if animatable {
            scrollView.scrollRectToVisible(monthViewFrame, animated: false)
        }
    }
    
    // MARK: - Load management
    
    func scrolledLeft() {
        if let presented = monthViews[Presented], let following = monthViews[Following] {
            if pageLoadingEnabled  {
                pageLoadingEnabled = false
                
                monthViews[Previous]?.removeFromSuperview()
                replaceMonthView(presented, withIdentifier: Previous, animatable: false)
                replaceMonthView(following, withIdentifier: Presented, animatable: true)
                
                insertMonthView(getFollowingMonth(following.date), withIdentifier: Following)
            }
            
        }
    }
    
    func scrolledRight() {
        if let previous = monthViews[Previous], let presented = monthViews[Presented] {
            if pageLoadingEnabled  {
                pageLoadingEnabled = false
                
                monthViews[Following]?.removeFromSuperview()
                replaceMonthView(previous, withIdentifier: Presented, animatable: true)
                replaceMonthView(presented, withIdentifier: Following, animatable: false)
                
                insertMonthView(getPreviousMonth(previous.date), withIdentifier: Previous)
            }
        }
    }
    
    // MARK: - Override methods
    
    override func updateFrames(rect: CGRect) {
        super.updateFrames(rect)
        
        for monthView in monthViews.values {
            monthView.reloadViewsWithRect(rect != CGRectZero ? rect : scrollView.bounds)
        }
        
        reloadMonthViews()

        if let presented = monthViews[Presented] {
            if scrollView.frame.height != presented.potentialSize.height {
                updateHeight(presented.potentialSize.height, animated: false)
            }
            
            scrollView.scrollRectToVisible(presented.frame, animated: false)
        }
    }
    
    override func performedDayViewSelection(dayView: DayView) {
        if dayView.isOut {
            if dayView.date.day > 20 {
                let presentedDate = dayView.monthView.date
                calendarView.presentedDate = Date(date: self.dateBeforeDate(presentedDate))
                presentPreviousView(dayView)
            } else {
                let presentedDate = dayView.monthView.date
                calendarView.presentedDate = Date(date: self.dateAfterDate(presentedDate))
                presentNextView(dayView)
            }
        }
    }
    
    override func presentPreviousView(view: UIView?) {
        if presentationEnabled {
            presentationEnabled = false
            if let extra = monthViews[Following], let presented = monthViews[Presented], let previous = monthViews[Previous] {
                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.prepareTopMarkersOnMonthView(presented, hidden: true)
                    
                    extra.frame.origin.x += self.scrollView.frame.width
                    presented.frame.origin.x += self.scrollView.frame.width
                    previous.frame.origin.x += self.scrollView.frame.width
                    
                    self.replaceMonthView(presented, withIdentifier: self.Following, animatable: false)
                    self.replaceMonthView(previous, withIdentifier: self.Presented, animatable: false)
                    self.presentedMonthView = previous
                    
                    self.updateLayoutIfNeeded()
                }) { _ in
                    extra.removeFromSuperview()
                    self.insertMonthView(self.getPreviousMonth(previous.date), withIdentifier: self.Previous)
                    self.updateSelection()
                    self.presentationEnabled = true
                    
                    for monthView in self.monthViews.values {
                        self.prepareTopMarkersOnMonthView(monthView, hidden: false)
                    }
                }
            }
        }
    }
    
    override func presentNextView(view: UIView?) {
        if presentationEnabled {
            presentationEnabled = false
            if let extra = monthViews[Previous], let presented = monthViews[Presented], let following = monthViews[Following] {
                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.prepareTopMarkersOnMonthView(presented, hidden: true)
                    
                    extra.frame.origin.x -= self.scrollView.frame.width
                    presented.frame.origin.x -= self.scrollView.frame.width
                    following.frame.origin.x -= self.scrollView.frame.width
                    
                    self.replaceMonthView(presented, withIdentifier: self.Previous, animatable: false)
                    self.replaceMonthView(following, withIdentifier: self.Presented, animatable: false)
                    self.presentedMonthView = following
                    
                    self.updateLayoutIfNeeded()
                }) { _ in
                    extra.removeFromSuperview()
                    self.insertMonthView(self.getFollowingMonth(following.date), withIdentifier: self.Following)
                    self.updateSelection()
                    self.presentationEnabled = true
                    
                    for monthView in self.monthViews.values {
                        self.prepareTopMarkersOnMonthView(monthView, hidden: false)
                    }
                }
            }
        }
    }
    
    override func updateDayViews(hidden: Bool) {
        setDayOutViewsVisible(hidden)
    }
    
    private var togglingBlocked = false
    override func togglePresentedDate(date: NSDate) {
        let presentedDate = Date(date: date)
        if let presented = monthViews[Presented], let selectedDate = calendarView.coordinator.selectedDayView?.date {
            if !matchedDays(selectedDate, presentedDate) && !togglingBlocked {
                if !matchedMonths(presentedDate, selectedDate) {
                    togglingBlocked = true
                    
                    monthViews[Previous]?.removeFromSuperview()
                    monthViews[Following]?.removeFromSuperview()
                    insertMonthView(getPreviousMonth(date), withIdentifier: Previous)
                    insertMonthView(getFollowingMonth(date), withIdentifier: Following)
                    
                    let currentMonthView = MonthView(calendarView: calendarView, date: date)
                    currentMonthView.updateAppearance(scrollView.bounds)
                    currentMonthView.alpha = 0
                    
                    insertMonthView(currentMonthView, withIdentifier: Presented)
                    presentedMonthView = currentMonthView
                    
                    calendarView.presentedDate = Date(date: date)
                    
                    UIView.animateWithDuration(0.8, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        presented.alpha = 0
                        currentMonthView.alpha = 1
                    }) { _ in
                        presented.removeFromSuperview()
                        self.selectDayViewWithDay(presentedDate.day, inMonthView: currentMonthView)
                        self.togglingBlocked = false
                        self.updateLayoutIfNeeded()
                    }
                } else {
                    if let currentMonthView = monthViews[Presented] {
                        selectDayViewWithDay(presentedDate.day, inMonthView: currentMonthView)
                    }
                }
            }
        }
    }
}

// MARK: - Month management

extension CVCalendarMonthContentViewController {
    func getFollowingMonth(date: NSDate) -> MonthView {
        let firstDate = calendarView.manager.monthDateRange(date).monthStartDate
        let components = Manager.componentsForDate(firstDate)
        
        components.month += 1
        
        let newDate = NSCalendar.currentCalendar().dateFromComponents(components)!
        let frame = scrollView.bounds
        let monthView = MonthView(calendarView: calendarView, date: newDate)
        
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    func getPreviousMonth(date: NSDate) -> MonthView {
        let firstDate = calendarView.manager.monthDateRange(date).monthStartDate
        let components = Manager.componentsForDate(firstDate)
        
        components.month -= 1
        
        let newDate = NSCalendar.currentCalendar().dateFromComponents(components)!
        let frame = scrollView.bounds
        let monthView = MonthView(calendarView: calendarView, date: newDate)
        
        monthView.updateAppearance(frame)
        
        return monthView
    }
}

// MARK: - Visual preparation

extension CVCalendarMonthContentViewController {
    func prepareTopMarkersOnMonthView(monthView: MonthView, hidden: Bool) {
        monthView.mapDayViews { dayView in
            dayView.topMarker?.hidden = hidden
        }
    }
    
    func setDayOutViewsVisible(visible: Bool) {
        for monthView in monthViews.values {
            monthView.mapDayViews { dayView in
                if dayView.isOut {
                    if !visible {
                        dayView.alpha = 0
                        dayView.hidden = false
                    }
                    
                    UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        dayView.alpha = visible ? 0 : 1
                        }) { _ in
                            if visible {
                                dayView.alpha = 1
                                dayView.hidden = true
                                dayView.userInteractionEnabled = false
                            } else {
                                dayView.userInteractionEnabled = true
                            }
                    }
                }
            }
        }
    }
    
    func updateSelection() {
        let coordinator = calendarView.coordinator
        if let selected = coordinator.selectedDayView {
            for (index, monthView) in monthViews {
                if indexOfIdentifier(index) != 1 {
                    monthView.mapDayViews {
                        dayView in
                        
                        if dayView == selected {
                            dayView.setDeselectedWithClearing(true)
                            coordinator.dequeueDayView(dayView)
                        }
                    }
                }
            }
        }
        
        if let presentedMonthView = monthViews[Presented] {
            self.presentedMonthView = presentedMonthView
            calendarView.presentedDate = Date(date: presentedMonthView.date)
            
            if let selected = coordinator.selectedDayView, let selectedMonthView = selected.monthView where !matchedMonths(Date(date: selectedMonthView.date), Date(date: presentedMonthView.date)) {
                let current = Date(date: NSDate())
                let presented = Date(date: presentedMonthView.date)
                
                if matchedMonths(current, presented) {
                    selectDayViewWithDay(current.day, inMonthView: presentedMonthView)
                } else {
                    selectDayViewWithDay(Date(date: calendarView.manager.monthDateRange(presentedMonthView.date).monthStartDate).day, inMonthView: presentedMonthView)
                }
            }
        }
        
    }
    
    func selectDayViewWithDay(day: Int, inMonthView monthView: CVCalendarMonthView) {
        let coordinator = calendarView.coordinator
        monthView.mapDayViews { dayView in
            if dayView.date.day == day && !dayView.isOut {
                if let selected = coordinator.selectedDayView where selected != dayView {
                    self.calendarView.didSelectDayView(dayView)
                }
                
                coordinator.performDayViewSingleSelection(dayView)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate

extension CVCalendarMonthContentViewController {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0)
        }
        
        let page = Int(floor((scrollView.contentOffset.x - scrollView.frame.width / 2) / scrollView.frame.width) + 1)
        if currentPage != page {
            currentPage = page
        }
        
        lastContentOffset = scrollView.contentOffset.x
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if let presented = monthViews[Presented] {
            prepareTopMarkersOnMonthView(presented, hidden: true)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if pageChanged {
            switch direction {
            case .Left: scrolledLeft()
            case .Right: scrolledRight()
            default: break
            }
        }
        
        updateSelection()
        updateLayoutIfNeeded()
        pageLoadingEnabled = true
        direction = .None
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            let rightBorder = scrollView.frame.width
            if scrollView.contentOffset.x <= rightBorder {
                direction = .Right
            } else  {
                direction = .Left
            }
        }
        
        for monthView in monthViews.values {
            prepareTopMarkersOnMonthView(monthView, hidden: false)
        }
    }
}