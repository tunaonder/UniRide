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

        
    }
    
    override func viewDidAppear(animated: Bool) {
        //temp
   //     let containerViewController = ContainerViewController()
        
        //Display ContainerViewController with Animation
   //     Animate().showViewControllerWith(containerViewController, usingAnimation: AnimationType.ANIMATE_UP)
        
        
        //If Current User is cached on the disk
        //PFUser.currentUser()?["name"] returns Optional("facebook name of the user")
        if PFUser.currentUser()?["name"] != nil {
            
            PFUser.currentUser()!.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
               
                if (currentUser as? PFUser) != nil {
                    
                    if let userState =  PFUser.currentUser()!["signedUp"]{
                        if (userState as! Int == 1){
                            // Create a ContainerViewController object and store its object reference into the local variable containerViewController.
                            let containerViewController = ContainerViewController()
                            
                            //Display ContainerViewController with Animation
                            Animate().showViewControllerWith(containerViewController, usingAnimation: AnimationType.ANIMATE_UP)
                        }
                        else {
                            print("Did not sign up yet 1")
                        }
                    }
                    else{
                        print("Did not sign up yet 2")
                        
                    }
                    
                    
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
                
            else if user != nil {
                
                    print("User signed up and logged in through Facebook!")
                    self.performSegueWithIdentifier("signUpSegue", sender:self)

                
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
                
            }
        }
        
    }



}
