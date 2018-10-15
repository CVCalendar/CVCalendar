//
//  CVCalendarContentViewController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 12/04/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

public typealias Identifier = String
open class CVCalendarContentViewController: UIViewController {
    // MARK: - Constants
    public let previous = "Previous"
    public let presented = "Presented"
    public let following = "Following"

    // MARK: - Public Properties
    public unowned let calendarView: CalendarView
    public let scrollView: UIScrollView

    open var presentedMonthView: MonthView

    open var bounds: CGRect {
        return scrollView.bounds
    }

    open var currentPage = 1
    open var pageChanged: Bool {
        return currentPage == 1 ? false : true
    }

    open var pageLoadingEnabled = true
    open var presentationEnabled = true
    open var lastContentOffset: CGFloat = 0
    open var direction: CVScrollDirection = .none

    open var toggleDateAnimationDuration: Double {
        return calendarView.delegate?.toggleDateAnimationDuration?() ?? 0.8
    }

    public init(calendarView: CalendarView, frame: CGRect) {
        self.calendarView = calendarView
        scrollView = UIScrollView(frame: frame)
        presentedMonthView = MonthView(calendarView: calendarView, date: calendarView.presentedDate?.convertedDate() ?? Foundation.Date())
        presentedMonthView.updateAppearance(frame)

        super.init(nibName: nil, bundle: nil)

        scrollView.contentSize = CGSize(width: frame.width * 3, height: frame.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.layer.masksToBounds = true
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Refresh

extension CVCalendarContentViewController {
    @objc public func updateFrames(_ frame: CGRect) {
        if frame != CGRect.zero {
            scrollView.frame = frame
            scrollView.removeAllSubviews()
            scrollView.contentSize = CGSize(width: frame.size.width * 3, height: frame.size.height)
        }

        calendarView.isHidden = false
    }
}

//MARK: - Month Refresh

extension CVCalendarContentViewController {
    public func refreshPresentedMonth() {
        for weekV in presentedMonthView.weekViews {
            for dayView in weekV.dayViews {
                removeCircleLabel(dayView)
                dayView.setupDotMarker()
                dayView.preliminarySetup()
                dayView.supplementarySetup()
                dayView.topMarkerSetup()
                dayView.interactionSetup()
                dayView.labelSetup()
            }
        }
    }
}


// MARK: Delete circle views (in effect refreshing the dayView circle)

extension CVCalendarContentViewController {
    func removeCircleLabel(_ dayView: CVCalendarDayView) {
        for each in dayView.subviews {
            if each is UILabel {
                continue
            } else if each is CVAuxiliaryView {
                continue
            } else {
                each.removeFromSuperview()
            }
        }
    }
}

//MARK: Delete dot views (in effect refreshing the dayView dots)

extension CVCalendarContentViewController {
    func removeDotViews(_ dayView: CVCalendarDayView) {
        for each in dayView.subviews {
            if each is CVAuxiliaryView && each.frame.height == 13 {
                each.removeFromSuperview()
            }
        }
    }
}

// MARK: - Abstract methods

/// UIScrollViewDelegate
extension CVCalendarContentViewController: UIScrollViewDelegate { }

// Convenience API.
extension CVCalendarContentViewController {
    @objc public func performedDayViewSelection(_ dayView: DayView) { }

    @objc public func togglePresentedDate(_ date: Foundation.Date) { }

    @objc public func presentNextView(_ view: UIView?) { }

    @objc public func presentPreviousView(_ view: UIView?) { }

    @objc public func updateDayViews(shouldShow: Bool) { }
}

// MARK: - Contsant conversion

extension CVCalendarContentViewController {
    public func indexOfIdentifier(_ identifier: Identifier) -> Int {
        let index: Int
        switch identifier {
        case previous: index = 0
        case presented: index = 1
        case following: index = 2
        default: index = -1
        }

        return index
    }
}

// MARK: - Date management

extension CVCalendarContentViewController {
    public func dateBeforeDate(_ date: Foundation.Date) -> Foundation.Date {
        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current
        var components = Manager.componentsForDate(date, calendar: calendar)

        components.month! -= 1

        let dateBefore = calendar.date(from: components)!

        return dateBefore
    }

    public func dateAfterDate(_ date: Foundation.Date) -> Foundation.Date {
        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current
        var components = Manager.componentsForDate(date, calendar: calendar)

        components.month! += 1

        let dateAfter = calendar.date(from: components)!

        return dateAfter
    }

    public func matchedMonths(_ lhs: CVDate, _ rhs: CVDate) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month
    }

    public func matchedWeeks(_ lhs: CVDate, _ rhs: CVDate) -> Bool {
        return (lhs.year == rhs.year && lhs.month == rhs.month && lhs.week == rhs.week)
    }

    public func matchedDays(_ lhs: CVDate, _ rhs: CVDate) -> Bool {
        return (lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day)
    }
}

// MARK: - AutoLayout Management

extension CVCalendarContentViewController {
    fileprivate func layoutViews(_ views: [UIView], toHeight height: CGFloat) {
        scrollView.frame.size.height = height

        var superStack = [UIView]()
        var currentView: UIView = calendarView
        while let currentSuperview = currentView.superview , !(currentSuperview is UIWindow) {
            superStack += [currentSuperview]
            currentView = currentSuperview
        }

        for view in views + superStack {
            view.layoutIfNeeded()
        }
    }

    public func updateHeight(_ height: CGFloat, animated: Bool) {
        if calendarView.shouldAnimateResizing {
            var viewsToLayout = [UIView]()
            if let calendarSuperview = calendarView.superview {
                for constraintIn in calendarSuperview.constraints {
                    if let firstItem = constraintIn.firstItem as? UIView,
                        let _ = constraintIn.secondItem as? CalendarView {

                            viewsToLayout.append(firstItem)
                    }
                }
            }


            for constraintIn in calendarView.constraints where
                constraintIn.firstAttribute == NSLayoutConstraint.Attribute.height {
                    constraintIn.constant = height

                    if animated {
                        UIView.animate(withDuration: 0.2, delay: 0,
                                                   options: UIView.AnimationOptions.curveLinear,
                                                   animations: { [weak self] in
                            self?.layoutViews(viewsToLayout, toHeight: height)
                        }) { [weak self] _ in
                            guard let strongSelf = self else {
                                return
                            }
                            strongSelf.presentedMonthView.frame.size = strongSelf.presentedMonthView.potentialSize
                            strongSelf.presentedMonthView.updateInteractiveView()
                        }
                    } else {
                        layoutViews(viewsToLayout, toHeight: height)
                        presentedMonthView.updateInteractiveView()
                        presentedMonthView.frame.size = presentedMonthView.potentialSize
                        presentedMonthView.updateInteractiveView()
                    }

                    break
            }
        }
    }

    public func updateLayoutIfNeeded() {
        if presentedMonthView.potentialSize.height != scrollView.bounds.height {
            updateHeight(presentedMonthView.potentialSize.height, animated: true)
        } else if presentedMonthView.frame.size != scrollView.frame.size {
            presentedMonthView.frame.size = presentedMonthView.potentialSize
            presentedMonthView.updateInteractiveView()
        }
    }
}

extension UIView {
    public func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
}
