//
//  CVCalendarContentViewPresentationCoordinator.swift
//  CVCalendar Demo
//
//  Created by Ethan Setnik on 2/10/17.
//  Copyright © 2017 GameApp. All rights reserved.
//

import UIKit
protocol CVCalendarContentPresentationCoordinator {
  func setDayOutViewsVisible(monthViews: [Identifier: MonthView], visible: Bool)
}

extension CVCalendarContentPresentationCoordinator {
  public func setDayOutViewsVisible(monthViews: [Identifier: MonthView], visible: Bool) {
    for monthView in monthViews.values {
      monthView.mapDayViews { dayView in
        if dayView.isOut {

          if visible {
            dayView.alpha = 0
            dayView.isHidden = false
          }

          UIView.animate(withDuration: 0.5, delay: 0,
                         options: UIViewAnimationOptions(),
                         animations: {
            dayView.alpha = visible ? 1 : 0
          }, completion: { _ in
            dayView.isHidden = !visible
          })
        }
      }
    }
  }
}
