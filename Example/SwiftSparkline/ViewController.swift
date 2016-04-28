//
//  ViewController.swift
//  SwiftSparkline
//
//  Created by Ronaldo Gomes on 04/22/2016.
//  Copyright (c) 2016 Ronaldo Gomes. All rights reserved.
//

import UIKit
import SwiftSparkline

class ViewController: UIViewController {

    let sparklineView1 = SparklineView(frame: CGRectZero)
    let sparklineView2 = SparklineView(frame: CGRectZero)
    let sparklineView3 = SparklineView(frame: CGRectZero)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sparklineView1.frame = CGRectMake(0, 120, self.view.frame.size.width, 50)
        self.view.addSubview(self.sparklineView1)
        self.sparklineView1.show([10.0, 20.0, 40.0, 30.0, 15.0])
        
        self.sparklineView2.frame = CGRectMake(0, 180, self.view.frame.size.width, 50)
        self.sparklineView2.lineColor = UIColor.redColor()
        self.sparklineView2.fillColor = UIColor.purpleColor()
        self.view.addSubview(self.sparklineView2)
        self.sparklineView2.show([10.0, 20.0, 40.0, 30.0, 15.0].reverse())

        self.sparklineView3.frame = CGRectMake(0, 250, self.view.frame.size.width, 50)
        self.sparklineView3.lineColor = UIColor.redColor()
        self.sparklineView3.fillColor = UIColor.purpleColor()
        self.view.addSubview(self.sparklineView3)
        self.sparklineView3.show([15.0, 50.0])
        
    }

}

