//
//  CVShape.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 23/03/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

public enum CVShape {
    case leftFlag
    case rightFlag
    case circle
    case rect
    case custom((CGRect) -> (UIBezierPath))
}
