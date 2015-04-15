//
//  CVCalendarView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

typealias WeekView = CVCalendarWeekView
typealias CalendarView = CVCalendarView
typealias MonthView = CVCalendarMonthView
typealias Manager = CVCalendarManager
typealias DayView = CVCalendarDayView
typealias ContentController = CVCalendarContentViewController
typealias Appearance = CVCalendarViewAppearance
typealias Coordinator = CVCalendarDayViewControlCoordinator
typealias Date = CVDate
typealias CalendarMode = CVCalendarViewPresentationMode
typealias Weekday = CVCalendarWeekday
typealias Animator = CVCalendarViewAnimator
typealias Delegate = CVCalendarViewDelegate
typealias AppearanceDelegate = CVCalendarViewAppearanceDelegate
typealias AnimatorDelegate = CVCalendarViewAnimatorDelegate
typealias ContentViewController = CVCalendarContentViewController
typealias MonthContentViewController = CVCalendarMonthContentViewController
typealias WeekContentViewController = CVCalendarWeekContentViewController
typealias MenuViewDelegate = CVCalendarMenuViewDelegate
typealias Renderer = CVCalendarRenderer
typealias TouchController = CVCalendarTouchController

class CVCalendarView: UIView {
    // MARK: - Public properties
    var manager: Manager!
    var appearance: Appearance!
    var renderer: Renderer!
    var touchController: TouchController!
    var coordinator: Coordinator!
    var animator: Animator!
    var contentController: ContentViewController!
    var calendarMode: CalendarMode!
    
    var firstWeekday: Weekday {
        get {
            if let delegate = delegate {
                return delegate.firstWeekday()
            } else {
                return .Sunday
            }
        }
    }
    
    var shouldShowWeekdaysOut: Bool! {
        if let delegate = delegate, let shouldShow = delegate.shouldShowWeekdaysOut?() {
            return shouldShow
        } else {
            return false
        }
    }
    
    var presentedDate: Date! {
        didSet {
            if let oldValue = oldValue {
                delegate?.presentedDateUpdated?(presentedDate)
            }
        }
    }
    
    // MARK: - Calendar View Delegate
    
    @IBOutlet weak var calendarDelegate: AnyObject? {
        set {
            if let calendarDelegate = newValue as? Delegate {
                delegate = calendarDelegate
            }
        }
        
        get {
            return delegate
        }
    }
    
    var delegate: CVCalendarViewDelegate? {
        didSet {
            if manager == nil {
                manager = Manager(calendarView: self)
            }
            
            if appearance == nil {
                appearance = Appearance()
            }
            
            if renderer == nil {
                renderer = Renderer(calendarView: self)
            }
            
            if touchController == nil {
                touchController = TouchController(calendarView: self)
            }
            
            if coordinator == nil {
                coordinator = Coordinator(calendarView: self)
            }
            
            if animator == nil {
                animator = Animator(calendarView: self)
            }
            
            if calendarMode == nil {
                loadCalendarMode()
            }
        }
    }
    
    // MARK: - Calendar Appearance Delegate
    
    @IBOutlet weak var calendarAppearanceDelegate: AnyObject? {
        set {
            if let calendarAppearanceDelegate = newValue as? AppearanceDelegate {
                if appearance == nil {
                    appearance = Appearance()
                }
                
                appearance.delegate = calendarAppearanceDelegate
            }
        }
        
        get {
            return appearance
        }
    }
    
    // MARK: - Calendar Animator Delegate
    
    @IBOutlet weak var animatorDelegate: AnyObject? {
        set {
            if let animatorDelegate = newValue as? AnimatorDelegate {
                animator.delegate = animatorDelegate
            }
        }
        
        get {
            return animator
        }
    }
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: CGRectZero)
        hidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        hidden = true
    }

    /// IB Initialization
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        hidden = true
    }
}

// MARK: - Frames update

extension CVCalendarView {
    func commitCalendarViewUpdate() {
        if let delegate = delegate, let contentController = contentController {
            let contentViewSize = contentController.bounds.size
            let selfSize = bounds.size
            
            if selfSize != contentViewSize {
                contentController.updateFrames(bounds)
            } else {
                contentController.updateFrames(CGRectZero)
            }
        }
    }
}

// MARK: - Coordinator callback

extension CVCalendarView {
    func didSelectDayView(dayView: CVCalendarDayView) {
        if let controller = contentController {
            delegate?.didSelectDayView?(dayView)
            controller.performedDayViewSelection(dayView) // TODO: Update to range selection
        }
    }
}

// MARK: - Convenience API

extension CVCalendarView {
    func changeDaysOutShowingState(shouldShow: Bool) {
        contentController.updateDayViews(shouldShow)
    }
    
    func toggleMonthViewWithDate(date: NSDate) {
        contentController.togglePresentedDate(date)
    }
    
    func toggleTodayMonthView() {
        contentController.togglePresentedDate(NSDate())
    }
    
    func loadNextMonthView() {
        contentController.presentNextView(nil)
    }
    
    func loadPreviousMonthView() {
        contentController.presentPreviousView(nil)
    }
}

// MARK: - Mode load 

private extension CVCalendarView {
    func loadCalendarMode() {
        if let delegate = delegate {
            calendarMode = delegate.presentationMode()
            switch delegate.presentationMode() {
                case .MonthView: contentController = MonthContentViewController(calendarView: self, frame: bounds)
                case .WeekView: contentController = WeekContentViewController(calendarView: self, frame: bounds)
                default: break
            }
        }
    }
}
