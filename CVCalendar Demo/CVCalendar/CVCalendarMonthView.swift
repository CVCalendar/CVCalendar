//
//  CVCalendarMonthView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

enum CVSelectionType {
    case Single
    case Range
}

class CVCalendarMonthView: UIView {
    
    // MARK: - Public properties

    var calendarView: CVCalendarView?
    var date: NSDate?
    var numberOfWeeks: Int?
    var weekViews: [CVCalendarWeekView]?
    
    var weeksIn: [[Int : [Int]]]?
    var weeksOut: [[Int : [Int]]]?
    
    var currentDay: Int?
    
    // MARK: - Initialization 

    init(calendarView: CVCalendarView, date: NSDate) {
        super.init()
        
        self.calendarView = calendarView
        self.date = date
        
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        let calendarManager = CVCalendarManager.sharedManager
        self.numberOfWeeks = calendarManager.monthDateRange(self.date!).countOfWeeks
        self.weeksIn = calendarManager.weeksWithWeekdaysForMonthDate(self.date!).weeksIn
        self.weeksOut = calendarManager.weeksWithWeekdaysForMonthDate(self.date!).weeksOut
        
        self.currentDay = calendarManager.dateRange(NSDate()).day
    }
    
    // MARK: - Content filling
    
    func updateAppearance(frame: CGRect) {
        self.frame = frame
        self.createWeekViews()
    }
    
    func createWeekViews() {
        let renderer = CVCalendarRenderer.sharedRenderer()
        self.weekViews = [CVCalendarWeekView]()
        
        for i in 0..<self.numberOfWeeks! {
            let frame = renderer.renderWeekFrameForMonthView(self, weekIndex: i)
            let weekView = CVCalendarWeekView(monthView: self, frame: frame, index: i)
            
            safeExecuteBlock({
                self.weekViews!.append(weekView)
            }, collapsingOnNil: true, withObjects: weekViews)
            
            self.addSubview(weekView)
        }
    }
    
    
    // MARK: - Events receiving
    
    lazy var coordinator: CVCalendarCoordinator = {
        return CVCalendarDayViewControlCoordinator.sharedControlCoordinator
    }()
    
    
    var ranged = false
    func receiveDayViewTouch(dayView: CVCalendarDayView, withSelectionType selectionType: CVSelectionType) {
        switch selectionType {
        case .Single:
            coordinator.performDayViewSingleSelection(dayView)
            calendarView!.didSelectDayView(dayView)
        case .Range:
            if !ranged {
                dayView.setDayLabelHighlighted()
                ranged = true
            } else {
                dayView.setDayLabelUnhighlightedDismissingState(true)
                ranged = false
            }
            
        default: break
        }
    }
    
    // MARK: - View Destruction
    
    func destroy() {
        let coordinator = CVCalendarDayViewControlCoordinator.sharedControlCoordinator
        if self.weekViews != nil {
            for weekView in self.weekViews! {
                for dayView in weekView.dayViews! {
                    if dayView == coordinator.selectedDayView {
                        coordinator.selectedDayView = nil
                    }
                }
                
                weekView.destroy()
            }
            
            self.weekViews = nil
        }
    }
    
    // MARK: Content reload 
    
    func reloadWeekViewsWithMonthFrame(frame: CGRect) {
        self.frame = frame
        
        let renderer = CVCalendarRenderer.sharedRenderer()
        
        safeExecuteBlock({
            for (index, weekView) in enumerate(self.weekViews!) {
                let frame = renderer.renderWeekFrameForMonthView(self, weekIndex: index)
                weekView.frame = frame
                weekView.reloadDayViews()
            }
        }, collapsingOnNil: true, withObjects: weekViews)
    }
    
    // MARK: - Interactive view update
    
    override var frame: CGRect {
        didSet {
            updateInteractiveView()
        }
    }
    
    private var interactiveView: UIView!
    func updateInteractiveView() {
        safeExecuteBlock({
            let mode = self.calendarView!.calendarMode!
            if mode == .MonthView {
                if let interactiveView = self.interactiveView {
                    interactiveView.frame = self.bounds
                    interactiveView.removeFromSuperview()
                    self.addSubview(interactiveView)
                } else {
                    self.interactiveView = UIView(frame: self.bounds)
                    self.interactiveView.backgroundColor = .clearColor()
                    
                    let tapRecognizer = UITapGestureRecognizer(target: self, action: "didTouchInteractiveView:")
                    let pressRecognizer = UILongPressGestureRecognizer(target: self, action: "didPressInteractiveView:")
                    pressRecognizer.minimumPressDuration = 0.3
                    
                    self.interactiveView.addGestureRecognizer(pressRecognizer)
                    self.interactiveView.addGestureRecognizer(tapRecognizer)
                    
                    self.addSubview(self.interactiveView)
                }
            }
            
        }, collapsingOnNil: false, withObjects: calendarView)
    }
    
    // MARK: - Interaction with embedded views
    
    func didPressInteractiveView(recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.locationInView(self.interactiveView)
        let state: UIGestureRecognizerState = recognizer.state
        
        switch state {
            case .Began, .Ended:
                //println("Found TAP gesture, location = \(location)")
            
                if let selectedDayView = locationOwner(location) {
                   receiveDayViewTouch(selectedDayView, withSelectionType: .Range)
                }
            
            /*
            case .Changed:
                println("Changed!")
            case .Ended:
                println("End location: \(location)")
            case .Cancelled:
                println("Canceled!") */
            default: break
        }
    }
    
    func didTouchInteractiveView(recognizer: UITapGestureRecognizer) {
        let location = recognizer.locationInView(self.interactiveView)
        if let selectedDayView = locationOwner(location) {
            receiveDayViewTouch(selectedDayView, withSelectionType: .Single)
        }
    }
    
    func doesBelongToDayView(dayView: DayView, withLocation location: CGPoint) -> Bool {
        var dayViewFrame = dayView.frame
        let weekIndex = dayView.weekView!.index!
        let appearance = dayView.weekView!.monthView!.calendarView!.appearanceDelegate!

        if weekIndex > 0 {
            dayViewFrame.origin.y += dayViewFrame.height
            dayViewFrame.origin.y *= CGFloat(dayView.weekView!.index!)
        }
        
        if dayView != dayView.weekView!.dayViews!.first! {
            dayViewFrame.origin.y += appearance.spaceBetweenWeekViews! * CGFloat(weekIndex)
        }
        
        if location.x >= dayViewFrame.origin.x && location.x <= CGRectGetMaxX(dayViewFrame) && location.y >= dayViewFrame.origin.y && location.y <= CGRectGetMaxY(dayViewFrame) {
            return true
        } else {
            return false
        }
    }
    
    // TODO: Come up with a more efficient algorithm!
    func locationOwner(location: CGPoint) -> DayView? {
        var owner: DayView?
        safeExecuteBlock({
            for weekView in self.weekViews! {
                for dayView in weekView.dayViews! {
                    if self.doesBelongToDayView(dayView, withLocation: location) {
                        owner = dayView
                        return
                    }
                }
            }
        }, collapsingOnNil: true, withObjects: weekViews)

        return owner
    }
}

extension CVCalendarMonthView {
    func safeExecuteBlock(block: Void -> Void, collapsingOnNil collapsing: Bool, withObjects objects: AnyObject?...) {
        for object in objects {
            if object == nil {
                if collapsing {
                    fatalError("Object { \(object) } must not be nil!")
                } else {
                    return
                }
            }
        }
        
        block()
    }
}

