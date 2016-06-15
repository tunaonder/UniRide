//
//  ContainerViewController.swift
//  ACCSports
//
//  Created by tuna onder on 10/5/15.
//  Copyright © 2015 TunaOnder. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case MenuCollapsed
    case MenuExpanded
}


class ContainerViewController: UIViewController, RiderMainViewControllerDelegate, UIGestureRecognizerDelegate {
    
    /*
     This class is named Container, because it is a Container type of view controller controlling two child view controllers:
     NavigationController and MenuViewController.
     NavigationController is also a Container type of view controller controlling RiderMainViewController and its child
     view controllers.
     
     "Container view controllers display content owned by other view controllers. These other view controllers are
     explicitly associated with the container, forming a parent-child relationship. The combination of container and
     content view controllers creates a hierarchy of view controller objects with a single root view controller." [Apple]
     */
    
    var riderMainNavigationController: UINavigationController!
    var riderMainViewController: RiderMainViewController!
    
    
    var currentState: SlideOutState = .MenuCollapsed {
        didSet {
            let shouldShowShadow = currentState != .MenuCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    var menuViewController: MenuViewController?
    
    
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
         Create a RiderMainViewController object using UIStoryboard's private extension class method and
         store its object reference into the instance variable riderMainViewController.
         */
        riderMainViewController = UIStoryboard.getRiderMainViewController()
        
        // Designate self as the delegate to implement and execute the RiderMainViewControllerDelegate protocol methods.
        riderMainViewController.delegate = self
        
        /*
         Create a UINavigationController object and set its root view controller to be the riderMainViewController.
         Embedding the riderMainViewController within a navigation controller enables navigation to downstream
         view controllers and navigating back to upstream view controllers.
         */
        riderMainNavigationController = UINavigationController(rootViewController: riderMainViewController)
        
        view.addSubview(riderMainNavigationController.view)
        
        // Add riderMainNavigationController as a child view controller
        addChildViewController(riderMainNavigationController)
        
        // didMoveToParentViewController is called after a view controller is added to or removed from a container view controller.
        riderMainNavigationController.didMoveToParentViewController(self)
        
        /*
         The pan gesture is also known as drag or slide gesture. The user pans (drags or slides) the riderMainNavigationController
         object to reveal the menu (MenuViewController's view). Therefore, whichever view the riderMainNavigationController is
         showing can be slided to the right to reveal the menu (MenuViewController's view).
         
         Create a UIPanGestureRecognizer object, which will call the handlePanGesture: method when the user pans (drags or slides)
         the riderMainNavigationController object. Store its object reference into local variable panGestureRecognizer.
         */
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        
        // Attach the pan gesture recognizer object to the riderMainNavigationController object.
        riderMainNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    /*
     -----------------------------------------------------
     MARK: - RiderMainViewControllerDelegate Protocol Methods
     -----------------------------------------------------
     */
    func toggleMenuView() {
        
        let notAlreadyExpanded = (currentState != .MenuExpanded)
        
        if notAlreadyExpanded {
            addMenuViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func collapseMenuView() {
        
        switch (currentState) {
        case .MenuExpanded:
            toggleMenuView()
            
        default:
            break
        }
    }
    
    /*
     --------------------------------
     MARK: - Add Menu View Controller
     --------------------------------
     */
    func addMenuViewController() {
        
        if (menuViewController == nil) {
            
            /*
             Create a MenuViewController object using UIStoryboard's private extension class method and
             store its object reference into the instance variable menuViewController.
             */
            menuViewController = UIStoryboard.getMenuViewController()
            
            
            view.insertSubview(menuViewController!.view, atIndex: 0)
            
            // Add menuViewController as a child view controller
            addChildViewController(menuViewController!)
            
            // didMoveToParentViewController is called after a view controller is added to or removed from a container view controller.
            menuViewController!.didMoveToParentViewController(self)
        }
    }
    
  
    
    /*
     ---------------------------
     MARK: - Animate Pan Gesture
     ---------------------------
     */
    func animateLeftPanel(shouldExpand shouldExpand: Bool) {
        
        if (shouldExpand) {
            currentState = .MenuExpanded
            
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(riderMainNavigationController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .MenuCollapsed
                //When menu is collapsed, let the scrool gesture work again
                self.riderMainViewController.mapView.settings.scrollGestures = true
                
                //When Menu is Collapsed, consumes gestures in the map
                //So that menu cannot be expanded with the gesture left to right
                self.riderMainViewController.mapView.settings.consumesGesturesInView = true
                
                
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.riderMainNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        
        if (shouldShowShadow) {
            riderMainNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            riderMainNavigationController.view.layer.shadowOpacity = 0.0
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
            if (currentState == .MenuCollapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addMenuViewController()
                    showShadowForCenterViewController(true)
                }
            }
        case .Changed:
            if menuViewController != nil && ((gestureIsDraggingFromRightToLeft && recognizer.view?.center.x > 300) || (gestureIsDraggingFromLeftToRight && recognizer.translationInView(view).x >= 0)) {
                recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
                recognizer.setTranslation(CGPointZero, inView: view)
            }
        case .Ended:
            if menuViewController != nil {
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
    
    class func getMenuViewController() -> MenuViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MenuViewController") as? MenuViewController
    }
    
    class func getRiderMainViewController() -> RiderMainViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("RiderMainViewController") as? RiderMainViewController
    }
    

    
}