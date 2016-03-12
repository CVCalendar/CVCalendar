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
//public typealias ContentController = CVCalendarContentViewController
public typealias Appearance = CVCalendarViewAppearance
public typealias Coordinator = CVCalendarDayViewControlCoordinator
public typealias Date = CVDate
public typealias CalendarMode = CVCalendarViewPresentationMode
//public typealias Weekday = CVCalendarWeekday /// Deprecated since 2.0 
public typealias Animator = CVCalendarViewAnimator
public typealias Delegate = CVCalendarViewDelegate
public typealias AppearanceDelegate = CVCalendarViewAppearanceDelegate
public typealias AnimatorDelegate = CVCalendarViewAnimatorDelegate
//public typealias ContentViewController = CVCalendarContentViewController
public typealias MonthContentViewController = CVCalendarMonthContentViewController
public typealias WeekContentViewController = CVCalendarWeekContentViewController
public typealias MenuViewDelegate = CVCalendarMenuViewDelegate
public typealias TouchController = CVCalendarTouchController
public typealias SelectionType = CVSelectionType


public enum CVContentController {
    case MonthView(controller: CVCalendarMonthContentViewController)
    case WeekView(controller: CVCalendarWeekContentViewController)
    case MonthFlowView(controller: CVCalendarMonthFlowContentViewController)
    
    public var contentView: UIView {
        switch self {
        case .MonthView(let controller):
            return controller.contentView
        case .WeekView(let controller):
            return controller.contentView
        case .MonthFlowView(let controller):
            return controller.contentView
        }
    }
    
    public var manager: CVCalendarViewContentManager {
        switch self {
        case .MonthView(let controller):
            return controller as CVCalendarViewContentManager
        case .WeekView(let controller):
            return controller as CVCalendarViewContentManager
        case .MonthFlowView(let controller):
            return controller as CVCalendarViewContentManager
        }
    }
}

public final class CVCalendarView: UIView {
    // MARK: - Public properties
    public var manager: Manager!
    public var appearance: Appearance!
    public var touchController: TouchController!
    public var coordinator: Coordinator!
    public var animator: Animator!
    public var contentController: CVContentController!
    public var calendarMode: CalendarMode!
    public var sizeManager: CVCalendarSizeManager!
    
    public var (weekViewSize, dayViewSize): (CGSize?, CGSize?)
    
    public private(set) var validated = false
    
    public var firstWeekday: CVCalendarWeekday {
        if let delegate = delegate {
            return delegate.firstWeekday()
        } else {
            return .Sunday
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
        if let delegate = delegate, should = delegate.shouldAnimateResizing?() {
            return should
        }
        
        return true
    }
    
    public var shouldAutoSelectDayOnMonthChange: Bool{
        if let delegate = delegate, should = delegate.shouldAutoSelectDayOnMonthChange?() {
            return should
        }
        
        return true
    }
    
    public var shouldAutoSelectDayOnWeekChange: Bool{
        if let delegate = delegate, should = delegate.shouldAutoSelectDayOnWeekChange?() {
            return should
        }
        
        return true
    }
    
    public var shouldScrollOnOutDayViewSelection: Bool{
        if let delegate = delegate, should = delegate.shouldScrollOnOutDayViewSelection?() {
            return should
        }
        
        return true
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
    
    public var delegate: CVCalendarViewDelegate? {
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
        super.init(frame: .zero)
        hidden = true
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        hidden = true
        setup()
    }

    /// IB Initialization
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        hidden = true
        setup()
    }
    
    // MARK: - Setup 
    
    public func setup() {
        sizeManager = CVCalendarSizeManager(calendarView: self)
    }
}

// MARK: - Frames update

extension CVCalendarView {
    public func commitCalendarViewUpdate() {
        if let _ = delegate, let contentController = contentController {
            let contentViewSize = contentController.contentView.bounds.size
            let selfSize = bounds.size
            let screenSize = UIScreen.mainScreen().bounds.size
            
            let allowed = (selfSize.width <= screenSize.width && selfSize.height <= screenSize.height) || calendarMode == .MonthFlowView
            
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
                    case .MonthFlowView:
                        height = ((selfSize.height / (UIScreen.mainScreen().bounds.height / selfSize.height)) / countOfWeeks) - (vSpace * countOfWeeks) 
                    }
                    
                    // If no height constraint found we set it manually.
                    var found = false
                    for constraint in constraints {
                        if constraint.firstAttribute == .Height {
                            found = true
                            break
                        }
                    }
                    
                    if !found {
                        addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: frame.height))
                    }
                    
