//
//  CVCalendarWeekContentViewController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 12/04/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarWeekContentViewController: CVCalendarScrollableContentViewControllerImpl<UIScrollView> {
    private var weekViews: [Identifier : WeekView]
    private var monthViews: [Identifier : MonthView]
    
    private var delegate: CVCalendarViewWeekScrollViewDelegate!
    
    public override init(calendarView: CalendarView, frame: CGRect) {
        weekViews = [Identifier : WeekView]()
        monthViews = [Identifier : MonthView]()
        super.init(calendarView: calendarView, frame: frame)
        initialLoad(NSDate())
        delegateSetup()
    }
    
    public init(calendarView: CalendarView, frame: CGRect, presentedDate: NSDate) {
        weekViews = [Identifier : WeekView]()
        monthViews = [Identifier : MonthView]()
        super.init(calendarView: calendarView, frame: frame)
        presentedMonthView = MonthView(calendarView: calendarView, date: presentedDate)
        presentedMonthView.updateAppearance(bounds)
        initialLoad(presentedDate)
        delegateSetup()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scroll delegate setup 
    
    private func delegateSetup() {
        delegate = CVCalendarViewWeekScrollViewDelegate()
        delegate.controller = self
        contentView.delegate = delegate
    }
    
    // MARK: - Load & Reload
    
    public func initialLoad(date: NSDate) {
        monthViews[.Previous] = getPreviousMonth(presentedMonthView.date)
        monthViews[.Presented] = presentedMonthView
        monthViews[.Following] = getFollowingMonth(presentedMonthView.date)
        
        presentedMonthView.mapDayViews { dayView in
            if self.matchedDays(dayView.date, Date(date: date)) {
                self.insertWeekView(dayView.weekView, withIdentifier: .Presented)
                self.calendarView.coordinator.flush()
                if self.calendarView.shouldAutoSelectDayOnWeekChange{
                    self.calendarView.touchController.receiveTouchOnDayView(dayView)
                    dayView.selectionView?.removeFromSuperview()
                }
            }
        }
        
        if let presented = weekViews[.Presented] {
            insertWeekView(getPreviousWeek(presented), withIdentifier: .Previous)
            insertWeekView(getFollowingWeek(presented), withIdentifier: .Following)
        }
    }
    
    public func reloadWeekViews() {
        for (identifier, weekView) in weekViews {
            weekView.frame.origin = CGPointMake(CGFloat(indexOfIdentifier(identifier)) * contentView.frame.width, 0)
            weekView.removeFromSuperview()
            contentView.addSubview(weekView)
        }
    }
    
    // MARK: - Insertion
    
    public func insertWeekView(weekView: WeekView, withIdentifier identifier: Identifier) {
        let index = CGFloat(indexOfIdentifier(identifier))
        weekView.frame.origin = CGPointMake(contentView.bounds.width * index, 0)
        weekViews[identifier] = weekView
        contentView.addSubview(weekView)
    }
    
    public func replaceWeekView(weekView: WeekView, withIdentifier identifier: Identifier, animatable: Bool) {
        var weekViewFrame = weekView.frame
        weekViewFrame.origin.x = weekViewFrame.width * CGFloat(indexOfIdentifier(identifier))
        weekView.frame = weekViewFrame
        
        weekViews[identifier] = weekView
        
        if animatable {
            contentView.scrollRectToVisible(weekViewFrame, animated: false)
        }
    }
    
    // MARK: - Load management
    
    public func scrolledLeft() {
        if let presented = weekViews[.Presented], let following = weekViews[.Following] {
            if pageLoadingEnabled  {
                pageLoadingEnabled = false
                
                weekViews[.Previous]?.removeFromSuperview()
                replaceWeekView(presented, withIdentifier: .Previous, animatable: false)
                replaceWeekView(following, withIdentifier: .Presented, animatable: true)
                
                insertWeekView(getFollowingWeek(following), withIdentifier: .Following)
            }
        }
    }
    
    public func scrolledRight() {
        if let presented = weekViews[.Presented], let previous = weekViews[.Previous] {
            if pageLoadingEnabled  {
                pageLoadingEnabled = false
                
                weekViews[.Following]?.removeFromSuperview()
                replaceWeekView(presented, withIdentifier: .Following, animatable: false)
                replaceWeekView(previous, withIdentifier: .Presented, animatable: true)
                
                insertWeekView(getPreviousWeek(previous), withIdentifier: .Previous)
            }
        }
    }
    
    // MARK: - Override methods
    
    public func updateFrames(rect: CGRect) {
        super.updateFrames(rect)
        
        for monthView in monthViews.values {
            monthView.reloadViewsWithRect(rect != .zero ? rect : contentView.bounds)
        }
        
        reloadWeekViews()
        
        if let presented = weekViews[.Presented] {
            contentView.scrollRectToVisible(presented.frame, animated: false)
        }
    }
    
    public func performedDayViewSelection(dayView: DayView) {
        if dayView.isOut && calendarView.shouldScrollOnOutDayViewSelection {
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
    
    public func presentPreviousView(view: UIView?) {
        if presentationEnabled {
            presentationEnabled = false
            if let extra = weekViews[.Following], let presented = weekViews[.Presented], let previous = weekViews[.Previous] {
                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.prepareTopMarkersOnWeekView(presented, hidden: false)
                    
                    extra.frame.origin.x += self.contentView.frame.width
                    presented.frame.origin.x += self.contentView.frame.width
                    previous.frame.origin.x += self.contentView.frame.width
                    
                    self.replaceWeekView(presented, withIdentifier: .Following, animatable: false)
                    self.replaceWeekView(previous, withIdentifier: .Presented, animatable: false)
                }) { _ in
                    extra.removeFromSuperview()
                    self.insertWeekView(self.getPreviousWeek(previous), withIdentifier: .Previous)
                    self.updateSelection()
                    self.presentationEnabled = true
                    
                    for weekView in self.weekViews.values {
                        self.prepareTopMarkersOnWeekView(weekView, hidden: false)
                    }
                }
            }
        }
    }
    
    public func presentNextView(view: UIView?) {
        if presentationEnabled {
            presentationEnabled = false
            if let extra = weekViews[.Previous], let presented = weekViews[.Presented], let following = weekViews[.Following] {
                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.prepareTopMarkersOnWeekView(presented, hidden: false)
                    
                    extra.frame.origin.x -= self.contentView.frame.width
                    presented.frame.origin.x -= self.contentView.frame.width
                    following.frame.origin.x -= self.contentView.frame.width
                    
                    self.replaceWeekView(presented, withIdentifier: .Previous, animatable: false)
                    self.replaceWeekView(following, withIdentifier: .Presented, animatable: false)
                }) { _ in
                    extra.removeFromSuperview()
                    self.insertWeekView(self.getFollowingWeek(following), withIdentifier: .Following)
                    self.updateSelection()
                    self.presentationEnabled = true
                    
                    for weekView in self.weekViews.values {
                        self.prepareTopMarkersOnWeekView(weekView, hidden: false)
                    }
                }
            }
        }

    }
    
    public func updateDayViews(hidden: Bool) {
        setDayOutViewsVisible(hidden)
    }
    
    private var togglingBlocked = false
    public func togglePresentedDate(date: NSDate) {
        let presentedDate = Date(date: date)
        if let _ = monthViews[.Presented], let presentedWeekView = weekViews[.Presented], let selectedDate = calendarView.coordinator.selectedDayView?.date {
            if !matchedDays(selectedDate, Date(date: date)) && !togglingBlocked {
                if !matchedWeeks(presentedDate, selectedDate) {
                    togglingBlocked = true
                    
                    weekViews[.Previous]?.removeFromSuperview()
                    weekViews[.Following]?.removeFromSuperview()
                    
                    let currentMonthView = MonthView(calendarView: calendarView, date: date)
                    currentMonthView.updateAppearance(contentView.bounds)
                    
                    monthViews[.Presented] = currentMonthView
                    monthViews[.Previous] = getPreviousMonth(date)
                    monthViews[.Following] = getFollowingMonth(date)
                    
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
                    
                    insertWeekView(getPreviousWeek(currentWeekView), withIdentifier: .Previous)
                    insertWeekView(currentWeekView, withIdentifier: .Presented)
                    insertWeekView(getFollowingWeek(currentWeekView), withIdentifier: .Following)
                    
                    UIView.animateWithDuration(0.8, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { 
                        presentedWeekView.alpha = 0
                        currentWeekView.alpha = 1
                    }) {  _ in
                        presentedWeekView.removeFromSuperview()
                        self.selectDayViewWithDay(currentDate.day, inWeekView: currentWeekView)
                        self.togglingBlocked = false
                    }
                } else {
                    if let currentWeekView = weekViews[.Presented] {
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
        guard let currentWeekView = weekViews[.Presented] else {
            return nil
        }
        
        return currentWeekView
    }
    
    public func getPreviousWeek(presentedWeekView: WeekView) -> WeekView {
        if let presentedMonthView = monthViews[.Presented], let previousMonthView = monthViews[.Previous] where presentedWeekView.monthView == presentedMonthView {
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
        } else if let previousMonthView = monthViews[.Previous] {
            monthViews[.Following] = monthViews[.Presented]
            monthViews[.Presented] = monthViews[.Previous]
            monthViews[.Previous] = getPreviousMonth(previousMonthView.date)
            
            presentedMonthView = monthViews[.Previous]!
        }
        
        return getPreviousWeek(presentedWeekView)
    }
    
    public func getFollowingWeek(presentedWeekView: WeekView) -> WeekView {
        if let presentedMonthView = monthViews[.Presented], let followingMonthView = monthViews[.Following] where presentedWeekView.monthView == presentedMonthView {
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
        } else if let followingMonthView = monthViews[.Following] {
            monthViews[.Previous] = monthViews[.Presented]
            monthViews[.Presented] = monthViews[.Following]
            monthViews[.Following] = getFollowingMonth(followingMonthView.date)
            
            presentedMonthView = monthViews[.Following]!
        }
        
        return getFollowingWeek(presentedWeekView)
    }
}

// MARK: - MonthView management

extension CVCalendarWeekContentViewController {
    public func getFollowingMonth(date: NSDate) -> MonthView {
        let newDate = date.month + 1
        let monthView = MonthView(calendarView: calendarView, date: newDate)
        let frame = CGRectMake(0, 0, contentView.bounds.width, contentView.bounds.height)
        
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    public func getPreviousMonth(date: NSDate) -> MonthView {
        let newDate = date.month - 1
        let monthView = MonthView(calendarView: calendarView, date: newDate)
        let frame = CGRectMake(0, 0, contentView.bounds.width, contentView.bounds.height)
        
        monthView.updateAppearance(frame)
        
        return monthView
    }

}

// MARK: - Visual preparation

extension CVCalendarWeekContentViewController {
    public func prepareTopMarkersOnWeekView(weekView: WeekView, hidden: Bool) {
        weekView.mapDayViews { dayView in
            dayView.topMarker?.hidden = hidden
        }
    }
    
    public func setDayOutViewsVisible(visible: Bool) {
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
    
    public func updateSelection() {
        let coordinator = calendarView.coordinator
        
        if let presentedWeekView = weekViews[.Presented], presentedMonthView = monthViews[.Presented] {
            self.presentedMonthView = presentedMonthView
            
            calendarView.presentedDate = CVDate(date: presentedMonthView.date)
            
            var presentedDate: Date!
            for dayView in presentedWeekView.dayViews {
                if !dayView.isOut {
                    presentedDate = dayView.date
                    break
                }
            }
            
            if let selected = coordinator.selectedDayView {
                guard !matchedWeeks(selected.date, presentedDate) else {
                    return
                }
                
                for (_, monthView) in monthViews {
                    monthView.mapDayViews { dayView in
                        if dayView == selected {
                            dayView.setDeselectedWithClearing(true)
                            coordinator.dequeueDayView(dayView)
                        }
                    }
                }
                
                if !matchedWeeks(selected.date, presentedDate) && calendarView.shouldAutoSelectDayOnWeekChange {
                    let current = Date(date: NSDate())
                    
                    /// Priority: Selected > Current > First
                    if selected.isOut {
                        selectDayViewWithDay(selected.date.day, inWeekView: presentedWeekView)
                    } else if matchedWeeks(current, presentedDate) {
                        selectDayViewWithDay(current.day, inWeekView: presentedWeekView)
                    } else {
                        selectDayViewWithDay(presentedDate.day, inWeekView: presentedWeekView)
                    }
                }
            } else if calendarView.shouldAutoSelectDayOnWeekChange {
                selectDayViewWithDay(presentedDate.day, inWeekView: presentedWeekView)
            }
        }
    }
    
    public func selectDayViewWithDay(day: Int, inWeekView weekView: WeekView) {
        let coordinator = calendarView.coordinator
        weekView.mapDayViews { dayView in
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


@objc internal final class CVCalendarViewWeekScrollViewDelegate: NSObject, UIScrollViewDelegate {
    weak var controller: CVCalendarWeekContentViewController!
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0)
        }
        
        let page = Int(floor((scrollView.contentOffset.x - scrollView.frame.width / 2) / scrollView.frame.width) + 1)
        if controller.currentPage != page {
            controller.currentPage = page
        }
        
        controller.lastContentOffset = scrollView.contentOffset.x
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if let presented = controller.weekViews[.Presented] {
            controller.prepareTopMarkersOnWeekView(presented, hidden: true)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if controller.pageChanged {
            switch controller.direction {
            case .Left:
                controller.scrolledLeft()
            case .Right:
                controller.scrolledRight()
            default: break
            }
        }
        
        controller.updateSelection()
        controller.pageLoadingEnabled = true
        controller.direction = .None
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            let rightBorder = scrollView.frame.width
            if scrollView.contentOffset.x <= rightBorder {
                controller.direction = .Right
            } else  {
                controller.direction = .Left
            }
        }
        
        for weekView in controller.weekViews.values {
            controller.prepareTopMarkersOnWeekView(weekView, hidden: false)
        }
    }
}