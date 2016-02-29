//
//  CVCalendarMonthFlowContentViewController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 2/23/16.
//  Copyright © 2016 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarMonthFlowContentViewControllerDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public weak var controller: CVCalendarMonthFlowContentViewController!
    
    public var monthViews: [CVCalendarMonthView] = []
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthViews.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        let monthView = monthViews[indexPath.row]
        
        print("Date \(monthView.date)")
        
        cell.backgroundColor = UIColor.magentaColor()
        cell.addSubview(monthView)
        
        monthView.mapDayViews { dayView in
            if dayView.isOut {
                dayView.hidden = true
            }
        }
        
//        cell.addConstraints([
//            NSLayoutConstraint(item: monthView, attribute: .Leading, relatedBy: .Equal, toItem: cell, attribute: .Leading, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: monthView, attribute: .Trailing, relatedBy: .Equal, toItem: cell, attribute: .Trailing, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: monthView, attribute: .Bottom, relatedBy: .Equal, toItem: cell, attribute: .Bottom, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: monthView, attribute: .Top, relatedBy: .Equal, toItem: cell, attribute: .Top, multiplier: 1, constant: 0)
//        ])
        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let monthView = monthViews[indexPath.row]
        let size = controller.calendarView.weekViewSize!
        
        return CGSize(width: size.width, height: size.height * CGFloat(monthView.weekViews.count))
    }
    
}

public final class CVCalendarMonthFlowContentViewControllerDelegate: NSObject, UICollectionViewDelegate {
    
}

public final class CVCalendarMonthFlowContentViewController: CVCalendarContentViewControllerImpl<UICollectionView> {
    
    private let dataSource = CVCalendarMonthFlowContentViewControllerDataSource()
    private let delegate = CVCalendarMonthFlowContentViewControllerDelegate()
    
    private var presentedMonthView: MonthView!
    
    public override init(calendarView: CVCalendarView, frame: CGRect) {
        super.init(calendarView: calendarView, frame: frame)
        
        presentedMonthView = MonthView(calendarView: calendarView, date: NSDate())
        presentedMonthView.updateAppearance(contentView.bounds)
        initialLoad(NSDate())
        
        setup()
        loadMonthData()
    }
    
    public init(calendarView: CalendarView, frame: CGRect, presentedDate: NSDate) {
        super.init(calendarView: calendarView, frame: frame)
        
        presentedMonthView = MonthView(calendarView: calendarView, date: presentedDate)
        presentedMonthView.updateAppearance(contentView.bounds)
        initialLoad(presentedDate)
        
        setup()
        loadMonthData()
    }
    
    private func initialLoad(date: NSDate) {
        presentedMonthView.mapDayViews { dayView in
            if self.calendarView.shouldAutoSelectDayOnMonthChange && self.matchedDays(dayView.date, Date(date: date)) {
                self.calendarView.coordinator.flush()
                self.calendarView.touchController.receiveTouchOnDayView(dayView)
                dayView.selectionView?.removeFromSuperview()
            }
        }
        
        calendarView.presentedDate = CVDate(date: presentedMonthView.date)
    }
    
    private func loadMonthData() {
        dataSource.monthViews = [presentedMonthView] + [getFollowingMonth(NSDate())] + [getFollowingMonth(NSDate().month + 1)]
    }
    
    private func setup() {
        dataSource.controller = self
        
        //contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.userInteractionEnabled = true
        contentView.alwaysBounceVertical = true
        contentView.backgroundColor = UIColor.lightGrayColor()
        contentView.showsVerticalScrollIndicator = false
        contentView.dataSource = dataSource
        contentView.delegate = dataSource
        contentView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        if let superview = contentView.superview {
            addConstraints(superview)
        }
    }
    
    private func addConstraints(view: UIView) {
        view.addConstraints([
            NSLayoutConstraint(item: contentView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        ])
    }
    
    public func updateFrames(rect: CGRect) {
        super.updateFrames(rect)
        print("Update frames")
        
        (contentView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.height = calendarView.weekViewSize!.height * 7
        
        for monthView in dataSource.monthViews {
            monthView.reloadViewsWithRect(rect != .zero ? rect : contentView.bounds)
        }
        
        contentView.reloadData()
    }
    
}


// MARK: - Month management

extension CVCalendarMonthFlowContentViewController {
    public func getFollowingMonth(date: NSDate) -> MonthView {
        let newDate = (date.day == 1).month + 1
        let frame = contentView.bounds
        let monthView = MonthView(calendarView: calendarView, date: newDate)
        
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    public func getPreviousMonth(date: NSDate) -> MonthView {
        let newDate = (date.day == 1).month - 1
        let frame = contentView.bounds
        let monthView = MonthView(calendarView: calendarView, date: newDate)
        
        monthView.updateAppearance(frame)
        
        return monthView
    }
}
