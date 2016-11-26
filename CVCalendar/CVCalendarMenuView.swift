//
//  CVCalendarMenuView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

public typealias WeekdaySymbolType = CVWeekdaySymbolType

public final class CVCalendarMenuView: UIView {
    public var symbols = [String]()
    public var symbolViews: [UILabel]?

    public var firstWeekday: Weekday? = .sunday
    public var dayOfWeekTextColor: UIColor? = .darkGray
    public var dayofWeekBackgroundColor: UIColor? = .clear
    public var dayOfWeekTextUppercase: Bool? = true
    public var dayOfWeekFont: UIFont? = UIFont(name: "Avenir", size: 10)
    public var weekdaySymbolType: WeekdaySymbolType? = .short

    @IBOutlet public weak var menuViewDelegate: AnyObject? {
        set {
            if let delegate = newValue as? MenuViewDelegate {
                self.delegate = delegate
            }
        }

        get {
            return delegate
        }
    }

    public weak var delegate: MenuViewDelegate? {
        didSet {
            setupAppearance()
            setupWeekdaySymbols()
            createDaySymbols()
        }
    }

    public init() {
        super.init(frame: CGRect.zero)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func setupAppearance() {
        if let delegate = delegate {
            firstWeekday~>delegate.firstWeekday?()
            dayOfWeekTextColor~>delegate.dayOfWeekTextColor?()
            dayofWeekBackgroundColor~>delegate.dayOfWeekBackGroundColor?()
            dayOfWeekTextUppercase~>delegate.dayOfWeekTextUppercase?()
            dayOfWeekFont~>delegate.dayOfWeekFont?()
            weekdaySymbolType~>delegate.weekdaySymbolType?()
        }
    }

    public func setupWeekdaySymbols() {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        (calendar as NSCalendar).components([NSCalendar.Unit.month, NSCalendar.Unit.day], from: Foundation.Date())
        calendar.firstWeekday = firstWeekday!.rawValue

        symbols = calendar.weekdaySymbols
    }

    public func createDaySymbols() {
        // Change symbols with their places if needed.
        let dateFormatter = DateFormatter()
        var weekdays: NSArray

        switch weekdaySymbolType! {
        case .normal:
            weekdays = dateFormatter.weekdaySymbols as NSArray
        case .short:
            weekdays = dateFormatter.shortWeekdaySymbols as NSArray
        case .veryShort:
            weekdays = dateFormatter.veryShortWeekdaySymbols as NSArray
        }

        let firstWeekdayIndex = firstWeekday!.rawValue - 1
        if firstWeekdayIndex > 0 {
            let copy = weekdays
            weekdays = weekdays.subarray(
                with: NSRange(location: firstWeekdayIndex, length: 7 - firstWeekdayIndex)) as NSArray
            weekdays = weekdays.addingObjects(
                from: copy.subarray(with: NSRange(location: 0, length: firstWeekdayIndex))) as NSArray
        }

        self.symbols = weekdays as! [String]

        // Add symbols.
        self.symbolViews = [UILabel]()
        let space = 0 as CGFloat
        let width = self.frame.width / 7 - space
        let height = self.frame.height

        var x: CGFloat = 0
        let y: CGFloat = 0

        for i in 0..<7 {
            x = CGFloat(i) * width + space

            let symbol = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
            symbol.textAlignment = .center
            symbol.text = self.symbols[i]

            if dayOfWeekTextUppercase! {
                symbol.text = (self.symbols[i]).uppercased()
            }
            
            let weekDay = Weekday(rawValue: (firstWeekday!.rawValue + i) % 7) ?? .saturday
            symbol.font = dayOfWeekFont
            symbol.textColor = self.delegate?.dayOfWeekTextColor?(by: weekDay)
                ?? dayOfWeekTextColor
            symbol.backgroundColor = self.delegate?.dayOfWeekBackGroundColor?(by: weekDay)
                ?? dayofWeekBackgroundColor
            self.symbolViews?.append(symbol)
            self.addSubview(symbol)
        }
    }

    public func commitMenuViewUpdate() {
        setNeedsLayout()
        layoutIfNeeded()
        if let _ = delegate {
            let space = 0 as CGFloat
            let width = self.frame.width / 7 - space
            let height = self.frame.height

            var x: CGFloat = 0
            let y: CGFloat = 0

            for i in 0..<self.symbolViews!.count {
                x = CGFloat(i) * width + space

                let frame = CGRect(x: x, y: y, width: width, height: height)
                let symbol = self.symbolViews![i]
                symbol.frame = frame
            }
        }
    }
}
