//
//  CVCalendarMonthContentViewController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 12/04/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

class CVCalendarMonthContentViewController: CVCalendarContentViewController {
    var monthViews: [Identifier : MonthView]
    
    override init(calendarView: CalendarView, frame: CGRect) {
        monthViews = [Identifier : MonthView]()
        super.init(calendarView: calendarView, frame: frame)
        initialLoad(presentedMonthView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Load & Reload
    
    func initialLoad(presentedMonthView: MonthView) {
        let presentedDate = presentedMonthView.date
        
        insertMonthView(getPreviousMonth(presentedDate), withIdentifier: Previous)
        insertMonthView(presentedMonthView, withIdentifier: Presented)
        insertMonthView(getFollowingMonth(presentedDate), withIdentifier: Following)
        
        calendarView.presentedDate = CVDate(date: presentedMonthView.date)
    }
    
    func reloadMonthViews() {
        for (identifier, monthView) in monthViews {
            monthView.frame.origin.x = CGFloat(indexOfIdentifier(identifier)) * scrollView.frame.width
            monthView.removeFromSuperview()
            scrollView.addSubview(monthView)
        }
    }
    
    // MARK: - Month generation
    
    func getFollowingMonth(date: NSDate) -> CVCalendarMonthView {
        let calendarManager = Manager.sharedManager
        let firstDate = calendarManager.monthDateRange(date).monthStartDate
        let components = calendarManager.componentsForDate(firstDate)
        
        components.month += 1
        
        let newDate = NSCalendar.currentCalendar().dateFromComponents(components)!
        let frame = scrollView.bounds
        let monthView = CVCalendarMonthView(calendarView: calendarView, date: newDate)
        
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    func getPreviousMonth(date: NSDate) -> CVCalendarMonthView {
        let calendarManager = Manager.sharedManager
        let firstDate = calendarManager.monthDateRange(date).monthStartDate
        let components = calendarManager.componentsForDate(firstDate)
        
        components.month -= 1
        
        let newDate = NSCalendar.currentCalendar().dateFromComponents(components)!
        let frame = scrollView.bounds
        let monthView = CVCalendarMonthView(calendarView: calendarView, date: newDate)
        
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    // MARk: - Insertion
    
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
            if pageLoadingEnabled && page != 1 {
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
            if pageLoadingEnabled && page != 1 {
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
            monthView.reloadViewsWithRect(rect)
        }
        
        reloadMonthViews()
        
        if let presented = monthViews[Presented] {
            scrollView.scrollRectToVisible(presented.frame, animated: false)
        }
    }
    
    override func performedDayViewSelection(dayView: DayView) {
        if dayView.isOut {
            if dayView.date.day > 20 {
                let presentedDate = dayView.monthView.date
                calendarView.presentedDate = CVDate(date: self.dateBeforeDate(presentedDate))
                presentPreviousView(dayView)
            } else {
                let presentedDate = dayView.monthView.date
                calendarView.presentedDate = CVDate(date: self.dateAfterDate(presentedDate))
                presentNextView(dayView)
            }
        }
    }
    
    override func presentPreviousView(view: UIView?) {
        if let extra = monthViews[Following], let presented = monthViews[Presented], let previous = monthViews[Previous] {
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.prepareTopMarkersOnMonthView(presented, hidden: true)
                
                extra.frame.origin.x += self.scrollView.frame.width
                presented.frame.origin.x += self.scrollView.frame.width
                previous.frame.origin.x += self.scrollView.frame.width
                }) { _ in
                    extra.removeFromSuperview()
                    
                    self.replaceMonthView(presented, withIdentifier: self.Following, animatable: false)
                    self.replaceMonthView(previous, withIdentifier: self.Presented, animatable: false)
                    self.insertMonthView(self.getPreviousMonth(previous.date), withIdentifier: self.Previous)
                    
                    let selectionDay: Int
                    if let selectedDayView = view as? DayView {
                        selectionDay = selectedDayView.date.day
                    } else {
                        selectionDay = 1
                    }
                    
                    self.selectDayViewWithDay(selectionDay, inMonthView: previous)
                    
                    for monthView in self.monthViews.values {
                        self.prepareTopMarkersOnMonthView(monthView, hidden: false)
                    }
            }
        }
    }
    
    override func presentNextView(view: UIView?) {
        if let extra = monthViews[Previous], let presented = monthViews[Presented], let following = monthViews[Following] {
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.prepareTopMarkersOnMonthView(presented, hidden: true)
                
                extra.frame.origin.x -= self.scrollView.frame.width
                presented.frame.origin.x -= self.scrollView.frame.width
                following.frame.origin.x -= self.scrollView.frame.width
                }) { _ in
                    extra.removeFromSuperview()
                    
                    self.replaceMonthView(presented, withIdentifier: self.Previous, animatable: false)
                    self.replaceMonthView(following, withIdentifier: self.Presented, animatable: false)
                    self.insertMonthView(self.getFollowingMonth(following.date), withIdentifier: self.Following)
                    
                    let selectionDay: Int
                    if let selectedDayView = view as? DayView {
                        selectionDay = selectedDayView.date.day
                    } else {
                        selectionDay = 1
                    }
                    
                    self.selectDayViewWithDay(selectionDay, inMonthView: following)
                    
                    for monthView in self.monthViews.values {
                        self.prepareTopMarkersOnMonthView(monthView, hidden: false)
                    }
            }
        }
    }
    
