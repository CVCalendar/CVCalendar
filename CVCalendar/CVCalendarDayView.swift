//
//  CVCalendarDayView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

internal extension UIFont {
    func decreased() -> UIFont {
        return UIFont(name: fontName, size: pointSize - 1)!
    }
    
    func increased() -> UIFont {
        return UIFont(name: fontName, size: pointSize + 1)!
    }
}

internal postfix func --(inout lhs: UIFont!) {
    lhs = lhs.decreased()
}

internal postfix func ++(inout lhs: UIFont!) {
    lhs = lhs.increased()
}

internal extension CGRect {
    var mid: CGPoint {
        return CGPoint(x: width / 2, y: height / 2)
    }
}

public final class CVCalendarDayView: UIView {
    // MARK: - Public properties
    public var weekdayIndex: Int!
    public weak var weekView: CVCalendarWeekView!
    
    public var date: CVDate!
    public var dayLabel: UILabel!
    
    public var selectionView: CVAuxiliaryView?
    public var topMarker: CALayer?
    public var dotMarkers = [CVAuxiliaryView?]()
    
    public var complementaryView: UIView?
    public var supplementaryView: UIView?
    public var prelimitaryView: UIView?
    
    public var isOut = false {
        didSet {
            labelSetup()
            
            if !calendarView.shouldShowWeekdaysOut {
                hidden = true 
            }
            
            if !isOut || calendarView.shouldShowWeekdaysOut! {
                hidden = false 
            }
        }
    }
    
    public var isCurrentDay = false
    
    public var weekIndex = 0
    
    public var weekday: Weekday
    
    private var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - UI Properties 
    
    public var topMarkerHidden = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private static var count = 0
    
    public weak var monthView: CVCalendarMonthView! {
        var monthView: MonthView!
        if let weekView = weekView, activeMonthView = weekView.monthView {
            monthView = activeMonthView
        }
        
        return monthView
    }
    
    private weak var _calendarView: CVCalendarView!
    
    public weak var calendarView: CVCalendarView! {
        set {
            self._calendarView = newValue
        }
        
        get {
            if let calendarView = _calendarView {
                return calendarView
            } else if let weekView = weekView, let activeCalendarView = weekView.calendarView {
                return activeCalendarView
            } else {
                return nil
            }
        }
    }
    
    public override var frame: CGRect {
        didSet {
            if oldValue != frame {
                selectionView?.setNeedsDisplay()
                //topMarkerSetup()
                preliminarySetup()
                supplementarySetup()
            }
        }
    }
    
    public override var hidden: Bool {
        didSet {
            userInteractionEnabled = hidden ? false : true
        }
    }
    
    // MARK: - Initialization
    
    public init(weekView: CVCalendarWeekView, weekdayIndex: Int, weekday: Weekday) {
        self.weekView = weekView
        self.weekdayIndex = weekdayIndex
        self.weekday = weekday
        
        if let size = weekView.calendarView.dayViewSize {
            let hSpace = weekView.calendarView.appearance.spaceBetweenDayViews!
            let x = (CGFloat(weekdayIndex - 1) * (size.width + hSpace)) + (hSpace/2)
            super.init(frame: CGRectMake(x, 0, size.width, size.height))
        } else {
            super.init(frame: .zero)
        }
        
        date = dateWithWeekView(weekView, andWeekIndex: weekdayIndex)

        setup()
        
        //print("TextSize \(textSize), SelectionSize: \(CVAuxiliaryView(dayView: self, rect: dayLabel.frame, shape: .Circle).frame.size)")
    }
    
    public init(calendarView: CVCalendarView, date: CVDate) {
        self.date = date
        self.weekday = Weekday(rawValue: CVCalendarManager.componentsForDate(date.convertedDate()!).weekday)!
        super.init(frame: .zero)
        self.calendarView = calendarView
        
        setup()
    }
    
