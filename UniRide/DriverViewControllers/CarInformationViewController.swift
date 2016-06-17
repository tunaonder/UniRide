//
//  CarInformationViewController.swift
//  UniRide
//
//  Created by Tuna Onder on 6/9/16.
//  Copyright © 2016 Tuna Onder. All rights reserved.
//

import UIKit
import GoogleMaps

class CarInformationViewController: UIViewController {
    
    
    
    var riderMainNavigationController: UINavigationController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*   riderMainNavigationController = UINavigationController(rootViewController: self)
         view.addSubview(riderMainNavigationController.view)
         
         // Add riderMainNavigationController as a child view controller
         //  addChildViewController(riderMainNavigationController)
         
         // didMoveToParentViewController is called after a view controller is added to or removed from a container view controller.
         riderMainNavigationController.didMoveToParentViewController(self)
         
         // Do any additional setup after loading the view.*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        //Back Button Pressed:
        //self.navigationController?.popViewControllerAnimated(true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController!, didAutocompleteWithPlace place: GMSPlace!) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewController(viewController: GMSAutocompleteViewController!, didFailAutocompleteWithError error: NSError!) {
        // TODO: handle the error.
        print("Error: \(error.description)")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // User canceled the operation.
    func wasCancelled(viewController: GMSAutocompleteViewController!) {
        print("Autocomplete was cancelled.")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


