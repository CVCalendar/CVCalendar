//
//  ViewController.swift
//  Calendar
//
//  Created by E. Mozharovsky on 12/15/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var calendarHolderView: CalendarView!
    @IBOutlet weak var heightLayout: NSLayoutConstraint!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        
        self.calendarHolderView.completeInitializationOnAppearing()
        self.updateContraints()
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateContraints() {
        self.heightLayout.constant = self.calendarHolderView.frame.height
    }

}