    public func setup() {
        isCurrentDay = date == CVDate(date: NSDate())
        
        labelSetup()
        complementarySetup()
        setupDotMarker()
        //topMarkerSetup()
        
        if (frame.width > 0) {
            preliminarySetup()
            supplementarySetup()
        }
        
        if !calendarView.shouldShowWeekdaysOut && isOut {
            hidden = true
        }
        
        backgroundColor = .clearColor()
        
        addConstraints()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        adjustLabelFontSize()
    }
   
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        drawTopMarker()
    }
    
    public func dateWithWeekView(weekView: CVCalendarWeekView, andWeekIndex index: Int) -> CVDate {
        let day: Int!
        let monthDate = monthView.date
        
        if let date = weekView.weekdays[weekday] {
            day = date.day.value()

            if date.month.value() != monthDate.month.value() {
                isOut = true
            }
        } else {
            assert(false, "Day data is failed to calculate....")
            day = -1
        }
        
        var offset = 0
        if isOut {
            offset = day > 20 ? -1 : 1
        }
        
        return CVDate(day: day, month: monthDate.month.value() + offset, week: weekView.index + 1, year: monthDate.year.value())
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func reloadWithDate(date: CVDate) {
        self.date = date
        
        isCurrentDay = date == CVDate(date: NSDate())
        
        labelSetup()
        complementarySetup()
        setupDotMarker()
        //topMarkerSetup()
        
        if (frame.width > 0) {
            preliminarySetup()
            supplementarySetup()
        }
        
        if !calendarView.shouldShowWeekdaysOut && isOut {
            hidden = true
        }
        
        backgroundColor = .clearColor()
    }
}

// MARK: - Private UILabel font adjustment

extension CVCalendarDayView {
    private var textSize: CGSize {
        guard let label = dayLabel, text = label.text else {
            return .zero
        }
        
        return NSString(string: text).sizeWithAttributes([ NSFontAttributeName : label.font ])
    }
    
    private var auxiliaryViewSize: CGSize {
        if let selectionView = selectionView {
            return selectionView.frame.size
        } else {
            return CVAuxiliaryView(dayView: self, rect: dayLabel.frame, shape: .Circle).frame.size
        }
    }
    
    public func adjustLabelFontSize() {
        let size = auxiliaryViewSize
        
        if max(textSize.width, textSize.height) * 3 > max(size.width, size.height) {
            dayLabel.font--
            adjustLabelFontSize()
        }
    }
}

// MARK: - Drawable 

extension CVCalendarDayView {
    // TODO: Make this widget customizable
    public func drawTopMarker() {
        let context = UIGraphicsGetCurrentContext()
        let height = UIScreen.mainScreen().scale
        
        if let delegate = self.calendarView.delegate {
            if let shouldDisplay = delegate.topMarker?(shouldDisplayOnDayView: self) where shouldDisplay {
                CGContextSetBlendMode(context, .Clear)
            }
        } else if hidden {
            CGContextSetBlendMode(context, .Clear)
        }
        
        UIColor.orangeColor().set()
        CGContextSaveGState(context)
        CGContextFillRect(context, CGRectMake(0, 1, bounds.width, height))
        CGContextRestoreGState(context)
    }
}

extension CVCalendarDayView {
    public func addConstraints() {
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel
            .constraint(.Leading, relation: .Equal, toView: self, constant: 0)
            .constraint(.Trailing, relation: .Equal, toView: self, constant: 0)
            .constraint(.Bottom, relation: .Equal, toView: self, constant: -(complementaryView?.frame.height ?? 0))
            .constraint(.Top, relation: .Equal, toView: self, constant: 0)
        
        selectionView?.translatesAutoresizingMaskIntoConstraints = false
        selectionView?
            .constraint(.Bottom, relation: .Equal, toView: self, constant: -(complementaryView?.frame.height ?? 0))
            .constraint(.Top, relation: .Equal, toView: self, constant: 0)
            .constraint(.Leading, relation: .Equal, toView: self, constant: 0)
            .constraint(.Trailing, relation: .Equal, toView: self, constant: 0)
        
        if let complementaryView = complementaryView {
            complementaryView.translatesAutoresizingMaskIntoConstraints = false 
            complementaryView
                .constraint(.Bottom, relation: .Equal, toView: self, constant: 0)
                .constraint(.Height, relation: .Equal, constant: complementaryView.frame.height)
                .constraint(.Width, relation: .Equal, constant: complementaryView.frame.width)
                .constraint(.CenterX, relation: .Equal, toView: self, constant: 0)
        }
        
        // TODO: Supplementary & Prelimitary views' constraints
        
    }
}

// MARK: - Subviews setup

