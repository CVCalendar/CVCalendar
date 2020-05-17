//
//  CVCalendarDayView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarDayView: UIView {
    // MARK: - Public properties
    public let weekdayIndex: Int!
    public weak var weekView: CVCalendarWeekView!
    
    public var date: CVDate!
    public var dayLabel: UILabel!
    
    public var selectionView: CVAuxiliaryView?
    public var topMarker: CALayer?
    public var dotMarkers = [CVAuxiliaryView?]()
    
    public var isOut = false
    public var isCurrentDay = false
    public var isDisabled: Bool { return !self.isUserInteractionEnabled }
    
    public weak var monthView: CVCalendarMonthView! {
        var monthView: MonthView!
        if let weekView = weekView, let activeMonthView = weekView.monthView {
            monthView = activeMonthView
        }
        
        return monthView
    }
    
    public weak var calendarView: CVCalendarView! {
        var calendarView: CVCalendarView!
        if let weekView = weekView, let activeCalendarView = weekView.calendarView {
            calendarView = activeCalendarView
        }
        
        return calendarView
    }
    
    public override var frame: CGRect {
        didSet {
            if oldValue != frame {
                selectionView?.setNeedsDisplay()
                topMarkerSetup()
                preliminarySetup()
                if date != nil {
                    supplementarySetup()
                }
            }
        }
    }
    
    // MARK: - Private properties
    
    fileprivate var preliminaryView: UIView?
    fileprivate var supplementaryView: UIView?
    fileprivate var dotColors = [UIColor]()
    
    // MARK: - Initialization
    
    public init(weekView: CVCalendarWeekView, weekdayIndex: Int) {
        self.weekView = weekView
        self.weekdayIndex = weekdayIndex
        
        if let size = weekView.calendarView.dayViewSize {
            let hSpace = weekView.calendarView.appearance.spaceBetweenDayViews!
            let x = (CGFloat(weekdayIndex - 1) * (size.width + hSpace)) + (hSpace/2)
            super.init(frame: CGRect(x: x, y: 0, width: size.width, height: size.height))
        } else {
            super.init(frame: CGRect.zero)
        }
        
        date = dateWithWeekView(weekView, andWeekIndex: weekdayIndex)
        
        interactionSetup()
        labelSetup()
        setupDotMarker()
        topMarkerSetup()
        
        if frame.width > 0 {
            preliminarySetup()
            supplementarySetup()
        }
        
        if !calendarView.shouldShowWeekdaysOut && isOut {
            isHidden = true
        }
    }
    
    public func dateWithWeekView(_ weekView: CVCalendarWeekView, andWeekIndex index: Int) -> CVDate {
        func hasDayAtWeekdayIndex(_ weekdayIndex: Int, weekdaysDictionary: [Int : [Int]]) -> Bool {
            for key in weekdaysDictionary.keys {
                if key == weekdayIndex {
                    return true
                }
            }
            
            return false
        }
        
        var day: Int!
        let weekdaysIn = weekView.weekdaysIn
        
        if let weekdaysOut = weekView.weekdaysOut {
            if hasDayAtWeekdayIndex(weekdayIndex, weekdaysDictionary: weekdaysOut) {
                isOut = true
                day = weekdaysOut[weekdayIndex]![0]
            } else if hasDayAtWeekdayIndex(weekdayIndex, weekdaysDictionary: weekdaysIn!) {
                day = weekdaysIn![weekdayIndex]![0]
            }
        } else {
            day = weekdaysIn![weekdayIndex]![0]
        }
        
        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current
        
        if day == monthView.currentDay && !isOut {
            let dateRange = Manager.dateRange(monthView.date, calendar: calendar)
            let currentDateRange = Manager.dateRange(Foundation.Date(), calendar: calendar)
            
            if dateRange.month == currentDateRange.month &&
                dateRange.year == currentDateRange.year {
                isCurrentDay = true
            }
        }
        
        let dateRange = Manager.dateRange(monthView.date, calendar: calendar)
        let year = dateRange.year
        let week = weekView.index + 1
        var month = dateRange.month
        
        if isOut {
            day > 20 ? (month -= 1) : (month += 1)
        }
        
        return CVDate(day: day, month: month, week: week, year: year, calendar: calendar)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subviews setup

extension CVCalendarDayView {
    public func labelSetup() {
        let appearance = calendarView.appearance
        
        dayLabel = UILabel()
        let numberFormatter = NumberFormatter()
        if let locale = calendarView.delegate?.calendar?()?.locale {
            numberFormatter.locale = locale
        }
        dayLabel?.text = numberFormatter.string(from: NSNumber.init(value: date.day))
        dayLabel?.textAlignment = NSTextAlignment.center
        dayLabel?.frame = bounds
        
        var font: UIFont? = appearance?.dayLabelWeekdayFont
        var color: UIColor?
        
        if isDisabled {
            color = appearance?.dayLabelWeekdayDisabledColor
        } else if isOut {
            color = appearance?.dayLabelWeekdayOutTextColor
        } else if isCurrentDay {
            let coordinator = calendarView.coordinator
            if coordinator?.selectedDayView == nil && calendarView.shouldAutoSelectDayOnMonthChange {
                let touchController = calendarView.touchController
                touchController?.receiveTouchOnDayView(self)
                calendarView.didSelectDayView(self)
                color = appearance?.dayLabelPresentWeekdaySelectedTextColor
            } else {
                color = appearance?.dayLabelPresentWeekdayTextColor
                if (appearance?.dayLabelPresentWeekdayInitallyBold!)! {
                    font = appearance?.dayLabelPresentWeekdayBoldFont
                } else {
                    font = appearance?.dayLabelPresentWeekdayFont
                }
            }
            
        } else {
            color = appearance?.dayLabelWeekdayInTextColor
        }
        
        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current
        let weekDay = self.date?.weekDay(calendar: calendar) ?? .monday // Monday is default
        let status: CVStatus = {
            if isDisabled { return .disabled }
            else if isOut { return .out }
            return .in
        }()
        let present: CVPresent = isCurrentDay
            && !(calendarView.coordinator.selectedDayView == nil
                && calendarView.shouldAutoSelectDayOnMonthChange)
            ? .present
            : .not
        
        dayLabel?.textColor = appearance?.delegate?.dayLabelColor?(by: weekDay, status: status, present: present) ?? color
        dayLabel?.font = appearance?.delegate?.dayLabelFont?(by: weekDay, status: status, present: present) ?? font
        
        addSubview(dayLabel)
    }
    
    public func interactionSetup() {
        if let shouldSelect = calendarView.delegate?.shouldSelectDayView?(self) {
            self.isUserInteractionEnabled = shouldSelect
        }
    }
    
    public func preliminarySetup() {
        if let delegate = calendarView.delegate,
            let shouldShow = delegate.preliminaryView?(shouldDisplayOnDayView: self) , shouldShow {
            if let preView = delegate.preliminaryView?(viewOnDayView: self) {
                preliminaryView?.removeFromSuperview()
                preliminaryView = preView
                weekView.insertSubview(preView, at: 0)
                preView.layer.zPosition = CGFloat(-MAXFLOAT)
            }
        }
        else {
            preliminaryView?.removeFromSuperview()
        }
    }
    
    public func supplementarySetup() {
        if let delegate = calendarView.delegate,
            let shouldShow = delegate.supplementaryView?(shouldDisplayOnDayView: self) ,
            shouldShow {
            if let supView = delegate.supplementaryView?(viewOnDayView: self) {
                supplementaryView?.removeFromSuperview()
                supplementaryView = supView
                weekView.insertSubview(supView, at: 0)
            }
        } else {
            supplementaryView?.removeFromSuperview()
            supplementaryView = nil
        }
    }
    
    // TODO: Make this widget customizable
    public func topMarkerSetup() {
        safeExecuteBlock({
            func createMarker() {
                let appearance = self.calendarView.appearance
                let height = CGFloat(0.5)
                let layer = CALayer()
                layer.borderColor = (appearance?.delegate?.topMarkerColor?() ?? .gray).cgColor
                layer.borderWidth = height
                layer.frame = CGRect(x: 0, y: 1, width: self.frame.width, height: height)
                
                self.topMarker = layer
                self.layer.addSublayer(self.topMarker!)
            }
            
            if let delegate = self.calendarView.delegate {
                if self.topMarker != nil {
                    self.topMarker?.removeFromSuperlayer()
                    self.topMarker = nil
                }
                
                if let shouldDisplay = delegate.topMarker?(shouldDisplayOnDayView: self) ,
                    shouldDisplay {
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
        }, collapsingOnNil: false,
           withObjects: weekView, weekView.monthView, weekView.monthView)
    }
    
    public func setupDotMarker() {
        for (index, dotMarker) in dotMarkers.enumerated() {
            dotMarker?.removeFromSuperview()
            dotMarkers[index] = nil
        }
        
        if let delegate = calendarView.delegate {
            if let shouldShow = delegate.dotMarker?(shouldShowOnDayView: self) , shouldShow {
                
                var (width, height): (CGFloat, CGFloat) = (13, 13)
                if let size = delegate.dotMarker?(sizeOnDayView: self) {
                    (width, height) = (size, size)
                }
                let colors = isOut ? [.gray] : delegate.dotMarker?(colorOnDayView: self)
                var yOffset = bounds.height / 5
                if let y = delegate.dotMarker?(moveOffsetOnDayView: self) {
                    yOffset = y
                }
                let y = frame.midY + yOffset
                let markerFrame = CGRect(x: 0, y: 0, width: width, height: height)
                
                if colors!.count > 3 {
                    assert(false, "Only 3 dot markers allowed per day")
                }
                
                dotColors = colors!
                
                for (index, color) in (colors!).enumerated() {
                    var x: CGFloat = 0
                    switch colors!.count {
                    case 1:
                        x = frame.width / 2
                    case 2:
                        x = frame.width * CGFloat(2+index)/5.00 // frame.width * (2/5, 3/5)
                    case 3:
                        x = frame.width * CGFloat(2+index)/6.00 // frame.width * (1/3, 1/2, 2/3)
                    default:
                        break
                    }
                    
                    let dotMarker = CVAuxiliaryView(dayView: self,
                                                    rect: markerFrame, shape: .circle)
                    dotMarker.fillColor = color
                    dotMarker.center = CGPoint(x: x, y: y)
                    insertSubview(dotMarker, at: 0)
                    
                    dotMarker.setNeedsDisplay()
                    dotMarkers.append(dotMarker)
                }
                
                let coordinator = calendarView.coordinator
                if self == coordinator?.selectedDayView {
                    moveDotMarkerBack(false, coloring: false)
                }
            }
        }
    }
}

// MARK: - Dot marker movement

extension CVCalendarDayView {
    public func moveDotMarkerBack(_ unwinded: Bool, coloring: Bool) {
        var coloring = coloring
        var dotIndex = 0
        for dotMarker in dotMarkers {
            if let calendarView = calendarView, let dotMarker = dotMarker {
                var shouldMove = true
                if let delegate = calendarView.delegate,
                    let move = delegate.dotMarker?(shouldMoveOnHighlightingOnDayView: self) ,
                    !move {
                    shouldMove = move
                }
                
                func colorMarker() {
                    let appearance = calendarView.appearance
                    var color: UIColor?
                    if unwinded {
                        color = isOut ?
                            appearance?.dayLabelWeekdayOutTextColor : dotColors[dotIndex]
                    } else {
                        color = appearance?.dotMarkerColor
                    }
                    
                    dotMarker.fillColor = color
                    dotMarker.setNeedsDisplay()
                }
                
                func moveMarker() {
                    var transform: CGAffineTransform!
                    if let selectionView = selectionView {
                        let point = pointAtAngle(CGFloat(-90).toRadians(),
                                                 withinCircleView: selectionView)
                        let spaceBetweenDotAndCircle = CGFloat(1)
                        let offset = point.y - dotMarker.frame.origin.y -
                            dotMarker.bounds.height/2 + spaceBetweenDotAndCircle
                        transform = unwinded ? CGAffineTransform.identity :
                            CGAffineTransform(translationX: 0, y: offset)
                        
                        if dotMarker.center.y + offset > frame.maxY {
                            //coloring = true
                        }
                    } else {
                        transform = CGAffineTransform.identity
                    }
                    
                    if !coloring {
                        UIView.animate(
                            withDuration: 0.3, delay: 0,
                            usingSpringWithDamping: 0.6,
                            initialSpringVelocity: 0,
                            options: UIView.AnimationOptions.curveEaseOut,
                            animations: {
                                dotMarker.transform = transform
                        },
                            completion: { _ in
                        }
                        )
                    } else {
                        moveDotMarkerBack(unwinded, coloring: coloring)
                    }
                }
                
                if shouldMove && !coloring {
                    moveMarker()
                } else {
                    colorMarker()
                }
                dotIndex += 1
            }
        }
    }
}


// MARK: - Circle geometry

extension CGFloat {
    public func toRadians() -> CGFloat {
      return CGFloat(self) * CGFloat(Double.pi / 180)
    }
    
    public func toDegrees() -> CGFloat {
        return CGFloat(180/Double.pi) * self
    }
}

extension CVCalendarDayView {
    public func pointAtAngle(_ angle: CGFloat, withinCircleView circleView: UIView) -> CGPoint {
        let radius = circleView.bounds.width / 2
        let xDistance = radius * cos(angle)
        let yDistance = radius * sin(angle)
        
        let center = circleView.center
        let x = floor(cos(angle)) < 0 ? center.x - xDistance : center.x + xDistance
        let y = center.y - yDistance
        
        let result = CGPoint(x: x, y: y)
        
        return result
    }
    
    public func moveView(_ view: UIView, onCircleView circleView: UIView,
                         fromAngle angle: CGFloat, toAngle endAngle: CGFloat, straight: Bool) {
        //        let condition = angle > endAngle ? angle > endAngle : angle < endAngle
        if straight && angle < endAngle || !straight && angle > endAngle {
            UIView.animate(withDuration: pow(10, -1000), delay: 0, usingSpringWithDamping: 0.4,
                           initialSpringVelocity: 10,
                           options: UIView.AnimationOptions.curveEaseIn, animations: { [weak self] in
                            guard let strongSelf = self else {
                                return
                            }
                            let angle = angle.toRadians()
                            view.center = strongSelf.pointAtAngle(angle, withinCircleView: circleView)
            }) { [weak self] _ in
                let speed = CGFloat(750).toRadians()
                let newAngle = straight ? angle + speed : angle - speed
                self?.moveView(view, onCircleView: circleView, fromAngle: newAngle,
                               toAngle: endAngle, straight: straight)
            }
        }
    }
}

// MARK: - Day label state management

extension CVCalendarDayView {
    public func setSelectedWithType(_ type: SelectionType) {
        
        let appearance = calendarView.appearance
        var backgroundColor: UIColor!
        var backgroundAlpha: CGFloat!
        var shape: CVShape!
        
        let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current
        let weekDay = self.date?.weekDay(calendar: calendar) ?? .monday // Monday is default
        let present: CVPresent = isCurrentDay ? .present : .not
        
        switch type {
        case .single:
            shape = .circle
            
            if let delegate = calendarView.delegate,
                let shouldShowCustomSelection = delegate.shouldShowCustomSingleSelection?() ,
                shouldShowCustomSelection {
                if let block = delegate.selectionViewPath?() {
                    shape = .custom(block)
                }
            }
            
            if isCurrentDay {
                dayLabel?.textColor = appearance?.delegate?.dayLabelColor?(by: weekDay, status: .selected, present: present)
                    ?? appearance?.dayLabelPresentWeekdaySelectedTextColor!
                dayLabel?.font = appearance?.delegate?.dayLabelFont?(by: weekDay, status: .selected, present: present)
                    ?? appearance?.dayLabelPresentWeekdaySelectedFont
                backgroundColor = appearance?.delegate?.dayLabelBackgroundColor?(by: weekDay, status: .selected, present: present)
                    ?? appearance?.dayLabelPresentWeekdaySelectedBackgroundColor
                backgroundAlpha = appearance?.dayLabelPresentWeekdaySelectedBackgroundAlpha
            } else {
                dayLabel?.textColor = appearance?.delegate?.dayLabelColor?(by: weekDay, status: .selected, present: present)
                    ?? appearance?.dayLabelWeekdaySelectedTextColor
                dayLabel?.font = appearance?.delegate?.dayLabelFont?(by: weekDay, status: .selected, present: present)
                    ?? appearance?.dayLabelWeekdaySelectedFont
                backgroundColor = appearance?.delegate?.dayLabelBackgroundColor?(by: weekDay, status: .selected, present: present)
                    ?? appearance?.dayLabelWeekdaySelectedBackgroundColor
                backgroundAlpha = appearance?.dayLabelWeekdaySelectedBackgroundAlpha
            }
            
        case .range:
            shape = .rect
            if isCurrentDay {
                dayLabel?.textColor = appearance?.delegate?.dayLabelColor?(by: weekDay, status: .highlighted, present: present)
                    ?? appearance?.dayLabelPresentWeekdayHighlightedTextColor!
                dayLabel?.font = appearance?.delegate?.dayLabelFont?(by: weekDay, status: .highlighted, present: present)
                    ?? appearance?.dayLabelPresentWeekdayHighlightedFont
                backgroundColor = appearance?.delegate?.dayLabelBackgroundColor?(by: weekDay, status: .selected, present: present)
                    ?? appearance?.dayLabelPresentWeekdayHighlightedBackgroundColor
                backgroundAlpha = appearance?.dayLabelPresentWeekdayHighlightedBackgroundAlpha
            } else {
                dayLabel?.textColor = appearance?.delegate?.dayLabelColor?(by: weekDay, status: .highlighted, present: present)
                    ?? appearance?.dayLabelWeekdayHighlightedTextColor
                dayLabel?.font = appearance?.delegate?.dayLabelFont?(by: weekDay, status: .highlighted, present: present)
                    ?? appearance?.dayLabelWeekdayHighlightedFont
                backgroundColor = appearance?.delegate?.dayLabelBackgroundColor?(by: weekDay, status: .selected, present: present)
                    ?? appearance?.dayLabelWeekdayHighlightedBackgroundColor
                backgroundAlpha = appearance?.dayLabelWeekdayHighlightedBackgroundAlpha
            }
        }
        
        if let selectionView = selectionView , selectionView.frame != dayLabel.bounds {
            selectionView.frame = dayLabel.bounds
        } else {
            selectionView = CVAuxiliaryView(dayView: self, rect: dayLabel.bounds, shape: shape)
        }
        
        selectionView!.fillColor = backgroundColor
        selectionView!.alpha = backgroundAlpha
        selectionView!.setNeedsDisplay()
        insertSubview(selectionView!, at: 0)
        
        moveDotMarkerBack(false, coloring: false)
    }
    
    public func setDeselectedWithClearing(_ clearing: Bool) {
        if let calendarView = calendarView, let appearance = calendarView.appearance {
            var color: UIColor?
            if isDisabled {
                color = appearance.dayLabelWeekdayDisabledColor
            } else if isOut {
                color = appearance.dayLabelWeekdayOutTextColor
            } else if isCurrentDay {
                color = appearance.dayLabelPresentWeekdayTextColor
            } else {
                color = appearance.dayLabelWeekdayInTextColor
            }
            
            var font: UIFont?
            if isCurrentDay {
                if appearance.dayLabelPresentWeekdayInitallyBold! {
                    font = appearance.dayLabelPresentWeekdayBoldFont
                } else {
                    font = appearance.dayLabelWeekdayFont
                }
            } else {
                font = appearance.dayLabelWeekdayFont
            }
            
            let calendar = self.calendarView.delegate?.calendar?() ?? Calendar.current
            let weekDay = self.date?.weekDay(calendar: calendar) ?? .monday // Monday is default
            let status: CVStatus = {
                if isDisabled { return .disabled }
                else if isOut { return .out }
                return .in
            }()
            let present: CVPresent = isCurrentDay ? .present : .not
            
            dayLabel?.textColor = appearance.delegate?.dayLabelColor?(by: weekDay, status: status, present: present) ?? color
            dayLabel?.font = appearance.delegate?.dayLabelFont?(by: weekDay, status: status, present: present) ?? font
            
            moveDotMarkerBack(true, coloring: false)
            
            if clearing {
                selectionView?.removeFromSuperview()
                selectionView = nil
            }
        }
    }
}


// MARK: - Content reload

extension CVCalendarDayView {
    public func reloadContent() {
        setupDotMarker()
        dayLabel?.frame = bounds
        
        let shouldShowDaysOut = calendarView.shouldShowWeekdaysOut!
        if !shouldShowDaysOut {
            if isOut {
                isHidden = true
            }
        } else {
            if isOut {
                isHidden = false
            }
        }
        
        if selectionView != nil {
            selectionView?.removeFromSuperview()
            let selectionType = calendarView.shouldSelectRange ? CVSelectionType.range(.changed) : CVSelectionType.single
            setSelectedWithType(selectionType)
        }
    }
}

// MARK: - Safe execution

extension CVCalendarDayView {
    public func safeExecuteBlock(_ block: () -> Void, collapsingOnNil collapsing: Bool,
                                 withObjects objects: AnyObject?...) {
        for object in objects {
            if object == nil {
                if collapsing {
                  fatalError("Object { \(String(describing: object)) } must not be nil!")
                } else {
                    return
                }
            }
        }
        
        block()
    }
}
