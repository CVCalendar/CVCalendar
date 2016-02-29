//
//  CVCalendarMonthFlowContentViewController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 2/23/16.
//  Copyright © 2016 GameApp. All rights reserved.
//

import UIKit

public final class CVCalendarMonthFlowContentHeaderView: UICollectionReusableView {
    public var label: UILabel!
    
    public override var frame: CGRect {
        didSet {
            guard label != nil else {
                return
            }
            
            label.frame = bounds
            label.center = bounds.mid
        }
    }
    
    public override func didMoveToSuperview() {
        label = UILabel(frame: bounds)
        label.center = bounds.mid
        label.textAlignment = .Center
        addSubview(label)
    }
}

public final class CVCalendarMonthFlowContentFooterView: UICollectionReusableView {
    
}

public final class CVCalendarMonthFlowContentViewControllerDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public weak var controller: CVCalendarMonthFlowContentViewController!
    
    public var monthViews: [CVCalendarMonthView] = []
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return monthViews.count
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        let monthView = monthViews[indexPath.section]
        
        print("Date \(monthView.date)")
        
        //cell.backgroundColor = UIColor.magentaColor()
        for subview in cell.subviews {
            subview.removeFromSuperview()
        }
        
        cell.addSubview(monthView)
        
        monthView.mapDayViews { dayView in
            dayView
            if dayView.isOut {
                dayView.topMarkerHidden = true
                dayView.hidden = true
            }
        }
        
//        cell.addConstraints([
//            NSLayoutConstraint(item: monthView, attribute: .Leading, relatedBy: .Equal, toItem: cell, attribute: .Leading, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: monthView, attribute: .Trailing, relatedBy: .Equal, toItem: cell, attribute: .Trailing, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: monthView, attribute: .Bottom, relatedBy: .Equal, toItem: cell, attribute: .Bottom, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: monthView, attribute: .Top, relatedBy: .Equal, toItem: cell, attribute: .Top, multiplier: 1, constant: 0)
//        ])
        
        cell.setNeedsDisplay()
        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let monthView = monthViews[indexPath.row]
        let size = controller.calendarView.weekViewSize!
        
        return CGSize(width: size.width, height: size.height * CGFloat(monthView.weekViews.count))
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let header: UICollectionReusableView
        
        if kind == UICollectionElementKindSectionHeader {
            let _header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! CVCalendarMonthFlowContentHeaderView
            let monthView = monthViews[indexPath.section]
            
            _header.label.text = CVDate(date: monthView.date).globalDescription
            _header.label.textColor = UIColor.whiteColor()
            header = _header
        } else {
            header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterView", forIndexPath: indexPath) as! CVCalendarMonthFlowContentFooterView
            header.hidden = true
        }

        //header.backgroundColor = UIColor.orangeColor()
        
        return header
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
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
        contentView.registerClass(CVCalendarMonthFlowContentHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        contentView.registerClass(CVCalendarMonthFlowContentFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterView")
        
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
