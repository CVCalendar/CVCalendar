//
//  CVCalendarDayView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarDayView: UIView {
    
    // MARK: - Public properties
    
    let weekdayIndex: Int?
    let date: CVDate?
    
    weak var weekView: CVCalendarWeekView?
    
    var dayLabel: UILabel?
    var circleView: CVCircleView?
    var topMarker: CALayer?
    var dotMarker: CVCircleView?
    
    var isOut = false
    var isCurrentDay = false
    
    unowned var monthView: CVCalendarMonthView {
        get {
            var monthView: CVCalendarMonthView!
            safeExecuteBlock({
                monthView = self.weekView!.monthView!
            }, collapsingOnNil: true, withObjects: weekView, weekView?.monthView)
            
            return monthView
        }
    }
    
    unowned var calendarView: CVCalendarView {
        get {
            var calendarView: CVCalendarView!
            safeExecuteBlock({
                calendarView = self.weekView!.monthView!.calendarView!
            }, collapsingOnNil: true, withObjects: weekView, weekView?.monthView, weekView?.monthView?.calendarView)
            
            return calendarView
        }
    }
    
    override var frame: CGRect {
        didSet {
            topMarkerSetup()
        }
    }
    
    // MARK: - Initialization
    
    init(weekView: CVCalendarWeekView, frame: CGRect, weekdayIndex: Int) {
        super.init()
        
        self.frame = frame
        self.weekView = weekView
        self.weekdayIndex = weekdayIndex
        
        func hasDayAtWeekdayIndex(weekdayIndex: Int, weekdaysDictionary: [Int : [Int]]) -> Bool {
            for key in weekdaysDictionary.keys {
                if key == weekdayIndex {
                    return true
                }
            }
            
            return false
        }
        
        
        var day: Int?
        let weekdaysIn = weekView.weekdaysIn!
        
        if let weekdaysOut = weekView.weekdaysOut {
            if hasDayAtWeekdayIndex(weekdayIndex, weekdaysOut) {
                isOut = true
                day = weekdaysOut[weekdayIndex]![0]
            } else if hasDayAtWeekdayIndex(weekdayIndex, weekdaysIn) {
                day = weekdaysIn[weekdayIndex]![0]
            }
        } else {
            day = weekdaysIn[weekdayIndex]![0]
        }
        
        if day == monthView.currentDay && !isOut {
            let manager = CVCalendarManager.sharedManager
            let dateRange = manager.dateRange(monthView.date!)
            let currentDateRange = manager.dateRange(NSDate())
            
            if dateRange.month == currentDateRange.month && dateRange.year == currentDateRange.year {
                isCurrentDay = true
            }
            
        }

        var shouldShowDaysOut = calendarView.shouldShowWeekdaysOut!
        let calendarManager = CVCalendarManager.sharedManager
        let year = calendarManager.dateRange(monthView.date!).year
        var month: Int? = calendarManager.dateRange(monthView.date!).month
        
        // TODO: Fix math part
        if isOut {
            if day > 20 {
                month! -= 1
            } else {
                month! += 1
            }
            
            if !shouldShowDaysOut {
                hidden = true
            }
        }
        
        date = CVDate(day: day!, month: month!, week: weekView.index!, year: year)
        
        labelSetup()
        setupDotMarker()
        topMarkerSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subviews setup

extension CVCalendarDayView {
    func labelSetup() {
        let appearance = CVCalendarViewAppearance.sharedCalendarViewAppearance
        
        dayLabel = UILabel()
        dayLabel!.text = String(self.date!.day!)
        dayLabel!.textAlignment = NSTextAlignment.Center
        dayLabel!.frame = bounds
        
        var font = appearance.dayLabelWeekdayFont
        var color: UIColor?
        
        if isOut {
            color = appearance.dayLabelWeekdayOutTextColor
        } else if isCurrentDay {
            let coordinator = CVCalendarDayViewControlCoordinator.sharedControlCoordinator
            if coordinator.selectedDayView == nil {
                let touchController = CVCalendarTouchController.sharedTouchController
                touchController.receiveTouchOnDayView(self)
            } else {
                color = appearance.dayLabelPresentWeekdayTextColor
                if appearance.dayLabelPresentWeekdayInitallyBold! {
                    font = appearance.dayLabelPresentWeekdayBoldFont
                } else {
                    font = appearance.dayLabelPresentWeekdayFont
                }
            }
            
        } else {
            color = appearance.dayLabelWeekdayInTextColor
        }
        
        if color != nil && font != nil {
            dayLabel!.textColor = color!
            dayLabel!.font = font
        }
        
        addSubview(dayLabel!)
    }
    
    func topMarkerSetup() {
        safeExecuteBlock({
            func createMarker() {
                let height = CGFloat(0.5)
                let layer = CALayer()
                layer.borderColor = UIColor.grayColor().CGColor
                layer.borderWidth = height
                layer.frame = CGRectMake(0, 0, CGRectGetWidth(frame), height)
                
                self.topMarker = layer
                self.layer.addSublayer(self.topMarker!)
            }
            
            if let delegate = self.calendarView.delegate {
                if self.topMarker != nil {
                    self.topMarker?.removeFromSuperlayer()
                    self.topMarker = nil
                }
                
                if delegate.topMarker(shouldDisplayOnDayView: self) {
                    createMarker()
                }
            } else {
                if self.topMarker == nil {
                    createMarker()
                } else {
                    self.topMarker?.removeFromSuperlayer()
                    self.topMarker = nil
                    createMarker()
                }
            }
        }, collapsingOnNil: false, withObjects: weekView, weekView?.monthView, weekView?.monthView)
    }
    
    func setupDotMarker() {
        if let dotMarker = dotMarker {
            self.dotMarker!.removeFromSuperview()
            self.dotMarker = nil
        }
        
        if let delegate = calendarView.delegate {
            if delegate.dotMarker(shouldShowOnDayView: self) {
                let color = isOut ? .grayColor() : delegate.dotMarker(colorOnDayView: self)
                let (width: CGFloat, height: CGFloat) = (13, 13)
                
                var yOffset: CGFloat = 5
                if let y = delegate.dotMarker?(moveOffsetOnDayView: self) {
                    yOffset = y
                }
                
                let x = frame.width / 2
                let y = CGRectGetMidY(frame) + yOffset
                let markerFrame = CGRectMake(0, 0, width, height)
                
                dotMarker = CVCircleView(frame: markerFrame, color: color, _alpha: 1)
                dotMarker!.center = CGPointMake(x, y)
                insertSubview(dotMarker!, atIndex: 0)
                
                let coordinator = CVCalendarDayViewControlCoordinator.sharedControlCoordinator
                if self == coordinator.selectedDayView {
                    moveDotMarkerBack(false)
                }
            }
        }
    }
}

// MARK: - Dot marker movement

extension CVCalendarDayView {
    func moveDotMarkerBack(unwinded: Bool) {
        if let dotMarker = dotMarker {
            var shouldMove = true
            var diff: CGFloat = 0
            
            if let delegate = calendarView.delegate {
                shouldMove = delegate.dotMarker(shouldMoveOnHighlightingOnDayView: self)
            }
            
            func moveMarker() {
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    dotMarker.transform = unwinded ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, diff)
                }, completion: nil)
            }
            
            func colorMarker() {
                if let delegate = calendarView.delegate {
                    let frame = dotMarker.frame
                    var color: UIColor?
                    if unwinded {
                        if let appearance = calendarView.appearanceDelegate  {
                            color = (isOut) ? appearance.dayLabelWeekdayOutTextColor : delegate.dotMarker(colorOnDayView: self)
                        }
                    } else {
                        if let appearance = calendarView.appearanceDelegate  {
                            color = appearance.dotMarkerColor!
                        }
                    }
                    
                    dotMarker.color = color
                    dotMarker.setNeedsDisplay()
                }
                
            }
            
            if shouldMove {
                if !unwinded {
                    let radius = (min(frame.height, frame.width) - 10) / 2
                    let center = CGPointMake(CGRectGetMidX(circleView!.frame), CGRectGetMidY(circleView!.frame))
                    let maxArcPointY = center.y + radius
                    diff = maxArcPointY - dotMarker.frame.origin.y/0.95
                }
                
                if (diff > 0 && !unwinded) || unwinded {
                    moveMarker()
                } else {
                    colorMarker()
                }
            } else {
                colorMarker()
            }
        }
    }
}