extension CVCalendarDayView {
    public func labelSetup() {
        let appearance = calendarView.appearance
        
        if dayLabel == nil {
            dayLabel = UILabel()
        }
        
        dayLabel!.text = String(date.day)
        dayLabel!.textAlignment = NSTextAlignment.Center
        dayLabel!.frame = bounds

        //complementarySetup()
        
        var font = appearance.dayLabelWeekdayFont
        var color: UIColor?
        
        if isOut {
            color = appearance.dayLabelWeekdayOutTextColor
        } else if isCurrentDay {
            let coordinator = calendarView.coordinator
            if coordinator.selectedDayView == nil && calendarView.shouldAutoSelectDayOnMonthChange {
                print("Selected")
                let touchController = calendarView.touchController
                touchController.receiveTouchOnDayView(self)
                calendarView.didSelectDayView(self)
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
        
        if dayLabel.superview == nil {
            addSubview(dayLabel!)
        }
        
//        if let bottom = self.constraintForAttribute(.Bottom) {
//            bottomConstraint = bottom
//        }
    }
    
    public func complementarySetup() {
        guard let complementaryView = calendarView.delegate?.complementaryView?(onDayView: self) else {
            return
        }
        
//        if let bottom = constraints.filter({ $0.firstAttribute == .Bottom }).first {
//            bottom.constant = -complementaryView.frame.height
//            layoutIfNeeded()
//        }
        //bottomConstraint.constant = complementaryView.frame.height
        dayLabel?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - complementaryView.bounds.height)
        
        self.complementaryView?.removeFromSuperview()
        self.complementaryView = complementaryView
        
        complementaryView.backgroundColor = UIColor.orangeColor()
        complementaryView.frame.origin = CGPoint(x: 0, y: dayLabel.frame.height)
        complementaryView.center.x = bounds.mid.x
        
        addSubview(complementaryView)
    }

    public func preliminarySetup() {
        if let delegate = calendarView.delegate, shouldShow = delegate.preliminaryView?(shouldDisplayOnDayView: self) where shouldShow {
            if let preView = delegate.preliminaryView?(viewOnDayView: self) {
                prelimitaryView = preView
                
                //dayLabel.insertSubview(preView, atIndex: 0)
                preView.layer.zPosition = CGFloat(-MAXFLOAT)
            }
        }
    }
    
    public func supplementarySetup() {
        if let delegate = calendarView.delegate, shouldShow = delegate.supplementaryView?(shouldDisplayOnDayView: self) where shouldShow {
            if let supView = delegate.supplementaryView?(viewOnDayView: self) {
                supplementaryView = supView
                
                //insertSubview(supView, atIndex: 0)
            }
        }
    }
    
    /// Deprecated since 2.0. 
    /// Use `drawTopMarker()` function to draw 
    /// a top marker.
    public func topMarkerSetup() {
        safeExecuteBlock({
            func createMarker() {
                let height = CGFloat(0.5)
                let layer = CALayer()
                layer.borderColor = UIColor.grayColor().CGColor
                layer.borderWidth = height
                layer.frame = CGRectMake(0, 1, CGRectGetWidth(self.frame), height)
                
                self.topMarker = layer
                self.layer.addSublayer(self.topMarker!)
            }
            
            if let delegate = self.calendarView.delegate {
                if self.topMarker != nil {
                    self.topMarker?.removeFromSuperlayer()
                    self.topMarker = nil
                }
                
                if let shouldDisplay = delegate.topMarker?(shouldDisplayOnDayView: self) where shouldDisplay {
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
            }, collapsingOnNil: false, withObjects: weekView, weekView.monthView, weekView.monthView)
    }
    
    public func setupDotMarker() {
        for (index, dotMarker) in dotMarkers.enumerate() {
            dotMarker?.removeFromSuperview()
            dotMarkers[index] = nil
        }
        
        if let delegate = calendarView.delegate {
            if let shouldShow = delegate.dotMarker?(shouldShowOnDayView: self) where shouldShow {
                
                var (width, height): (CGFloat, CGFloat) = (13, 13)
                if let size = delegate.dotMarker?(sizeOnDayView: self) {
                    (width, height) = (size,size)
                }
                let colors = isOut ? [.grayColor()] : delegate.dotMarker?(colorOnDayView: self)
                var yOffset = bounds.height / 5
                if let y = delegate.dotMarker?(moveOffsetOnDayView: self) {
                    yOffset = y
                }
                let y = CGRectGetMidY(frame) + yOffset
                let markerFrame = CGRectMake(0, 0, width, height)
                
                if (colors!.count > 3) {
                    assert(false, "Only 3 dot markers allowed per day")
                }
                
                for (index, color) in (colors!).enumerate() {
                    var x: CGFloat = 0
                    switch(colors!.count) {
                    case 1:
                        x = frame.width / 2
                    case 2:
                        x = frame.width * CGFloat(2+index)/5.00 // frame.width * (2/5, 3/5)
                    case 3:
                        x = frame.width * CGFloat(2+index)/6.00 // frame.width * (1/3, 1/2, 2/3)
                    default:
                        break
                    }
                    
                    let dotMarker = CVAuxiliaryView(dayView: self, rect: markerFrame, shape: .Circle)
                    dotMarker.fillColor = color
                    dotMarker.center = CGPointMake(x, y)
                    insertSubview(dotMarker, atIndex: 0)
                    
                    dotMarker.setNeedsDisplay()
                    dotMarkers.append(dotMarker)
                }
                
                let coordinator = calendarView.coordinator
                if self == coordinator.selectedDayView {
                    moveDotMarkerBack(false, coloring: false)
                }
            }
        }
    }
}

// MARK: - Dot marker movement

extension CVCalendarDayView {
    public func moveDotMarkerBack(unwinded: Bool, var coloring: Bool) {
        for dotMarker in dotMarkers {

            if let calendarView = calendarView, let dotMarker = dotMarker {
                var shouldMove = true
                if let delegate = calendarView.delegate, let move = delegate.dotMarker?(shouldMoveOnHighlightingOnDayView: self) where !move {
                    shouldMove = move
                }
                
                func colorMarker() {
                    if let delegate = calendarView.delegate {
                        let appearance = calendarView.appearance
                        var color: UIColor?
                        if unwinded {
                            if let myColor = delegate.dotMarker?(colorOnDayView: self) {
                                color = (isOut) ? appearance.dayLabelWeekdayOutTextColor : myColor.first
                            }
                        } else {
                            color = appearance.dotMarkerColor
                        }
                        
                        dotMarker.fillColor = color
                        dotMarker.setNeedsDisplay()
                    }
                    
                }
                
                func moveMarker() {
                    var transform: CGAffineTransform!
                    if let selectionView = selectionView {
                        let point = pointAtAngle(CGFloat(-90).toRadians(), withinCircleView: selectionView)
                        let spaceBetweenDotAndCircle = CGFloat(1)
                        let offset = point.y - dotMarker.frame.origin.y - dotMarker.bounds.height/2 + spaceBetweenDotAndCircle
                        transform = unwinded ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, offset)
                        
                        if dotMarker.center.y + offset > CGRectGetMaxY(frame) {
                            coloring = true
                        }
                    } else {
                        transform = CGAffineTransformIdentity
                    }
                    
                    if !coloring {
                        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                            dotMarker.transform = transform
                            }, completion: { _ in
                                
                        })
                    } else {
                        moveDotMarkerBack(unwinded, coloring: coloring)
                    }
                }
                
                if shouldMove && !coloring {
                    moveMarker()
                } else {
                    colorMarker()
                }
            }
        }
    }
}


