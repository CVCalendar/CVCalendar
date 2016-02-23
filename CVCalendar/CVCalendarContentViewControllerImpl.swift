//
//  CVCalendarContentViewControllerImpl.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 2/23/16.
//  Copyright © 2016 GameApp. All rights reserved.
//

import UIKit

public class CVCalendarContentViewControllerImpl<T: UIView>: NSObject, CVCalendarContentViewController, CVCalendarViewRefresher, CVCalendarViewDateManager, CVCalendarViewLayoutManager {
    public var calendarView: CalendarView
    public var contentView: T
    
    public init(calendarView: CalendarView, frame: CGRect) {
        self.calendarView = calendarView
        
        // TODO: Swizzle init method in CVCalendarMonthFlowContentViewController
        if T.self == UICollectionView.self {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: 150)
            layout.minimumLineSpacing = 2
            
            contentView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout) as! T
        } else {
            contentView = T(frame: frame)
        }
        
        
        super.init()
    }
}