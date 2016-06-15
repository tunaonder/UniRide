//
//  ContainerViewController.swift
//  ACCSports
//
//  Created by tuna onder on 10/5/15.
//  Copyright © 2015 TunaOnder. All rights reserved.
//

import UIKit
import QuartzCore


enum DriverSlideOutState {
    case DriverMenuCollapsed
    case DriverMenuExpanded
}

class DriverContainerViewController: UIViewController,DriverMainViewControllerDelegate, UIGestureRecognizerDelegate {
    
    /*
     This class is named Container, because it is a Container type of view controller controlling two child view controllers:
     NavigationController and MenuViewController.
     NavigationController is also a Container type of view controller controlling DriverMainViewController and its child
     view controllers.
     
     "Container view controllers display content owned by other view controllers. These other view controllers are
     explicitly associated with the container, forming a parent-child relationship. The combination of container and
     content view controllers creates a hierarchy of view controller objects with a single root view controller." [Apple]
     */
    
    var driverMainNavigationController: UINavigationController!
    var driverMainViewController: DriverMainViewController!
    
    var currentState: DriverSlideOutState = .DriverMenuCollapsed {
        didSet {
            let shouldShowShadow = currentState != .DriverMenuCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    var driverMenuViewController: DriverMenuViewController!
    
    // This defines how much the center view will show on the right when the menu is shown on the left.
    let centerPanelExpandedOffset: CGFloat = 80
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Create a DriverMainViewController object using UIStoryboard's private extension class method and
         store its object reference into the instance variable driverMainViewController.
         */
        driverMainViewController = UIStoryboard.getDriverMainViewController()
        
        // Designate self as the delegate to implement and execute the DriverMainViewControllerDelegate protocol methods.
        driverMainViewController.delegate = self
        
        

        
        /*
         Create a UINavigationController object and set its root view controller to be the driverMainViewController.
         Embedding the driverMainViewController within a navigation controller enables navigation to downstream
         view controllers and navigating back to upstream view controllers.
         */
        driverMainNavigationController = UINavigationController(rootViewController: driverMainViewController)
        view.addSubview(driverMainNavigationController.view)
        
        // Add driverMainNavigationController as a child view controller
        addChildViewController(driverMainNavigationController)
        
        // didMoveToParentViewController is called after a view controller is added to or removed from a container view controller.
        driverMainNavigationController.didMoveToParentViewController(self)
        
        /*
         The pan gesture is also known as drag or slide gesture. The user pans (drags or slides) the driverMainNavigationController
         object to reveal the menu (DriverMenuViewController's view). Therefore, whichever view the driverMainNavigationController is
         showing can be slided to the right to reveal the menu (DriverMenuViewController's view).
         
         Create a UIPanGestureRecognizer object, which will call the handlePanGesture: method when the user pans (drags or slides)
         the driverMainNavigationController object. Store its object reference into local variable panGestureRecognizer.
         */
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        
        // Attach the pan gesture recognizer object to the driverMainNavigationController object.
        driverMainNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    /*
     -----------------------------------------------------
     MARK: - DriverMainViewControllerDelegate Protocol Methods
     -----------------------------------------------------
     */
    func toggleMenuView() {
        
        let notAlreadyExpanded = (currentState != .DriverMenuExpanded)
        
        if notAlreadyExpanded {
            addMenuViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func collapseMenuView() {
        
        switch (currentState) {
        case .DriverMenuExpanded:
            toggleMenuView()
        default:
            break
        }
    }
    
    /*
     --------------------------------
     MARK: - Add Driver Menu View Controller
     --------------------------------
     */
    func addMenuViewController() {
        
        if (driverMenuViewController == nil) {
            
            /*
             Create a driverMenuViewController object using UIStoryboard's private extension class method and
             store its object reference into the instance variable driverMenuViewController.
             */
            driverMenuViewController = UIStoryboard.getDriverMenuViewController()
            
            // Designate driverMainViewController as the delegate to implement and execute the DriverMenuViewControllerDelegate protocol methods.           
            driverMenuViewController!.delegate = driverMainViewController
            
            
            
            view.insertSubview(driverMenuViewController!.view, atIndex: 0)
            
            // Add driverMenuViewController as a child view controller
            addChildViewController(driverMenuViewController!)
            
            // didMoveToParentViewController is called after a view controller is added to or removed from a container view controller.
            driverMenuViewController!.didMoveToParentViewController(self)
        }
    }
    

    
    /*
     ---------------------------
     MARK: - Animate Pan Gesture
     ---------------------------
     */
    func animateLeftPanel(shouldExpand shouldExpand: Bool) {
        
        if (shouldExpand) {
            currentState = .DriverMenuExpanded
            
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(driverMainNavigationController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .DriverMenuCollapsed
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.driverMainNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        
        if (shouldShowShadow) {
            driverMainNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            driverMainNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
    /*
     --------------------------
     MARK: - Handle Pan Gesture
     --------------------------
     */
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        let gestureIsDraggingFromRightToLeft = (recognizer.velocityInView(view).x < 0)
        
        switch(recognizer.state) {
        case .Began:
            if (currentState == .DriverMenuCollapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addMenuViewController()
                    showShadowForCenterViewController(true)
                }
            }
        case .Changed:
            if driverMenuViewController != nil && ((gestureIsDraggingFromRightToLeft && recognizer.view?.center.x > 187.5) || (gestureIsDraggingFromLeftToRight && recognizer.translationInView(view).x >= 0)) {
                recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
                recognizer.setTranslation(CGPointZero, inView: view)
            }
        case .Ended:
            if driverMenuViewController != nil {
                // Animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
        default:
            break
        }
    }
    
    
    
    
    
    
    
    
    
}

/*
 ------------------------------------
 MARK: - Storyboard Private Extension
 ------------------------------------
 */
private extension UIStoryboard {
    
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    }
    
    class func getDriverMenuViewController() -> DriverMenuViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("DriverMenuViewController") as? DriverMenuViewController
    }
    
    class func getDriverMainViewController() -> DriverMainViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("DriverMainViewController") as? DriverMainViewController
    }

    
}