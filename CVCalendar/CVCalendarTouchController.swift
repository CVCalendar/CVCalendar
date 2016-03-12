//
//  CVCalendarTouchController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 17/03/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarTouchController {
    private unowned let calendarView: CalendarView
    
    // MARK: - Properties
    public var coordinator: Coordinator {
        return calendarView.coordinator
    }
    
    /// Init.
    public init(calendarView: CalendarView) {
        self.calendarView = calendarView
    }
}

// MARK: - Events receive 

extension CVCalendarTouchController {
    public func receiveTouchLocation(location: CGPoint, inMonthView monthView: CVCalendarMonthView, withSelectionType selectionType: CVSelectionType) {
//        let weekViews = monthView.weekViews
        if let dayView = ownerTouchLocation(location, onMonthView: monthView) where dayView.userInteractionEnabled {
            receiveTouchOnDayView(dayView, withSelectionType: selectionType)
        }
    }
    
    public func receiveTouchLocation(location: CGPoint, inWeekView weekView: CVCalendarWeekView, withSelectionType selectionType: CVSelectionType) {
//        let monthView = weekView.monthView
//        let index = weekView.index
//        let weekViews = monthView.weekViews
        
        if let dayView = ownerTouchLocation(location, onWeekView: weekView) where dayView.userInteractionEnabled {
            receiveTouchOnDayView(dayView, withSelectionType: selectionType)
        }
    }
    
    public func receiveTouchOnDayView(dayView: CVCalendarDayView) {
        coordinator.performDayViewSingleSelection(dayView)
    }
}

// MARK: - Events management 

private extension CVCalendarTouchController {
    func receiveTouchOnDayView(dayView: CVCalendarDayView, withSelectionType selectionType: CVSelectionType) {
        if let calendarView = dayView.calendarView {
            switch selectionType {
            case .Single:
                print("Single selection")
                coordinator.performDayViewSingleSelection(dayView)
                calendarView.didSelectDayView(dayView)
                
            case .Range(.Started):
                print("Received start of range selection.")
            case .Range(.Changed):
                print("Received change of range selection.")
            case .Range(.Ended):
                print("Received end of range selection.")
            }
        }
    }

    func monthViewLocation(location: CGPoint, doesBelongToCell cell: DayViewCell) -> Bool {
        return cell.frame.contains(location)
    }
    
    func weekViewLocation(location: CGPoint, doesBelongToDayView dayView: CVCalendarDayView) -> Bool {
        let dayViewFrame = dayView.frame
        if location.x >= dayViewFrame.origin.x && location.x <= CGRectGetMaxX(dayViewFrame) && location.y >= dayViewFrame.origin.y && location.y <= CGRectGetMaxY(dayViewFrame) {
            return true
        } else {
            return false
        }
    }
    
    func ownerTouchLocation(location: CGPoint, onMonthView monthView: CVCalendarMonthView) -> DayView? {
        var owner: DayView?

        for cell in monthView.collectionView.visibleCells() as! [DayViewCell] {
            if self.monthViewLocation(location, doesBelongToCell: cell) {
                owner = cell.dayView
                return owner
            }
        }

        return owner
    }
    
    func ownerTouchLocation(location: CGPoint, onWeekView weekView: CVCalendarWeekView) -> DayView? {
        var owner: DayView?
        let dayViews = weekView.dayViews
        for dayView in dayViews {
            if weekViewLocation(location, doesBelongToDayView: dayView) {
                owner = dayView
                return owner
            }
        }
        
        return owner
    }
}