// MARK: - Day label state management

extension CVCalendarDayView {
    func setDayLabelHighlighted() {
        println("Highlighted")
        let appearance = CVCalendarViewAppearance.sharedCalendarViewAppearance
        
        var backgroundColor: UIColor!
        var backgroundAlpha: CGFloat!
        
        if isCurrentDay {
            dayLabel?.textColor = appearance.dayLabelPresentWeekdayHighlightedTextColor!
            dayLabel?.font = appearance.dayLabelPresentWeekdayHighlightedFont
            backgroundColor = appearance.dayLabelPresentWeekdayHighlightedBackgroundColor
            backgroundAlpha = appearance.dayLabelPresentWeekdayHighlightedBackgroundAlpha
        } else {
            dayLabel?.textColor = appearance.dayLabelWeekdayHighlightedTextColor
            dayLabel?.font = appearance.dayLabelWeekdayHighlightedFont
            backgroundColor = appearance.dayLabelWeekdayHighlightedBackgroundColor
            backgroundAlpha = appearance.dayLabelWeekdayHighlightedBackgroundAlpha
        }
        
        if let circleView = circleView {
            circleView.color = backgroundColor
            circleView.alpha = backgroundAlpha
            circleView.setNeedsDisplay()
        } else {
            circleView = CVCircleView(frame: dayLabel!.bounds, color: backgroundColor, _alpha: backgroundAlpha)
            insertSubview(circleView!, atIndex: 0)
        }
        
        moveDotMarkerBack(false)
    }
    
