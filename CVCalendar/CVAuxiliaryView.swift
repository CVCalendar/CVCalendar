//
//  CVAuxiliaryView.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 22/03/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

public final class CVAuxiliaryView: UIView {
    public var shape: CVShape!
    public var strokeColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var fillColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public let defaultFillColor = UIColor.colorFromCode(0xe74c3c)
    
    private var radius: CGFloat {
        get {
            return (min(frame.height, frame.width) - 10) / 2
        }
    }
    
    public unowned let dayView: DayView
    
    public init(dayView: DayView, rect: CGRect, shape: CVShape) {
        self.dayView = dayView
        self.shape = shape
        super.init(frame: rect)
        strokeColor = UIColor.clearColor()
        fillColor = UIColor.colorFromCode(0xe74c3c)
        
        layer.cornerRadius = 5
        backgroundColor = .clearColor()
    }
    
    public override func didMoveToSuperview() {
        setNeedsDisplay()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func drawRect(rect: CGRect) {
        var path: UIBezierPath!
        
        if let shape = shape {
            switch shape {
            case .RightFlag: path = rightFlagPath()
            case .LeftFlag: path = leftFlagPath()
            case .Circle: path = circlePath()
            case .Rect: path = rectPath()
            case .Custom(let customPathBlock): path = customPathBlock(rect)
            }
            
            switch shape {
            case .Custom: break
            default: path.lineWidth = 1
            }
        }
        
        strokeColor.setStroke()
        fillColor.setFill()
        
        if let path = path {
            path.stroke()
            path.fill()
        }
    }
    
    deinit {
        //println("[CVCalendar Recovery]: AuxiliaryView is deinited.")
    }
}

extension CVAuxiliaryView {
    public func updateFrame(frame: CGRect) {
        self.frame = frame
        setNeedsDisplay()
    }
}

extension CVAuxiliaryView {
    func circlePath() -> UIBezierPath {
        let arcCenter = CGPointMake(frame.width / 2, frame.height / 2)
        let startAngle = CGFloat(0)
        let endAngle = CGFloat(M_PI * 2.0)
        let clockwise = true
        
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        
        return path
    }
    
    func rightFlagPath() -> UIBezierPath {
//        let appearance = dayView.calendarView.appearance
//        let offset = appearance.spaceBetweenDayViews!
        
        let flag = UIBezierPath()
        flag.moveToPoint(CGPointMake(bounds.width / 2, bounds.height / 2 - radius))
        flag.addLineToPoint(CGPointMake(bounds.width, bounds.height / 2 - radius))
        flag.addLineToPoint(CGPointMake(bounds.width, bounds.height / 2 + radius ))
        flag.addLineToPoint(CGPointMake(bounds.width / 2, bounds.height / 2 + radius))
        
        let path = CGPathCreateMutable()
        CGPathAddPath(path, nil, circlePath().CGPath)
        CGPathAddPath(path, nil, flag.CGPath)
        
        return UIBezierPath(CGPath: path)
    }
    
    func leftFlagPath() -> UIBezierPath {
        let flag = UIBezierPath()
        flag.moveToPoint(CGPointMake(bounds.width / 2, bounds.height / 2 + radius))
        flag.addLineToPoint(CGPointMake(0, bounds.height / 2 + radius))
        flag.addLineToPoint(CGPointMake(0, bounds.height / 2 - radius))
        flag.addLineToPoint(CGPointMake(bounds.width / 2, bounds.height / 2 - radius))
        
        let path = CGPathCreateMutable()
        CGPathAddPath(path, nil, circlePath().CGPath)
        CGPathAddPath(path, nil, flag.CGPath)
        
        return UIBezierPath(CGPath: path)
    }
    
    func rectPath() -> UIBezierPath {
//        let midX = bounds.width / 2
        let midY = bounds.height / 2
        
        let appearance = dayView.calendarView.appearance
        let offset = appearance.spaceBetweenDayViews!
        
        print("offset = \(offset)")
        
        let path = UIBezierPath(rect: CGRectMake(0 - offset, midY - radius, bounds.width + offset / 2, radius * 2))
        
        return path
    }
}