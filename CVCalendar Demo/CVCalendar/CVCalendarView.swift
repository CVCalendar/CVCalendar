//
//  CVCalendarView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

public typealias WeekView = CVCalendarWeekView
public typealias CalendarView = CVCalendarView
public typealias MonthView = CVCalendarMonthView
public typealias Manager = CVCalendarManager
public typealias DayView = CVCalendarDayView
public typealias ContentController = CVCalendarContentViewController
public typealias Appearance = CVCalendarViewAppearance
public typealias Coordinator = CVCalendarDayViewControlCoordinator
public typealias Date = CVDate
public typealias CalendarMode = CVCalendarViewPresentationMode
public typealias Weekday = CVCalendarWeekday
public typealias Animator = CVCalendarViewAnimator
public typealias Delegate = CVCalendarViewDelegate
public typealias AppearanceDelegate = CVCalendarViewAppearanceDelegate
public typealias AnimatorDelegate = CVCalendarViewAnimatorDelegate
public typealias ContentViewController = CVCalendarContentViewController
public typealias MonthContentViewController = CVCalendarMonthContentViewController
public typealias WeekContentViewController = CVCalendarWeekContentViewController
public typealias MenuViewDelegate = CVCalendarMenuViewDelegate
public typealias TouchController = CVCalendarTouchController
public typealias SelectionType = CVSelectionType

public final class CVCalendarView: UIView {
    // MARK: - Public properties
    public var manager: Manager!
    public var appearance: Appearance!
    public var touchController: TouchController!
    public var coordinator: Coordinator!
    public var animator: Animator!
    public var contentController: ContentViewController!
    public var calendarMode: CalendarMode!
    
    public var (weekViewSize, dayViewSize): (CGSize?, CGSize?)
    
    private var validated = false
    
    public var firstWeekday: Weekday {
        get {
            if let delegate = delegate {
                return delegate.firstWeekday()
            } else {
                return .Sunday
            }
        }
    }
    
    public var shouldShowWeekdaysOut: Bool! {
        if let delegate = delegate, let shouldShow = delegate.shouldShowWeekdaysOut?() {
            return shouldShow
        } else {
            return false
        }
    }
    
    public var presentedDate: Date! {
        didSet {
            if let _ = oldValue {
                delegate?.presentedDateUpdated?(presentedDate)
            }
        }
    }
    
    public var shouldAnimateResizing: Bool {
        get {
            if let delegate = delegate, should = delegate.shouldAnimateResizing?() {
                return should
            }
            
            return true
        }
    }
    
    public var shouldAutoSelectDayOnMonthChange: Bool{
        get {
            if let delegate = delegate, should = delegate.shouldAutoSelectDayOnMonthChange?() {
                return should
            }
            return true
        }
    }
    
    public var shouldAutoSelectDayOnWeekChange: Bool{
        get {
            if let delegate = delegate, should = delegate.shouldAutoSelectDayOnWeekChange?() {
                return should
            }
            return true
        }
    }
    
    public var shouldScrollOnOutDayViewSelection: Bool{
        get {
            if let delegate = delegate, should = delegate.shouldScrollOnOutDayViewSelection?() {
                return should
            }
            return true
        }
    }
    
    // MARK: - Calendar View Delegate
    
    @IBOutlet public weak var calendarDelegate: AnyObject? {
        set {
            if let calendarDelegate = newValue as? Delegate {
                delegate = calendarDelegate
            }
        }
        
        get {
            return delegate
        }
    }
    
    public weak var delegate: CVCalendarViewDelegate? {
        didSet {
            if manager == nil {
                manager = Manager(calendarView: self)
            }
            
            if appearance == nil {
                appearance = Appearance()
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
    
    @IBOutlet public weak var calendarAppearanceDelegate: AnyObject? {
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
    
    @IBOutlet public weak var animatorDelegate: AnyObject? {
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
    
    public init() {
        super.init(frame: CGRectZero)
        hidden = true
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        hidden = true
    }

    /// IB Initialization
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        hidden = true
    }
}

// MARK: - Frames update

extension CVCalendarView {
    public func commitCalendarViewUpdate() {
        if let _ = delegate, let contentController = contentController {
            let contentViewSize = contentController.bounds.size
            let selfSize = bounds.size
            let screenSize = UIScreen.mainScreen().bounds.size
            
            let allowed = selfSize.width <= screenSize.width && selfSize.height <= screenSize.height
            
            if !validated && allowed {
                let width = selfSize.width
                let height: CGFloat
                let countOfWeeks = CGFloat(6)
                
                let vSpace = appearance.spaceBetweenWeekViews!
                let hSpace = appearance.spaceBetweenDayViews!
                
                if let mode = calendarMode {
                    switch mode {
                    case .WeekView:
                        height = selfSize.height
                    case .MonthView :
                        height = (selfSize.height / countOfWeeks) - (vSpace * countOfWeeks)
                    }
                    
                    // If no height constraint found we set it manually.
                    var found = false
                    for constraint in constraints {
                        if constraint.firstAttribute == .Height {
                            found = true
                        }
                    }
                    
                    if !found {
                        addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: frame.height))
                    }
                    
                    weekViewSize = CGSizeMake(width, height)
                    dayViewSize = CGSizeMake((width / 7.0) - hSpace, height)
                    validated = true
                    
                    contentController.updateFrames(selfSize != contentViewSize ? bounds : CGRectZero)
                }
            }
        }
    }
}

// MARK: - Coordinator callback

extension CVCalendarView {
    public func didSelectDayView(dayView: CVCalendarDayView) {
        if let controller = contentController {
            presentedDate = dayView.date
            delegate?.didSelectDayView?(dayView, animationDidFinish: false)
            controller.performedDayViewSelection(dayView) // TODO: Update to range selection
        }
    }
}

// MARK: - Convenience API

extension CVCalendarView {
    public func changeDaysOutShowingState(shouldShow: Bool) {
        contentController.updateDayViews(shouldShow)
    }
    
    public func toggleViewWithDate(date: NSDate) {
        contentController.togglePresentedDate(date)
    }
    
    public func toggleCurrentDayView() {
        contentController.togglePresentedDate(NSDate())
    }
    
    public func loadNextView() {
        contentController.presentNextView(nil)
    }
    
    public func loadPreviousView() {
        contentController.presentPreviousView(nil)
    }
    
    public func changeMode(mode: CalendarMode, completion: () -> () = {}) {
        if let selectedDate = coordinator.selectedDayView?.date.convertedDate() where calendarMode != mode {
            calendarMode = mode
            
            let newController: ContentController
            switch mode {
            case .WeekView:
                contentController.updateHeight(dayViewSize!.height, animated: true)
                newController = WeekContentViewController(calendarView: self, frame: bounds, presentedDate: selectedDate)
            case .MonthView:
                contentController.updateHeight(contentController.presentedMonthView.potentialSize.height, animated: true)
                newController = MonthContentViewController(calendarView: self, frame: bounds, presentedDate: selectedDate)
            }
            
            
            newController.updateFrames(bounds)
            newController.scrollView.alpha = 0
            addSubview(newController.scrollView)
            
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.contentController.scrollView.alpha = 0
                newController.scrollView.alpha = 1
            }) { _ in
                self.contentController.scrollView.removeAllSubviews()
                self.contentController.scrollView.removeFromSuperview()
                self.contentController = newController
                completion()
            }
        }
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
            }
            
            addSubview(contentController.scrollView)
        }
    }
}
