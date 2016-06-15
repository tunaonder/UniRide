//
//  DriverMainViewController.swift
//  UniRide
//
//  Created by Tuna Onder on 6/8/16.
//  Copyright © 2016 Tuna Onder. All rights reserved.
//

import UIKit

@objc
// Define DriverMainViewControllerDelegate as a protocol with two optional methods
protocol DriverMainViewControllerDelegate {
    
    optional func toggleMenuView()
    optional func collapseMenuView()
}

class DriverMainViewController: UIViewController, DriverMenuViewControllerDelegate {
    
    /*
     This instance variable designates the object that adopts the DriverMainViewControllerDelegate protocol.
     DriverContainerViewController adopts this protocol and implements its two optional methods (see its code).
     */
    var delegate: DriverMainViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func menuButtonTapped(sender: AnyObject) {
        
        /*
         Tell the delegate (DriverContainerViewController) to execute its implementation of the
         DriverMainViewControllerDelegate protocol method toggleMenuView()
         */
        
        delegate?.toggleMenuView!()
    }
    
    func itemSelected() {
        //Collapse the Menu
        delegate?.collapseMenuView!()
        
        performSegueWithIdentifier("carInfoSegue", sender: self)
    } 
    
}
