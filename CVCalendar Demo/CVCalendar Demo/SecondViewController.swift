//
//  SecondViewController.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 2/23/16.
//  Copyright © 2016 GameApp. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: 150)
        layout.minimumLineSpacing = 2
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.lightGrayColor()
        
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        view.addConstraints([
            NSLayoutConstraint(item: collectionView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        ])
        
    }
}

extension SecondViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        
        cell.backgroundColor = UIColor.magentaColor()
        
        return cell
    }
}