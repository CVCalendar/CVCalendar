//
//  CVCalendarMonthView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarMonthView: UIView {
    // MARK: - Non public properties
    private var interactiveView: UIView!
    
    public override var frame: CGRect {
        didSet {
            if let calendarView = calendarView {
                if calendarView.calendarMode == CalendarMode.MonthView || calendarView.calendarMode == CalendarMode.MonthFlowView {
                    updateInteractiveView()
                }
            }
        }
    }
    
    private var touchController: CVCalendarTouchController {
        return calendarView.touchController
    }
    
    // MARK: - Public properties
    
    public weak var calendarView: CVCalendarView!
    public var date: NSDate!
    public var numberOfWeeks: Int!
    public var weekViews: [CVCalendarWeekView]!
    
    /// -------–-------–-------–-------–-------–
    /// Deprecated
    /// -------–-------–-------–-------–-------–
    
    //    public var weeksIn: [[Int : [Int]]]?
    //    public var weeksOut: [[Int : [Int]]]?
    
    /// -------–-------–-------–-------–-------–
    
    // Since v2.0.
    public var weekdays: [[Weekday : NSDate]]!
    
    public var currentDay: Int?
    
    public var potentialSize: CGSize {
        return CGSizeMake(bounds.width, CGFloat(weekViews.count) * weekViews[0].bounds.height + calendarView.appearance.spaceBetweenWeekViews! * CGFloat(weekViews.count))
    }
    
    public var collectionView: UICollectionView!
    public var dayViews: [NSIndexPath : CVCalendarDayView] = [:]
    
    // MARK: - Initialization
    
    public init(calendarView: CVCalendarView, date: NSDate) {
        super.init(frame: .zero)
        self.calendarView = calendarView
        self.date = date
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func mapDayViews(body: (DayView) -> Void) {
//        for weekView in self.weekViews {
//            for dayView in weekView.dayViews {
//                body(dayView)
//            }
//        }
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
}

// MARK: - Creation and destruction

extension CVCalendarMonthView {
    public func commonInit() {
        let calendarManager = calendarView.manager
        let range = calendarManager.monthDateRange(date)
        numberOfWeeks = range.numberOfWeeks
        currentDay = NSDate().day.value()
        weekdays = calendarManager.weekdaysForDate(date)
        
        // CollectionView setup. 
        
        let layout = MonthViewFlowLayout()
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(DayViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        collectionView.backgroundColor = .clearColor()
        
        addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView
            .constraint(.Leading, relation: .Equal, toView: self, constant: 0)
            .constraint(.Trailing, relation: .Equal, toView: self, constant: 0)
            .constraint(.Bottom, relation: .Equal, toView: self, constant: 0)
            .constraint(.Top, relation: .Equal, toView: self, constant: 0)
    }
}

internal class DayViewCell: UICollectionViewCell {
    var dayView: CVCalendarDayView! {
        didSet {
            removeAllSubviews()
            addSubview(dayView)
            
            dayView
                .constraint(.Leading, relation: .Equal, toView: self, constant: 0)
                .constraint(.Trailing, relation: .Equal, toView: self, constant: 0)
                .constraint(.Bottom, relation: .Equal, toView: self, constant: 0)
                .constraint(.Top, relation: .Equal, toView: self, constant: 0)
        }
    }
    
    
}

internal class MonthViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let _attributes = super.layoutAttributesForElementsInRect(rect)
        
        guard var attributes = _attributes else {
            return nil
        }
        
        for i in 1..<attributes.count {
            let currentAttr = attributes[i]
            let previousAttr = attributes[i - 1]
            let maxSpacing: CGFloat = 0
            
            let originX = CGRectGetMaxX(previousAttr.frame)
            
            if originX + maxSpacing + currentAttr.frame.width < collectionViewContentSize().width {
                currentAttr.frame.origin.x = originX + maxSpacing
            }

        }
        
        return attributes
    }
}

internal extension CVCalendarDayView {
    func setConstaintsForView(view: UIView) {
        //dayView.center = cell.bounds.mid
        //dayView.frame.size = cell.bounds.size
        translatesAutoresizingMaskIntoConstraints = false
        self
            .constraint(.Leading, relation: .Equal, toView: view, constant: 0)
            .constraint(.Trailing, relation: .Equal, toView: view, constant: 0)
            .constraint(.Bottom, relation: .Equal, toView: view, constant: 0)
            .constraint(.Top, relation: .Equal, toView: view, constant: 0)
    }
}