// MARK: - Circle geometry

extension CGFloat {
    public func toRadians() -> CGFloat {
        return CGFloat(self) * CGFloat(M_PI / 180)
    }
    
    public func toDegrees() -> CGFloat {
        return CGFloat(180/M_PI) * self
    }
}

extension CVCalendarDayView {
    public func pointAtAngle(angle: CGFloat, withinCircleView circleView: UIView) -> CGPoint {
        let radius = circleView.bounds.width / 2
        let xDistance = radius * cos(angle)
        let yDistance = radius * sin(angle)
        
        let center = circleView.center
        let x = floor(cos(angle)) < 0 ? center.x - xDistance : center.x + xDistance
        let y = center.y - yDistance
        
        let result = CGPointMake(x, y)
        
        return result
    }
    
    public func moveView(view: UIView, onCircleView circleView: UIView, fromAngle angle: CGFloat, toAngle endAngle: CGFloat, straight: Bool) {
//        let condition = angle > endAngle ? angle > endAngle : angle < endAngle
        if straight && angle < endAngle || !straight && angle > endAngle {
            UIView.animateWithDuration(pow(10, -1000), delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                let angle = angle.toRadians()
                view.center = self.pointAtAngle(angle, withinCircleView: circleView)
                }) { _ in
                    let speed = CGFloat(750).toRadians()
                    let newAngle = straight ? angle + speed : angle - speed
                    self.moveView(view, onCircleView: circleView, fromAngle: newAngle, toAngle: endAngle, straight: straight)
            }
        }
    }
}

