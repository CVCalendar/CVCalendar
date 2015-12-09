//
//  CVShape.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 23/03/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

public enum CVShape {
    case LeftFlag
    case RightFlag
    case Circle
    case Rect
    case Custom((CGRect) -> (UIBezierPath))
}
