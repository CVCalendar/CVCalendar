//
//  CVCalendarLayoutManager.swift
//  CVCalendar Demo
//
//  Created by mac on 03/03/16.
//  Copyright © 2016 GameApp. All rights reserved.
//

import UIKit

public extension UIView {
    func constraint(attribute: NSLayoutAttribute, relation: NSLayoutRelation, toView view: UIView? = nil, withAttribute itemAttribute: NSLayoutAttribute? = nil, multiplier: CGFloat = 1, constant: CGFloat) -> UIView {
        if let view = view {
            view.addConstraint(NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: view, attribute: itemAttribute ?? attribute, multiplier: multiplier, constant: constant))
        } else {
            self.addConstraint(NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: nil, attribute: .NotAnAttribute, multiplier: multiplier, constant: constant))
        }
        
        return self
    }
}
