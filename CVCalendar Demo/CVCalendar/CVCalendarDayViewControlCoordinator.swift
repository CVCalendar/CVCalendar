//
//  CVCalendarDayViewControlCoordinator.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

/// Singleton
private let instance = CVCalendarDayViewControlCoordinator()

// MARK: - Type work 

typealias DayView = CVCalendarDayView
typealias Appearance = CVCalendarViewAppearance
typealias Coordinator = CVCalendarCoordinator

/// Coordinator's control actions
protocol CVCalendarCoordinator {
    func performDayViewSingleSelection(dayView: DayView)
    func performDayViewRangeSelection(dayView: DayView)
}

class CVCalendarDayViewControlCoordinator: NSObject {
    var inOrderNumber = 0
    
    class var sharedControlCoordinator: CVCalendarDayViewControlCoordinator {
        return instance
    }
   
    var selectedDayView: CVCalendarDayView?
    var animator: CVCalendarViewAnimatorDelegate?
    
    lazy var appearance: Appearance = {
       return Appearance.sharedCalendarViewAppearance
    }()
    
    private override init() {
        super.init()
    }
    
    private func presentSelectionOnDayView(dayView: DayView) {
        animator?.animateSelection(dayView, withControlCoordinator: self)
    }
    
    private func presentDeselectionOnDayView(dayView: DayView) {
        animator?.animateDeselection(dayView, withControlCoordinator: self)
    }
    
    func selectionPerformedOnDayView() {
        
    }
    
    func deselectionPerformedOnDayView(dayView: DayView) {
        selectionSet.removeObject(dayView)
    }
    
    var selectionSet = Set<DayView>()
}

// MARK: - CVCalendarCoordinator

extension CVCalendarDayViewControlCoordinator: Coordinator {
    func performDayViewSingleSelection(dayView: DayView) {
        selectionSet.addObject(dayView)
        println(selectionSet.count)
        
        if selectionSet.count > 1 {
            let count = selectionSet.count-1
            for dayViewInQueue in selectionSet {
                if dayView != dayViewInQueue {
                    presentDeselectionOnDayView(dayViewInQueue)
                    
                }
                
            }
        }
        
        if let animator = animator {
            if selectedDayView != dayView {
                selectedDayView = dayView
                presentSelectionOnDayView(dayView)
            }
        } else {
            animator = dayView.calendarView.animator!
        }
    }
    
    func performDayViewRangeSelection(dayView: DayView) {
        println("Day view range selection found")
    }
}

struct Set<T: AnyObject>: SequenceType, NilLiteralConvertible {
    private var storage = [T]()
    
    subscript(index: Int) -> T? {
        get {
            if index < storage.count {
                return storage[index]
            } else {
                return nil
            }
        }
        
        set {
            if let value = newValue {
                addObject(value)
            }
        }
    }
    
    mutating func addObject(object: T) {
        if indexObject(object) == nil {
            storage.append(object)
        }
    }
    
    mutating func removeObject(object: T) {
        if let index = indexObject(object) {
            storage.removeAtIndex(index)
        }
    }
    
    var count: Int {
        return storage.count
    }
    
    var last: T? {
        return storage.last
    }
    
    private func indexObject(object: T) -> Int? {
        for (index, storageObj) in enumerate(storage) {
            if storageObj === object {
                return index
            }
        }
        
        return nil
    }
    
    
    func generate() -> GeneratorOf<T> {
        var power = 0
        var nextClosure : () -> T? = {
            (power < self.count) ? self.storage[power++] : nil
        }
        return GeneratorOf<T>(nextClosure)
    }
    
    init(nilLiteral: ()) {
        
    }
    
    init() {
        
    }
}