    func setDayLabelUnhighlightedDismissingState(removeViews: Bool) {
        let appearance = CVCalendarViewAppearance.sharedCalendarViewAppearance
        
        var color: UIColor?
        if isOut {
            color = appearance.dayLabelWeekdayOutTextColor
        } else if isCurrentDay {
            color = appearance.dayLabelPresentWeekdayTextColor
        } else {
            color = appearance.dayLabelWeekdayInTextColor
        }
        
        var font: UIFont?
        if self.isCurrentDay {
            if appearance.dayLabelPresentWeekdayInitallyBold! {
                font = appearance.dayLabelPresentWeekdayBoldFont
            } else {
                font = appearance.dayLabelWeekdayFont
            }
        } else {
            font = appearance.dayLabelWeekdayFont
        }
        
        dayLabel?.textColor = color
        dayLabel?.font = font
        
        moveDotMarkerBack(true)
        
        if removeViews {
            circleView?.removeFromSuperview()
            circleView = nil
        }
    }
    
    func setDayLabelSelected() {
        println("Selected")
        let appearance = CVCalendarViewAppearance.sharedCalendarViewAppearance
        
        var backgroundColor: UIColor!
        var backgroundAlpha: CGFloat!
        
        if isCurrentDay {
            dayLabel?.textColor = appearance.dayLabelPresentWeekdaySelectedTextColor!
            dayLabel?.font = appearance.dayLabelPresentWeekdaySelectedFont
            backgroundColor = appearance.dayLabelPresentWeekdaySelectedBackgroundColor
            backgroundAlpha = appearance.dayLabelPresentWeekdaySelectedBackgroundAlpha
        } else {
            dayLabel?.textColor = appearance.dayLabelWeekdaySelectedTextColor
            dayLabel?.font = appearance.dayLabelWeekdaySelectedFont
            backgroundColor = appearance.dayLabelWeekdaySelectedBackgroundColor
            backgroundAlpha = appearance.dayLabelWeekdaySelectedBackgroundAlpha
        }
        
        if let circleView = circleView {
            circleView.color = backgroundColor
            circleView.alpha = backgroundAlpha
            circleView.setNeedsDisplay()
        } else {
            circleView = CVCircleView(frame: dayLabel!.bounds, color: backgroundColor, _alpha: backgroundAlpha)
            insertSubview(circleView!, atIndex: 0)
        }
        
        moveDotMarkerBack(false)
    }
    
    func setDayLabelDeselectedDismissingState(removeViews: Bool) {
        setDayLabelUnhighlightedDismissingState(removeViews)
    }

}

// MARK: - Content reload

extension CVCalendarDayView {
    func reloadContent() {
        setupDotMarker()
        dayLabel?.frame = bounds
        
        var shouldShowDaysOut = calendarView.shouldShowWeekdaysOut!
        if !shouldShowDaysOut {
            if isOut {
                hidden = true
            }
        } else {
            if isOut {
                hidden = false
            }
        }
        
        if circleView != nil {
            setDayLabelDeselectedDismissingState(true)
            setDayLabelSelected()
        }
    }
}

// MARK: - Safe execution

extension CVCalendarDayView {
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
