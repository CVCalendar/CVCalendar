//
//  CVCircleView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCircleView: UIView {
    
    let color: UIColor?
    let _alpha: CGFloat?
    
    init(frame: CGRect, color: UIColor, _alpha: CGFloat) {
        super.init(frame: frame)
        
        self.color = color
        self._alpha = _alpha
        self.alpha = _alpha
        
        self.backgroundColor = .clearColor()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(rect: CGRect) {
        var context = UIGraphicsGetCurrentContext()
        
        CGContextSetLineWidth(context, 0.5)
        
        CGContextAddArc(context, (frame.size.width)/2, frame.size.height/2, (frame.size.width - 10)/2, 0.0, CGFloat(M_PI * 2.0), 1)
        
        // Draw
        CGContextSetFillColorWithColor(context, self.color!.CGColor)
        CGContextSetStrokeColorWithColor(context, self.color!.CGColor)
        CGContextDrawPath(context, kCGPathFillStroke)
    }

    deinit {
        println("Deinited a CircleView")
    }
}
