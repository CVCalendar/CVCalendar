//
//  CVScrollDirection.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 12/04/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import Foundation

public enum CVScrollDirection {
    case None
    case Right
    case Left
    
    var description: String {
        get {
            switch self {
            case .Left: return "Left"
            case .Right: return "Right"
            case .None: return "None"
            }
        }
    }
}