//
//  CVScrollDirection.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 12/04/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import Foundation

public enum CVScrollDirection {
    case none
    case right
    case left

    var description: String {
        get {
            switch self {
            case .left: return "Left"
            case .right: return "Right"
            case .none: return "None"
            }
        }
    }
}
