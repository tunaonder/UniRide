//
//  UserSignUpViewController.swift
//  UniRide
//
//  Created by Tuna Onder on 6/8/16.
//  Copyright © 2016 Tuna Onder. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Parse

class UserSignUpViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var window: UIWindow?
    var imageView = UIImageView()
    
    @IBOutlet var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name"])
        
        graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
            if error != nil {
                print(error)
                
            }
                
            else if let result = result {
                PFUser.currentUser()?["name"] = result["name"]!
                PFUser.currentUser()?.saveInBackgroundWithBlock({ (result, error) -> Void in
                    if let error = error {
                        print(error)
                        
                    }
                    
                })
                
                let userId = result["id"]! as! String
                let facebookProfilepictureUrl = "https://graph.facebook.com/" + userId + "/picture?type=large"
                
                if let fbpicUrl = NSURL(string: facebookProfilepictureUrl)
                {
                    //  print(fbpicUrl)
                    if let data = NSData(contentsOfURL: fbpicUrl) {
                        
                        //IMAGE VIEW DETAILS
                        self.specifyImageView()
                        self.imageView.image = UIImage(data: data)
                        self.view.addSubview(self.imageView)
                        //Set User Name
                        self.userNameLabel.text = result["name"]! as? String
                        
                      //  let imageFile: PFFile = PFFile(data: data)!
                        
                      //  PFUser.currentUser()?["image"] = imageFile
                      //  PFUser.currentUser()?.saveInBackground()
                        
                    }
                }
                
            }
        }
        
    }
    
    
    @IBAction func continueButtonPressed(sender: AnyObject) {
        
        let user = PFUser.currentUser()
        if let user = user {
            user["signedUp"] = 1
            user.saveInBackgroundWithBlock { (success, error) -> Void in
                
                
                if error == nil {
                    // Create a ContainerViewController object and store its object reference into the local variable containerViewController.
                    let containerViewController = ContainerViewController()
                    
                    //Display ContainerViewController with Animation
                    Animate().showViewControllerWith(containerViewController, usingAnimation: AnimationType.ANIMATE_UP)
                    
                }
                    
                else{
                    
                    if let errorString = error!.userInfo["error"] as? String {
                        
                        AlertView().displayAlert("Could not Signed Up", message: errorString, view: self)
                        
                    }
                    
                }
                
            }
        }
        
        
       
    }
    
    /*
     -------------------------
     MARK: - Setting User Profile Image
     -------------------------
     */
    
    func specifyImageView(){
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        imageView = UIImageView(frame: CGRectMake(screenWidth/2-100, 50, 200, 200))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UserSignUpViewController.imageTapped(_:)))
        
        // add it to the image view;
        imageView.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        imageView.userInteractionEnabled = true
        imageView.backgroundColor = UIColor.redColor()
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        
        
    }
    
    func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            
            //Here you can initiate your new ViewController
            
            //View controller which goes out of the app for a second
            let image = UIImagePickerController()
            image.delegate = self
            //Take photo from camera
            image.sourceType = UIImagePickerControllerSourceType.Camera
            //No edit before import the image
            image.allowsEditing = false
            
            
            self.presentViewController(image, animated: true, completion: nil)
            
            
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        
        self.imageView.image = image
        
        //Done with photo picking
        dismissViewControllerAnimated(true, completion: nil)
        
   
    }
    

    
    
    
    
    
}
