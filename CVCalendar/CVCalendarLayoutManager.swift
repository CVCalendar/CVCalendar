//
//  CVCalendarLayoutManager.swift
//  CVCalendar Demo
//
//  Created by mac on 03/03/16.
//  Copyright © 2016 GameApp. All rights reserved.
//

import UIKit

public extension UIView {
    func constraint(attribute: NSLayoutAttribute, relation: NSLayoutRelation, toView view: UIView? = nil, constant: CGFloat) -> UIView {
        if let view = view {
            view.addConstraint(NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: view, attribute: attribute, multiplier: 1, constant: constant))
        } else {
            self.addConstraint(NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: constant))
        }
        
        return self
    }
}
