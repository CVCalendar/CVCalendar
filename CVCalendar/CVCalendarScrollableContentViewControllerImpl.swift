//
//  CVCalendarScrollableContentViewControllerImpl.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 2/23/16.
//  Copyright © 2016 GameApp. All rights reserved.
//

import UIKit

public class CVCalendarScrollableContentViewControllerImpl<T : UIScrollView>: CVCalendarContentViewControllerImpl<T>, CVCalendarScrollableContentViewController {
    public var presentedMonthView: MonthView
    
    public var bounds: CGRect {
        return contentView.bounds
    }
    
    public var currentPage = 1
    public var pageChanged: Bool {
        return currentPage == 1 ? false : true
    }
    
    public var pageLoadingEnabled = true
    public var presentationEnabled = true
    public var lastContentOffset: CGFloat = 0
    public var direction: CVScrollDirection = .None
    
    public override init(calendarView: CalendarView, frame: CGRect) {
        presentedMonthView = MonthView(calendarView: calendarView, date: NSDate())
        presentedMonthView.updateAppearance(frame)
        
        super.init(calendarView: calendarView, frame: frame)
        
        contentView.contentSize = CGSizeMake(frame.width * 3, frame.height)
        contentView.showsHorizontalScrollIndicator = false
        contentView.showsVerticalScrollIndicator = false
        contentView.layer.masksToBounds = true
        contentView.pagingEnabled = true
    }
}