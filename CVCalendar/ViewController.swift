//
//  ViewController.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var monthViewHolder: UIView!
    
    var calendarView: CVCalendarView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendarView = CVCalendarView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.calendarView!.monthViewHolder = self.monthViewHolder
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

