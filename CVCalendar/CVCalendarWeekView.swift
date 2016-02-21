//
//  CVCalendarWeekView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarWeekView: UIView {
    // MARK: - Non public properties
    private var interactiveView: UIView!
    
    public override var frame: CGRect {
        didSet {
            if let calendarView = calendarView {
                if calendarView.calendarMode == CalendarMode.WeekView {
                    updateInteractiveView()
                }
            }
        }
    }
    
    private var touchController: CVCalendarTouchController {
        return calendarView.touchController
    }
    
    // MARK: - Public properties
    
    public weak var monthView: CVCalendarMonthView!
    public var dayViews: [CVCalendarDayView]!
    public var index: Int!
    
    public var weekdaysIn: [Int : Int]?
    public var weekdaysOut: [Int : Int]?
    
    public var weekdays: [Weekday : NSDate]!
    
    public var utilizable = false /// Recovery service.
    
    public weak var calendarView: CVCalendarView! {
        var calendarView: CVCalendarView!
        
        if let monthView = monthView, let activeCalendarView = monthView.calendarView {
            calendarView = activeCalendarView
        }
        
        return calendarView
    }
    
    // MARK: - Initialization
    
    public init(monthView: CVCalendarMonthView, index: Int) {
        self.monthView = monthView
        self.index = index
        
        if let size = monthView.calendarView.weekViewSize {
            super.init(frame: CGRectMake(0, CGFloat(index) * size.height, size.width, size.height))
        } else {
            super.init(frame: .zero)
        }
        
        print("[WeekView]: MonthView weekdays \(monthView.weekdays[index].count)")
        
        weekdays = monthView.weekdays[index]
        
        createDayViews()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func mapDayViews(body: (DayView) -> ()) {
        if let dayViews = dayViews {
            for dayView in dayViews {
                body(dayView)
            }
        }
    }
}

// MARK: - Interactive view setup & management

extension CVCalendarWeekView {
    public func updateInteractiveView() {
        safeExecuteBlock({
            
            let mode = self.monthView!.calendarView!.calendarMode!
            if mode == .WeekView {
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
            
            }, collapsingOnNil: false, withObjects: monthView, monthView?.calendarView)
    }
    
    public func didPressInteractiveView(recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.locationInView(self.interactiveView)
        let state: UIGestureRecognizerState = recognizer.state
        
        switch state {
        case .Began:
            touchController.receiveTouchLocation(location, inWeekView: self, withSelectionType: .Range(.Started))
        case .Changed:
            touchController.receiveTouchLocation(location, inWeekView: self, withSelectionType: .Range(.Changed))
        case .Ended:
            touchController.receiveTouchLocation(location, inWeekView: self, withSelectionType: .Range(.Ended))
            
        default: break
        }
    }
    
    public func didTouchInteractiveView(recognizer: UITapGestureRecognizer) {
        let location = recognizer.locationInView(self.interactiveView)
        touchController.receiveTouchLocation(location, inWeekView: self, withSelectionType: .Single)
    }
}

// MARK: - Content fill & reload

extension CVCalendarWeekView {
    public func createDayViews() {
        dayViews = [CVCalendarDayView]()
        var weekday = Weekday(rawValue: calendarView.firstWeekday.rawValue)!
        for i in 1...7 {
            let dayView = CVCalendarDayView(weekView: self, weekdayIndex: i, weekday: weekday)
            dayViews!.append(dayView)
            addSubview(dayView)
            
            weekday = weekday.next()
        }
    }
    
    public func reloadDayViews() {
        
        if let size = calendarView.dayViewSize, let dayViews = dayViews {
//            let hSpace = calendarView.appearance.spaceBetweenDayViews!
            
            for (index, dayView) in dayViews.enumerate() {
                let hSpace = calendarView.appearance.spaceBetweenDayViews!
                let x = CGFloat(index) * CGFloat(size.width + hSpace) + hSpace/2
                dayView.frame = CGRectMake(x, 0, size.width, size.height)
                dayView.reloadContent()
            }
        }
    }
}

// MARK: - Safe execution

extension CVCalendarWeekView {
    public func safeExecuteBlock(block: Void -> Void, collapsingOnNil collapsing: Bool, withObjects objects: AnyObject?...) {
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