    override func updateDayViews(hidden: Bool) {
        setDayOutViewsVisible(hidden)
    }
    
    private var togglingBlocked = false
    override func togglePresentedDate(date: NSDate) {
        if let presented = monthViews[Presented] {
            if !match(presented.date, date) && !togglingBlocked {
                togglingBlocked = true
                
                monthViews[Previous]?.removeFromSuperview()
                monthViews[Following]?.removeFromSuperview()
                insertMonthView(getPreviousMonth(date), withIdentifier: Previous)
                insertMonthView(getFollowingMonth(date), withIdentifier: Following)
                
                let currentMonthView = MonthView(calendarView: calendarView, date: date)
                currentMonthView.updateAppearance(scrollView.bounds)
                currentMonthView.alpha = 0
                
                insertMonthView(currentMonthView, withIdentifier: Presented)
                
                calendarView.presentedDate = CVDate(date: date)
                
                UIView.animateWithDuration(0.8, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    presented.alpha = 0
                    currentMonthView.alpha = 1
                    }) { _ in
                        presented.removeFromSuperview()
                        
                        if self.match(date, NSDate()) {
                            self.selectDayViewWithDay(Manager.sharedManager.dateRange(NSDate()).day, inMonthView: currentMonthView)
                        } else {
                            self.selectDayViewWithDay(Manager.sharedManager.dateRange(date).day, inMonthView: currentMonthView)
                        }
                        
                        self.togglingBlocked = false
                }
            }
        }
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
        let coordinator = CVCalendarDayViewControlCoordinator.sharedControlCoordinator
        if let selected = coordinator.selectedDayView {
            for (index, monthView) in monthViews {
                if indexOfIdentifier(index) != 1 {
                    monthView.mapDayViews {
                        dayView in
                        
                        if dayView == selected {
                            dayView.setDayLabelDeselectedDismissingState(true)
                            coordinator.dequeueDayView(dayView)
                        }
                    }
                }
            }
        }
        
        if let presentedMonthView = monthViews[Presented] {
            self.presentedMonthView = presentedMonthView
            calendarView.presentedDate = CVDate(date: presentedMonthView.date)
            
            let manager = Manager.sharedManager
            let currentDateRange = manager.dateRange(NSDate())
            let presentedDateRange = manager.dateRange(presentedMonthView.date)
            
            if let selected = coordinator.selectedDayView, let selectedMonthView = selected.monthView where !match(selectedMonthView.date, presentedMonthView.date) {
                if currentDateRange.month == presentedDateRange.month && currentDateRange.year == presentedDateRange.year {
                    selectDayViewWithDay(currentDateRange.day, inMonthView: presentedMonthView)
                } else {
                    selectDayViewWithDay(1, inMonthView: presentedMonthView)
                }
            }
        }
    }
}

// MARK: - UIScrollViewDelegate

extension CVCalendarMonthContentViewController {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let page = Int(floor((scrollView.contentOffset.x - width / 2) / width) + 1)
        if page != self.page {
            self.page = page
        }
        
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0)
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
            case .Left:
                scrolledLeft()
            case .Right:
                scrolledRight()
            default: break
            }
        }
        
        updateSelection()
        
        pageChanged = false
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
            
            pageChanged = true
        }
        
        for monthView in monthViews.values {
            prepareTopMarkersOnMonthView(monthView, hidden: false)
        }
    }
}