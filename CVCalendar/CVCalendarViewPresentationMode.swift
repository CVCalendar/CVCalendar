//
//  CVCalendarViewPresentationMode.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 15/04/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

@objc public enum CVCalendarViewPresentationMode: Int {
    case MonthView
    case WeekView
    case MonthFlowView
    
    public var description: String {
        switch self {
        case .MonthView: return "MonthView"
        case .WeekView: return "WeekView"
        case .MonthFlowView: return "MonthFlowView"
        }
    }
}