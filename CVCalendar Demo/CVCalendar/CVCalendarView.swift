//
//  CVCalendarView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

enum CVCalendarViewMode {
    case MonthView
    case WeekView
}

typealias WeekView = CVCalendarWeekView
typealias CalendarView = CVCalendarView
typealias MonthView = CVCalendarMonthView
typealias Manager = CVCalendarManager
typealias Recovery = CVCalendarWeekContentRecovery
typealias WeekContentView = CVCalendarWeekContentView
typealias DayView = CVCalendarDayView
typealias ContentController = CVCalendarContentViewController
typealias Appearance = CVCalendarViewAppearance
typealias Coordinator = CVCalendarDayViewControlCoordinator
typealias Date = CVDate
typealias CalendarMode = CVCalendarViewMode
typealias Animator = CVCalendarViewAnimator
typealias Delegate = CVCalendarViewDelegate
typealias AppearanceDelegate = CVCalendarViewAppearanceDelegate
typealias AnimatorDelegate = CVCalendarViewAnimatorDelegate
typealias MonthContentView = CVCalendarMonthContentView
typealias ContentDelegate = CVCalendarContentDelegate

class CVCalendarView: UIView {
    // MARK: - Public properties
    var contentController: CVCalendarContentViewController!
    var calendarMode: CalendarMode! = .MonthView
    
    var shouldShowWeekdaysOut: Bool! {
        if let delegate = delegate {
            return delegate.shouldShowWeekdaysOut()
        } else {
            return false
        }
    }
    
    var presentedDate: Date! {
        didSet {
            delegate?.presentedDateUpdated(presentedDate)
        }
    }
    
    var animator: Animator {
        return Animator.sharedAnimator
    }
    
    // MARK: - Calendar View Delegate
    
    @IBOutlet var calendarDelegate: AnyObject? {
        set {
            if let calendarDelegate = newValue as? Delegate {
                delegate = calendarDelegate
            }
        }
        
        get {
            return delegate
        }
    }
    
    var delegate: CVCalendarViewDelegate?
    
    // MARK: - Calendar Appearance Delegate
    
    @IBOutlet var calendarAppearanceDelegate: AnyObject? {
        set {
            if let calendarAppearanceDelegate = newValue as? AppearanceDelegate {
                appearance.delegate = calendarAppearanceDelegate
            }
        }
        
        get {
            return appearance
        }
    }
    
    var appearance = Appearance.sharedCalendarViewAppearance
    
    // MARK: - Calendar Animator Delegate
    
    @IBOutlet var animatorDelegate: AnyObject? {
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
        loadCalendarMode()
        contentController = CVCalendarContentViewController(calendarView: self, frame: bounds)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        hidden = true
        loadCalendarMode()
        contentController = CVCalendarContentViewController(calendarView: self, frame: bounds)
    }

    /// IB Initialization
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        hidden = true
        loadCalendarMode()
        contentController = CVCalendarContentViewController(calendarView: self, frame: bounds)
    }
}

// MARK: - Frames update

extension CVCalendarView {
    func commitCalendarViewUpdate() {
        if let contentController = contentController {
            let contentViewSize = contentController.bounds.size
            let selfSize = bounds.size
            
            if selfSize != contentViewSize {
                contentController.updateFrames(bounds)
            }
        }
        
    }
}

// MARK: - Coordinator callback

extension CVCalendarView {
    func didSelectDayView(dayView: CVCalendarDayView) {
        delegate?.didSelectDayView(dayView)
        if let controller = contentController {
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
        let calendarModeKey = "CVCalendarViewMode"
        let calendarMode = NSBundle.mainBundle().objectForInfoDictionaryKey(calendarModeKey) as? String
        
        if let calendarMode = calendarMode {
            switch calendarMode {
                case "MonthView": self.calendarMode = .MonthView
                case "WeekView": self.calendarMode = .WeekView
            default: break
            }
        }
    }
}
