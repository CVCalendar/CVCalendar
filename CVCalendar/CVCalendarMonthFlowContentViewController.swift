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
        if label != nil {
            label.removeFromSuperview()
        }
        
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
    
    public var count = 0
    public var dates: [NSDate] = []
    public var monthViews: [NSIndexPath : CVCalendarMonthView] = [:]
    
    public func getMonth(date: NSDate) -> MonthView {
        let frame = controller.contentView.bounds
        let monthView = MonthView(calendarView: controller.calendarView, date: date)
        
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return count
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        
        let monthView: CVCalendarMonthView
        if let _monthView = monthViews[indexPath] {
            monthView = _monthView
        } else {
            monthView = getMonth(dates[indexPath.section])
            monthViews[indexPath] = monthView
        }
        
        //print("Date \(monthView.date)")
        
        //cell.backgroundColor = UIColor.magentaColor()
        for subview in cell.subviews {
            subview.removeFromSuperview()
        }
        
        monthView.mapDayViews { dayView in
            dayView
            if dayView.isOut {
                dayView.topMarkerHidden = true
                dayView.hidden = true
            }
        }
        
        cell.userInteractionEnabled = true
        monthView.userInteractionEnabled = true
        cell.setNeedsDisplay()
        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        print("Cell")
        
        for subview in cell.subviews {
            subview.removeFromSuperview()
        }
        
        if let monthView = monthViews[indexPath] {
            print("Op")
            

            
            collectionView.performBatchUpdates({
                collectionView.reloadItemsAtIndexPaths([indexPath])
            }, completion: nil)

            monthView.frame = cell.bounds
            cell.addSubview(monthView)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let monthView = monthViews[indexPath] else {
            return .zero
        }
        
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
            guard let monthView = monthViews[indexPath] else {
                return _header
            }
            
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
        return CGSize(width: collectionView.frame.width, height: 1)
    }
    
}

public final class CVCalendarMonthFlowContentViewControllerDelegate: NSObject, UICollectionViewDelegate {
    
}

public final class CVCalendarMonthFlowContentViewController: CVCalendarContentViewControllerImpl<UICollectionView> {
    
    public var startDate: NSDate = NSDate().year == 2007
    public var endDate: NSDate = NSDate().year + 1
    
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
        let leftRange = (NSDate().year.value() - startDate.year.value())
        let leftCount = leftRange == 0 ? 1 : leftRange
        
        let dates = (1..<leftCount * 12).map { self.startDate.month + $0 }
        
        dataSource.dates = dates
        dataSource.count = dataSource.dates.count
        
//        dataSource.monthViews = [
//            NSIndexPath(forRow: 0, inSection: 0) : presentedMonthView,
//            NSIndexPath(forRow: 0, inSection: 1) : getFollowingMonth(NSDate()),
//            NSIndexPath(forRow: 0, inSection: 2) : getFollowingMonth(NSDate().month + 1)
//        ]
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
        
        if #available(iOS 9.0, *) {
            (contentView.collectionViewLayout as! UICollectionViewFlowLayout).sectionHeadersPinToVisibleBounds = true
            (contentView.collectionViewLayout as! UICollectionViewFlowLayout).sectionFootersPinToVisibleBounds = true
        } else {
            // Fallback on earlier versions
        }
        
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
        
        for (_, monthView) in dataSource.monthViews {
            monthView.updateAppearance(rect != .zero ? rect : contentView.bounds)
        }
        
        let todayIndex = NSIndexPath(forRow: 0, inSection: dataSource.count - 1)
        
        contentView.performBatchUpdates({
            self.contentView.scrollToItemAtIndexPath(todayIndex, atScrollPosition: .Bottom, animated: false)
            self.contentView.reloadData()
        }, completion: nil)


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
    
    public func getMonth(date: NSDate) -> MonthView {
        let frame = contentView.bounds
        let monthView = MonthView(calendarView: calendarView, date: date)
        
        monthView.updateAppearance(frame)
        
        return monthView
    }
}