// MARK: - Day label state management

extension CVCalendarDayView {
    public func setSelectedWithType(type: SelectionType) {
        let appearance = calendarView.appearance
        var backgroundColor: UIColor!
        var backgroundAlpha: CGFloat!
        var (textColor, font): (UIColor!, UIFont!)
        var shape: CVShape!
        
        
        switch type {
        case .Single:
            shape = .Circle
            
            if let delegate = calendarView.delegate, shouldShowCustomSelection = delegate.shouldShowCustomSingleSelection?() where shouldShowCustomSelection {
                if let block = delegate.selectionViewPath?() {
                    shape = .Custom(block)
                }
            }
            
            if isCurrentDay {
                textColor = appearance.dayLabelPresentWeekdaySelectedTextColor!
                font = appearance.dayLabelPresentWeekdaySelectedFont
                backgroundColor = appearance.dayLabelPresentWeekdaySelectedBackgroundColor
                backgroundAlpha = appearance.dayLabelPresentWeekdaySelectedBackgroundAlpha
            } else {
                textColor = appearance.dayLabelWeekdaySelectedTextColor
                font = appearance.dayLabelWeekdaySelectedFont
                backgroundColor = appearance.dayLabelWeekdaySelectedBackgroundColor
                backgroundAlpha = appearance.dayLabelWeekdaySelectedBackgroundAlpha
            }
            
        case .Range:
            shape = .Rect
            if isCurrentDay {
                textColor = appearance.dayLabelPresentWeekdayHighlightedTextColor!
                font = appearance.dayLabelPresentWeekdayHighlightedFont
                backgroundColor = appearance.dayLabelPresentWeekdayHighlightedBackgroundColor
                backgroundAlpha = appearance.dayLabelPresentWeekdayHighlightedBackgroundAlpha
            } else {
                textColor = appearance.dayLabelWeekdayHighlightedTextColor
                font = appearance.dayLabelWeekdayHighlightedFont
                backgroundColor = appearance.dayLabelWeekdayHighlightedBackgroundColor
                backgroundAlpha = appearance.dayLabelWeekdayHighlightedBackgroundAlpha
            }
        }
        // TODO: Get back here
        
        if let selectionView = selectionView where selectionView.frame != dayLabel.bounds {
            selectionView.frame = dayLabel.bounds
        } else {
            selectionView = CVAuxiliaryView(dayView: self, rect: dayLabel.bounds, shape: shape)
        }
        
        dayLabel.textColor = textColor
        dayLabel.font = font
        
        selectionView!.fillColor = backgroundColor
        selectionView!.alpha = backgroundAlpha
        selectionView!.setNeedsDisplay()
        selectionView!.layer.zPosition = CGFloat(-MAXFLOAT)
        
        insertSubview(selectionView!, atIndex: 0)
        
        moveDotMarkerBack(false, coloring: false)
    }
    
    public func setDeselectedWithClearing(clearing: Bool) {
        if let calendarView = calendarView, let appearance = calendarView.appearance {
            var color: UIColor?
            if isOut {
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
            
            dayLabel?.textColor = color
            dayLabel?.font = font
            
            moveDotMarkerBack(true, coloring: false)
            adjustLabelFontSize()
            
            if clearing {
                selectionView?.removeFromSuperview()
            }
        }
    }
}


// MARK: - Content reload

extension CVCalendarDayView {
    public func reloadContent() {
        setupDotMarker()
        labelSetup()
        complementarySetup()
        
        let shouldShowDaysOut = calendarView.shouldShowWeekdaysOut!
        if !shouldShowDaysOut {
            if isOut {
                hidden = true
            }
        } else {
            if isOut {
                hidden = false
            }
        }
        
        if selectionView != nil {
            setSelectedWithType(.Single)
        }
        
        adjustLabelFontSize()
    }
}

// MARK: - Safe execution

extension CVCalendarDayView {
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