extension CVCalendarMonthView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7 * calendarView.manager.monthDateRange(date).numberOfWeeks
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! DayViewCell
        
        if indexPath.row == 0 {
            cell.backgroundColor = UIColor.orangeColor()
        } else {
            cell.backgroundColor = UIColor.redColor()
        }
        
        if let dayView = dayViews[indexPath] {
            cell.dayView = dayView
            dayView.setConstaintsForView(cell)
        } else {
            let weekData = weekdays[indexPath.row / 7]
            let date = weekData[Weekday(rawValue: indexPath.row % 7 + 1)!]!
            let dayView = CVCalendarDayView(calendarView: calendarView, date: CVDate(day: date.day.value(), month: date.month.value(), week: indexPath.row / 7, year: date.year.value()))
            
            dayViews[indexPath] = dayView
            
            cell.dayView = dayView
            
            dayView.setConstaintsForView(cell)
            dayView.weekIndex = indexPath.row / 7
            
            print("Date = \(date), Current Date = \(self.date) isOut = \(self.date.month.value() != date.month.value())")
            
            if self.date.month.value() != date.month.value() {
                dayView.isOut = true
            }
        }
        
        cell.dayView?.backgroundColor = .clearColor()
        
        // TODO: Add autolayout to DayView !!!
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.width / 7, round(collectionView.frame.height / CGFloat(calendarView.manager.monthDateRange(date).numberOfWeeks)))
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
}

// MARK: Content reload

extension CVCalendarMonthView {
    public func reloadViewsWithRect(frame: CGRect) {
        self.frame = frame
        
        safeExecuteBlock({
            for (index, weekView) in self.weekViews.enumerate() {
                if let size = self.calendarView.weekViewSize {
                    weekView.frame = CGRectMake(0, size.height * CGFloat(index), size.width, size.height)
                    weekView.reloadDayViews()
                }
            }
        }, collapsingOnNil: true, withObjects: weekViews)
    }
}

// MARK: - Content fill & update

extension CVCalendarMonthView {
    public func updateAppearance(frame: CGRect) {
        self.frame = frame
//        collectionView.frame = bounds
//        collectionView.layoutSubviews()
//        collectionView.reloadData()
        
        //createWeekViews()
    }
    
    public func createWeekViews() {
        weekViews = [CVCalendarWeekView]()
        
        safeExecuteBlock({
            for i in 0..<self.numberOfWeeks! {
                let weekView = CVCalendarWeekView(monthView: self, index: i)
                
                self.safeExecuteBlock({
                    self.weekViews!.append(weekView)
                    }, collapsingOnNil: true, withObjects: self.weekViews)
                
                self.addSubview(weekView)
            }
            }, collapsingOnNil: true, withObjects: numberOfWeeks)
    }
}

// MARK: - Interactive view management & update

extension CVCalendarMonthView {
    public func updateInteractiveView() {
        safeExecuteBlock({
            print("Setting interactive view...")
            let mode = self.calendarView!.calendarMode!
            if mode == .MonthView || mode == .MonthFlowView {
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
            
            }, collapsingOnNil: false, withObjects: calendarView)
    }
    
    public func didPressInteractiveView(recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.locationInView(self.interactiveView)
        let state: UIGestureRecognizerState = recognizer.state
        
        print("PRESS")
        
        switch state {
        case .Began:
            touchController.receiveTouchLocation(location, inMonthView: self, withSelectionType: .Range(.Started))
        case .Changed:
            touchController.receiveTouchLocation(location, inMonthView: self, withSelectionType: .Range(.Changed))
        case .Ended:
            touchController.receiveTouchLocation(location, inMonthView: self, withSelectionType: .Range(.Ended))
            
        default: break
        }
    }
    
    public func didTouchInteractiveView(recognizer: UITapGestureRecognizer) {
        let location = recognizer.locationInView(self.interactiveView)
        touchController.receiveTouchLocation(location, inMonthView: self, withSelectionType: .Single)
    }
}

// MARK: - Safe execution

extension CVCalendarMonthView {
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