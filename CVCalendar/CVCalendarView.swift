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

    fileprivate var validated = false

    public var firstWeekday: Weekday {
        get {
            if let delegate = delegate {
                return delegate.firstWeekday()
            } else {
                return .sunday
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

    public var presentedDate: CVDate! {
        didSet {
            if let _ = oldValue {
                delegate?.presentedDateUpdated?(presentedDate)
            }
        }
    }

    public var shouldAnimateResizing: Bool {
        get {
            if let delegate = delegate, let should = delegate.shouldAnimateResizing?() {
                return should
            }

            return true
        }
    }

    public var shouldAutoSelectDayOnMonthChange: Bool {
        get {
            if let delegate = delegate, let should = delegate.shouldAutoSelectDayOnMonthChange?() {
                return should
            }
            return true
        }
    }

    public var shouldAutoSelectDayOnWeekChange: Bool {
        get {
            if let delegate = delegate, let should = delegate.shouldAutoSelectDayOnWeekChange?() {
                return should
            }
            return true
        }
    }

    public var shouldScrollOnOutDayViewSelection: Bool {
        get {
            if let delegate = delegate, let should = delegate.shouldScrollOnOutDayViewSelection?() {
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
        super.init(frame: CGRect.zero)
        isHidden = true
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
    }

    // IB Initialization
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isHidden = true
    }
}

// MARK: - Frames update

extension CVCalendarView {
    public func commitCalendarViewUpdate() {
        if let _ = delegate, let contentController = contentController {
            let contentViewSize = contentController.bounds.size
            let selfSize = bounds.size
            let screenSize = UIScreen.main.bounds.size

            let allowed = selfSize.width <= screenSize.width && selfSize.height <= screenSize.height

            if !validated && allowed {
                let width = selfSize.width
                let height: CGFloat
                let countOfWeeks = CGFloat(6)

                let vSpace = appearance.spaceBetweenWeekViews!
                let hSpace = appearance.spaceBetweenDayViews!

                if let mode = calendarMode {
                    switch mode {
                    case .weekView:
                        height = selfSize.height
                    case .monthView :
                        height = (selfSize.height / countOfWeeks) - (vSpace * countOfWeeks)
                    }

                    // If no height constraint found we set it manually.
                    var found = false
                    for constraint in constraints {
                        if constraint.firstAttribute == .height {
                            found = true
                        }
                    }

                    if !found {
                        addConstraint(NSLayoutConstraint(item: self, attribute: .height,
                            relatedBy: .equal, toItem: nil, attribute: .height,
                            multiplier: 1, constant: frame.height))
                    }

                    weekViewSize = CGSize(width: width, height: height)
                    dayViewSize = CGSize(width: (width / 7.0) - hSpace, height: height)
                    validated = true

                    contentController
                        .updateFrames(selfSize != contentViewSize ? bounds : CGRect.zero)
                }
            }
        }
    }
}

// MARK: - Coordinator callback

extension CVCalendarView {
    public func didSelectDayView(_ dayView: CVCalendarDayView) {
        if let controller = contentController {
            presentedDate = dayView.date
            delegate?.didSelectDayView?(dayView, animationDidFinish: false)
            controller.performedDayViewSelection(dayView) // TODO: Update to range selection
        }
    }
}

// MARK: - Convenience API

extension CVCalendarView {
    public func changeDaysOutShowingState(_ shouldShow: Bool) {
        contentController.updateDayViews(shouldShow)
    }

    public func toggleViewWithDate(_ date: Foundation.Date) {
        contentController.togglePresentedDate(date)
    }

    public func toggleCurrentDayView() {
        contentController.togglePresentedDate(Foundation.Date())
    }

    public func loadNextView() {
        contentController.presentNextView(nil)
    }

    public func loadPreviousView() {
        contentController.presentPreviousView(nil)
    }

    public func changeMode(_ mode: CalendarMode, completion: @escaping () -> () = {}) {
        guard let selectedDate = coordinator.selectedDayView?.date.convertedDate() ,
            calendarMode != mode else {
                return
        }

        calendarMode = mode

        let newController: ContentController
        switch mode {
        case .weekView:
            contentController.updateHeight(dayViewSize!.height, animated: true)
            newController = WeekContentViewController(calendarView: self, frame: bounds,
                                                      presentedDate: selectedDate)
        case .monthView:
            contentController.updateHeight(
                contentController.presentedMonthView.potentialSize.height, animated: true)
            newController = MonthContentViewController(calendarView: self, frame: bounds,
                                                       presentedDate: selectedDate)
        }

        newController.updateFrames(bounds)
        newController.scrollView.alpha = 0
        addSubview(newController.scrollView)

        UIView.animate(withDuration: 0.5, delay: 0,
                                   options: UIViewAnimationOptions(), animations: {
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

// MARK: - Mode load

private extension CVCalendarView {
    func loadCalendarMode() {
        if let delegate = delegate {
            calendarMode = delegate.presentationMode()
            switch delegate.presentationMode() {
                case .monthView:
                    contentController =
                        MonthContentViewController(calendarView: self, frame: bounds)
                case .weekView:
                    contentController =
                        WeekContentViewController(calendarView: self, frame: bounds)
            }

            addSubview(contentController.scrollView)
        }
    }
}
