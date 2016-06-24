//
//  AlertView.swift
//  UniRide
//
//  Created by Tuna Onder on 6/24/16.
//  Copyright © 2016 Tuna Onder. All rights reserved.
//

import UIKit

class AlertView {
    /*
     -------------------------
     MARK: - ALERT VIEW
     -------------------------
     */
    
    func displayAlert(title: String, message: String, view: UIViewController){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
            
            
        }))
        
        view.presentViewController(alert, animated: true, completion: nil)
        
        
        
    }
}