                    weekViewSize = CGSizeMake(width, height)
                    dayViewSize = CGSizeMake((width / 7.0) - hSpace, height)
                    validated = true
                    
                    
                    switch contentController {
                    case .MonthView(let controller):
                        controller.updateFrames(selfSize != contentViewSize ? bounds : .zero)
                    case .WeekView(let controller):
                        controller.updateFrames(selfSize != contentViewSize ? bounds : .zero)
                    case .MonthFlowView(let controller):
                        print("Updating Frames for MonthFlowView...")
                        controller.updateFrames(selfSize != contentViewSize ? bounds : .zero)
                    }
                    
                    //print("ContentView = \(contentController.contentView)")
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
            controller.manager.performedDayViewSelection?(dayView) // TODO: Update to range selection
        }
    }
}

// MARK: - Convenience API

extension CVCalendarView {
    public func changeDaysOutShowingState(shouldShow: Bool) {
        contentController.manager.updateDayViews?(shouldShow)
    }
    
    public func toggleViewWithDate(date: NSDate) {
        contentController.manager.togglePresentedDate?(date)
    }
    
    public func toggleCurrentDayView() {
        contentController.manager.togglePresentedDate?(NSDate())
    }
    
    public func loadNextView() {
        contentController.manager.presentNextView?(nil)
    }
    
    public func loadPreviousView() {
        (contentController as! CVCalendarViewContentManager).presentPreviousView?(nil)
    }
    
    public func changeMode(mode: CalendarMode, completion: () -> () = {}) {
        if let selectedDate = coordinator.selectedDayView?.date.convertedDate() where calendarMode != mode {
            calendarMode = mode
            
            guard let contentController = contentController else {
                return
            }
            
            let newController: CVContentController
            
            switch mode {
            case .WeekView:
                if case .WeekView(let controller) = contentController {
                    controller.updateHeight(dayViewSize!.height, animated: true)
                }
                
                let controller = WeekContentViewController(calendarView: self, frame: bounds, presentedDate: selectedDate)
                controller.updateFrames(bounds)
                newController = .WeekView(controller: controller)
            case .MonthView:
                if case .MonthView(let controller) = contentController {
                    controller.updateHeight(controller.presentedMonthView.potentialSize.height, animated: true)
                }
                
                
                let controller = MonthContentViewController(calendarView: self, frame: bounds, presentedDate: selectedDate)
                controller.updateFrames(bounds)
                newController = .MonthView(controller: controller)
            case .MonthFlowView:
                if case .MonthFlowView(let controller) = contentController {
                    // TODO:
                }
                
                
                let controller = CVCalendarMonthFlowContentViewController(calendarView: self, frame: bounds, presentedDate: selectedDate)
                controller.updateFrames(bounds)
                newController = .MonthFlowView(controller: controller)
            }
            
            newController.contentView.alpha = 0
            addSubview(newController.contentView)
            
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.contentController.contentView.alpha = 0
                newController.contentView.alpha = 1
            }) { _ in
                self.contentController.contentView.removeAllSubviews()
                self.contentController.contentView.removeFromSuperview()
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
            
            print("Loading mode...")
            calendarMode = delegate.presentationMode()
            switch delegate.presentationMode() {
            case .MonthView:
                print("Found Month mode")
                contentController = .MonthView(controller: MonthContentViewController(calendarView: self, frame: bounds))
            case .WeekView:
                contentController = .WeekView(controller: WeekContentViewController(calendarView: self, frame: bounds))
            case .MonthFlowView:
                contentController = .MonthFlowView(controller: CVCalendarMonthFlowContentViewController(calendarView: self, frame: bounds))
            }
            
            print("Loaded mode \(calendarMode.description)")
            print("ContentView = \(contentController.contentView)")
            
            
            addSubview(contentController.contentView)
        }
    }
}
