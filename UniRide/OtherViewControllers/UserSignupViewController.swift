//
//  UserSignUpViewController.swift
//  UniRide
//
//  Created by Tuna Onder on 6/8/16.
//  Copyright © 2016 Tuna Onder. All rights reserved.
//

import UIKit

class UserSignUpViewController: UIViewController {
    
    var window: UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func continueButtonPressed(sender: AnyObject) {
        
        
        
        // Create a ContainerViewController object and store its object reference into the local variable containerViewController.
        let containerViewController = ContainerViewController()
        
        //Display ContainerViewController with Animation
        Animate().showViewControllerWith(containerViewController, usingAnimation: AnimationType.ANIMATE_UP)
    }
    
    
    
    
    
}
