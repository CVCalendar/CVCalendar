//
//  CVSelectionType.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 17/03/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

public enum CVSelectionType : Equatable {
    case single
    case range(CVRange)
}

public func ==(lhs: CVSelectionType, rhs: CVSelectionType) -> Bool {
    return lhs == rhs
}
