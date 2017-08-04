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
    switch(lhs, rhs) {
    case (let .range(range1), let .range(range2)):
        return range1 == range2
    case(.single, .single):
        return true;
    default:
        return false;
    }
}
