//
//  StarterViewController.swift
//  UniRide
//
//  Created by Tuna Onder on 6/14/16.
//  Copyright © 2016 Tuna Onder. All rights reserved.
//

import UIKit
import Parse

import ParseFacebookUtilsV4




class StarterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if (PFUser.currentUser()?.username) != nil {
           
            
            PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
               
                if (currentUser as? PFUser) != nil {
                    // Create a ContainerViewController object and store its object reference into the local variable containerViewController.
                    let containerViewController = ContainerViewController()
                    
                    //Display ContainerViewController with Animation
                    Animate().showViewControllerWith(containerViewController, usingAnimation: AnimationType.ANIMATE_UP)
                }
            })
          
       
        }
        else {
            print("First Time User")
            
        }
    }
    
 

    
    @IBAction func connectFbButtonPressed(sender: AnyObject) {
        
        let permissions = ["public_profile"]
        
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            }
                
            else if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                    self.performSegueWithIdentifier("signUpSegue", sender:self)
                } else {
                    
                    // Create a ContainerViewController object and store its object reference into the local variable containerViewController.
                    let containerViewController = ContainerViewController()                    
                    //Display ContainerViewController with Animation
                    Animate().showViewControllerWith(containerViewController, usingAnimation: AnimationType.ANIMATE_UP)
                    
                    
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
                
            }
        }
        
    }



}
