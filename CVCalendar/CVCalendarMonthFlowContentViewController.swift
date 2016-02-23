//
//  CVCalendarMonthFlowContentViewController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 2/23/16.
//  Copyright © 2016 GameApp. All rights reserved.
//

import UIKit


public final class CVCalendarMonthFlowContentViewControllerDataSource: NSObject, UICollectionViewDataSource {
    
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
        
        cell.backgroundColor = UIColor.magentaColor()
        
        return cell
    }
}

public final class CVCalendarMonthFlowContentViewControllerDelegate: NSObject, UICollectionViewDelegate {
    
}

public class CVCalendarMonthFlowContentViewController: CVCalendarContentViewControllerImpl<UICollectionView> {
    
    private let dataSource = CVCalendarMonthFlowContentViewControllerDataSource()
    private let delegate = CVCalendarMonthFlowContentViewControllerDelegate()
    
    public override init(calendarView: CVCalendarView, frame: CGRect) {
        super.init(calendarView: calendarView, frame: frame)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: 150)
        layout.minimumLineSpacing = 2
        
        contentView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.lightGrayColor()
        
        contentView.showsVerticalScrollIndicator = false
        
        contentView.dataSource = dataSource
        contentView.delegate = delegate
        
        contentView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")

        if let superview = contentView.superview {
            addConstraints(superview)
        }
    }
    
    public init(calendarView: CalendarView, frame: CGRect, presentedDate: NSDate) {
        super.init(calendarView: calendarView, frame: frame)
    }
    
    private func addConstraints(view: UIView) {
        view.addConstraints([
            NSLayoutConstraint(item: contentView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        ])
    }
    
}
