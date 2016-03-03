//
//  CVCalendarMonthContentViewController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 12/04/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarMonthContentViewController: CVCalendarScrollableContentViewControllerImpl<UIScrollView> {
    private var monthViews: [Identifier : MonthView]
    
    private var delegate: CVCalendarViewMonthScrollViewDelegate!

    public override init(calendarView: CalendarView, frame: CGRect) {
        monthViews = [Identifier : MonthView]()
        super.init(calendarView: calendarView, frame: frame)
        initialLoad(presentedMonthView.date)
        delegateSetup()
    }
    
    public init(calendarView: CalendarView, frame: CGRect, presentedDate: NSDate) {
        monthViews = [Identifier : MonthView]()
        super.init(calendarView: calendarView, frame: frame)
        presentedMonthView = MonthView(calendarView: calendarView, date: presentedDate)
        presentedMonthView.updateAppearance(contentView.bounds)
        initialLoad(presentedDate)
        delegateSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scroll delegate setup
    
    private func delegateSetup() {
        delegate = CVCalendarViewMonthScrollViewDelegate()
        delegate.controller = self
        contentView.delegate = delegate
    }
    
    // MARK: - Load & Reload
    
    public func initialLoad(date: NSDate) {
        insertMonthView(getPreviousMonth(date), withIdentifier: .Previous)
        insertMonthView(presentedMonthView, withIdentifier: .Presented)
        insertMonthView(getFollowingMonth(date), withIdentifier: .Following)
        
        presentedMonthView.mapDayViews { dayView in
            if self.calendarView.shouldAutoSelectDayOnMonthChange && self.matchedDays(dayView.date, Date(date: date)) {
                self.calendarView.coordinator.flush()
                self.calendarView.touchController.receiveTouchOnDayView(dayView)
                dayView.selectionView?.removeFromSuperview()
            }
        }
        
        calendarView.presentedDate = CVDate(date: presentedMonthView.date)
        
        print("Scroll View Delegate: \(contentView.delegate)")
    }
    
    public func reloadMonthViews() {
        for (identifier, monthView) in monthViews {
            monthView.frame.origin.x = CGFloat(indexOfIdentifier(identifier)) * contentView.frame.width
            monthView.removeFromSuperview()
            contentView.addSubview(monthView)
        }
    }
    
    // MARK: - Insertion
    
    public func insertMonthView(monthView: MonthView, withIdentifier identifier: Identifier) {
        let index = CGFloat(indexOfIdentifier(identifier))
        
        monthView.frame.origin = CGPointMake(contentView.bounds.width * index, 0)
        monthViews[identifier] = monthView
        contentView.addSubview(monthView)
    }
    
    public func replaceMonthView(monthView: MonthView, withIdentifier identifier: Identifier, animatable: Bool) {
        var monthViewFrame = monthView.frame
        monthViewFrame.origin.x = monthViewFrame.width * CGFloat(indexOfIdentifier(identifier))
        monthView.frame = monthViewFrame
        
        monthViews[identifier] = monthView
        
        if animatable {
            contentView.scrollRectToVisible(monthViewFrame, animated: false)
        }
    }
    
    // MARK: - Load management
    
    public func scrolledLeft() {
        if let presented = monthViews[.Presented], let following = monthViews[.Following] {
            if pageLoadingEnabled  {
                pageLoadingEnabled = false
                
                monthViews[.Previous]?.removeFromSuperview()
                replaceMonthView(presented, withIdentifier: .Previous, animatable: false)
                replaceMonthView(following, withIdentifier: .Presented, animatable: true)
                
                insertMonthView(getFollowingMonth(following.date), withIdentifier: .Following)
                self.calendarView.delegate?.didShowNextMonthView?(following.date)
            }
            
        }
    }
    
    public func scrolledRight() {
        if let previous = monthViews[.Previous], let presented = monthViews[.Presented] {
            if pageLoadingEnabled  {
                pageLoadingEnabled = false
                
                monthViews[.Following]?.removeFromSuperview()
                replaceMonthView(previous, withIdentifier: .Presented, animatable: true)
                replaceMonthView(presented, withIdentifier: .Following, animatable: false)
                
                insertMonthView(getPreviousMonth(previous.date), withIdentifier: .Previous)
                self.calendarView.delegate?.didShowPreviousMonthView?(previous.date)
            }
        }
    }
    
    // MARK: - Override methods
    
    public func updateFrames(rect: CGRect) {
        super.updateFrames(rect)
        print("Updating frames on MonthContentVC")
        for monthView in monthViews.values {
            monthView.reloadViewsWithRect(rect != .zero ? rect : contentView.bounds)
        }
        
        reloadMonthViews()

        if let presented = monthViews[.Presented] {
            if contentView.frame.height != presented.potentialSize.height {
                updateHeight(presented.potentialSize.height, animated: false)
            }
            
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
            if let extra = monthViews[.Following], let presented = monthViews[.Presented], let previous = monthViews[.Previous] {
                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.prepareTopMarkersOnMonthView(presented, hidden: true)
                    
                    extra.frame.origin.x += self.contentView.frame.width
                    presented.frame.origin.x += self.contentView.frame.width
                    previous.frame.origin.x += self.contentView.frame.width
                    
                    self.replaceMonthView(presented, withIdentifier: .Following, animatable: false)
                    self.replaceMonthView(previous, withIdentifier: .Presented, animatable: false)
                    self.presentedMonthView = previous
                    
                    self.updateLayoutIfNeeded()
                }) { _ in
                    extra.removeFromSuperview()
                    self.insertMonthView(self.getPreviousMonth(previous.date), withIdentifier: .Previous)
                    self.updateSelection()
                    self.presentationEnabled = true
                    
                    for monthView in self.monthViews.values {
                        self.prepareTopMarkersOnMonthView(monthView, hidden: false)
                    }
                }
            }
        }
    }
    
    public func presentNextView(view: UIView?) {
        if presentationEnabled {
            presentationEnabled = false
            if let extra = monthViews[.Previous], let presented = monthViews[.Presented], let following = monthViews[.Following] {
                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.prepareTopMarkersOnMonthView(presented, hidden: true)
                    
                    extra.frame.origin.x -= self.contentView.frame.width
                    presented.frame.origin.x -= self.contentView.frame.width
                    following.frame.origin.x -= self.contentView.frame.width
                    
                    self.replaceMonthView(presented, withIdentifier: .Previous, animatable: false)
                    self.replaceMonthView(following, withIdentifier: .Presented, animatable: false)
                    self.presentedMonthView = following
                    
                    self.updateLayoutIfNeeded()
                }) { _ in
                    extra.removeFromSuperview()
                    self.insertMonthView(self.getFollowingMonth(following.date), withIdentifier: .Following)
                    self.updateSelection()
                    self.presentationEnabled = true
                    
                    for monthView in self.monthViews.values {
                        self.prepareTopMarkersOnMonthView(monthView, hidden: false)
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
        if let presented = monthViews[.Presented], let selectedDate = calendarView.coordinator.selectedDayView?.date {
            if !matchedDays(selectedDate, presentedDate) && !togglingBlocked {
                if !matchedMonths(presentedDate, selectedDate) {
                    togglingBlocked = true
                    
                    monthViews[.Previous]?.removeFromSuperview()
                    monthViews[.Following]?.removeFromSuperview()
                    insertMonthView(getPreviousMonth(date), withIdentifier: .Previous)
                    insertMonthView(getFollowingMonth(date), withIdentifier: .Following)
                    
                    let currentMonthView = MonthView(calendarView: calendarView, date: date)
                    currentMonthView.updateAppearance(contentView.bounds)
                    currentMonthView.alpha = 0
                    
                    insertMonthView(currentMonthView, withIdentifier: .Presented)
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
                    if let currentMonthView = monthViews[.Presented] {
                        selectDayViewWithDay(presentedDate.day, inMonthView: currentMonthView)
                    }
                }
            }
        }
    }
}

// MARK: - Month management

extension CVCalendarMonthContentViewController {
    public func getFollowingMonth(date: NSDate) -> MonthView {
        let newDate = (date.day == 1).month + 1
        let frame = contentView.bounds
        let monthView = MonthView(calendarView: calendarView, date: newDate)
        
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    public func getPreviousMonth(date: NSDate) -> MonthView {
        let newDate = (date.day == 1).month - 1
        let frame = contentView.bounds
        let monthView = MonthView(calendarView: calendarView, date: newDate)
        
        monthView.updateAppearance(frame)
        
        return monthView
    }
}

// MARK: - Visual preparation

extension CVCalendarMonthContentViewController {
    public func prepareTopMarkersOnMonthView(monthView: MonthView, hidden: Bool) {
        monthView.mapDayViews { dayView in
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
        
        if let presentedMonthView = monthViews[.Presented] {
            self.presentedMonthView = presentedMonthView
            let _presentedDate = Date(date: presentedMonthView.date)
            
            if let selected = coordinator.selectedDayView, selectedMonthView = selected.monthView {
                guard !matchedMonths(selected.date, _presentedDate) || (matchedMonths(selected.date, _presentedDate) && selected.isOut)  else {
                    return
                }
                
                // Clear...
                for (_, monthView) in monthViews {
                    monthView.mapDayViews {
                        dayView in
                        
                        if dayView == selected {
                            dayView.setDeselectedWithClearing(true)
                            coordinator.dequeueDayView(dayView)
                        }
                    }
                }
                
                if !matchedMonths(Date(date: selectedMonthView.date), Date(date: presentedMonthView.date)) && calendarView.shouldAutoSelectDayOnMonthChange {
                    let current = Date(date: NSDate())
                    let presented = Date(date: presentedMonthView.date)
                    
                    /// Priority: Selected > Current > First
                    if selected.isOut {
                        selectDayViewWithDay(selected.date.day, inMonthView: presentedMonthView)
                    } else if matchedMonths(current, presented) {
                        selectDayViewWithDay(current.day, inMonthView: presentedMonthView)
                    } else {
                        selectDayViewWithDay(presentedMonthView.date.firstMonthDate().day.value(), inMonthView: presentedMonthView)
                    }
                }
            } else {
                selectDayViewWithDay(presentedMonthView.date.firstMonthDate().day.value(), inMonthView: presentedMonthView)
            }
            
            calendarView.presentedDate = _presentedDate
        }
    }
    
    public func selectDayViewWithDay(day: Int, inMonthView monthView: CVCalendarMonthView) {
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
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        print("Scroll From Month")
        
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0)
        }
        
        let page = Int(floor((scrollView.contentOffset.x - scrollView.frame.width / 2) / scrollView.frame.width) + 1)
        if currentPage != page {
            currentPage = page
        }
        
        lastContentOffset = scrollView.contentOffset.x
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if let presented = monthViews[.Presented] {
            prepareTopMarkersOnMonthView(presented, hidden: true)
        }
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
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
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
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


@objc internal final class CVCalendarViewMonthScrollViewDelegate: NSObject, UIScrollViewDelegate {
        weak var controller: CVCalendarMonthContentViewController!
    
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
            if let presented = controller.monthViews[.Presented] {
                controller.prepareTopMarkersOnMonthView(presented, hidden: true)
            }
        }
    
        func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
            if controller.pageChanged {
                switch controller.direction {
                case .Left: controller.scrolledLeft()
                case .Right: controller.scrolledRight()
                default: break
                }
            }
    
            controller.updateSelection()
            controller.updateLayoutIfNeeded()
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
            
            for monthView in controller.monthViews.values {
                controller.prepareTopMarkersOnMonthView(monthView, hidden: false)
            }
        }
}