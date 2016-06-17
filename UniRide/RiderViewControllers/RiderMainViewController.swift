//
//  RiderMainViewController.swift
//  UniRide
//
//  Created by Tuna Onder on 6/7/16.
//  Copyright © 2016 Tuna Onder. All rights reserved.
//

import UIKit
import GoogleMaps

@objc
// Define RiderMainViewControllerDelegate as a protocol with two optional methods
protocol RiderMainViewControllerDelegate {
    
    optional func toggleMenuView()
    optional func collapseMenuView()
}

enum RiderState {
    case setPickupState
    case setDestinationState
    case cancelState
}

class RiderMainViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
   
    /*
     This instance variable designates the object that adopts the RiderMainViewControllerDelegate protocol.
     ContainerViewController adopts this protocol and implements its two optional methods (see its code).
     */
    var delegate: RiderMainViewControllerDelegate?
    
    // A reference to the location manager
    var locationManager: CLLocationManager!
    //Google Maps View
    var mapView = GMSMapView()
    

    //Set Rider State
    var riderState: RiderState = .setPickupState
    
    var camera: GMSCameraPosition?
    
    var centerImage: UIImageView!
    var riderLabel: UILabel!
    var lessRiderButton: UIButton!
    var moreRiderButton: UIButton!
    var riderCountDisplayLabel: UILabel!
    
    @IBOutlet var bottomButton: UIButton!
    var anotherDestButton: UIButton!
    var cancelRideButton: UIButton!
    
    
    //Get the screen size of the device
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var startMarker: GMSMarker!
    
    
    //Current Location Coordinates
    var long: Double = 0
    var lat: Double = 0
    var markerLat: Double = 0
    var markerLong: Double = 0
    
    //
    var numberOfRiders: Int = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeViewComponents()
        
        //Set rider state
        riderState = .setPickupState
        
        
        
        //Initialize location Manager
        locationManager = CLLocationManager()
        //This class is a delegate for locationManager
        locationManager.delegate = self
        //This wont be called after user allow once
        locationManager.requestWhenInUseAuthorization()
        
        
        //Real Device (it doesnt work on simulator)
        //If location manager returns a location continue
        if let location = locationManager.location {
            long = location.coordinate.longitude
            lat = location.coordinate.latitude
            
            mapLocationLoad()
            
            
        }
        
        // Do any additional setup after loading the view.
        
        
        
       
        
        
        
        
    }
    
    func initializeViewComponents(){
        //Transparent Navigation Bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.purpleColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        bottomButton.backgroundColor = UIColor.purpleColor()
        
        
        anotherDestButton = UIButton(frame: CGRect(x: 0, y: screenSize.height-50, width: screenSize.width/2, height: 50))
        anotherDestButton.backgroundColor = UIColor.blueColor()
        anotherDestButton.setTitle("Set Alternative Destination!", forState: .Normal)
        anotherDestButton.titleLabel?.numberOfLines = 2
        anotherDestButton.addTarget(self, action: #selector(setAnotherDestinationButtonPressed), forControlEvents: .TouchUpInside)
        
        
        cancelRideButton = UIButton(frame: CGRect(x: screenSize.width/2, y: screenSize.height-50, width: screenSize.width/2, height: 50))
        cancelRideButton.backgroundColor = UIColor.redColor()
        cancelRideButton.setTitle("Cancel Ride Request!", forState: .Normal)
        cancelRideButton.titleLabel?.numberOfLines = 2
        cancelRideButton.addTarget(self, action: #selector(cancelRideButtonPressed), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(anotherDestButton)
        self.view.addSubview(cancelRideButton)
        
        anotherDestButton.hidden = true
        cancelRideButton.hidden = true
        
      
        
    }
    
    
    func mapLocationLoad(){
        //Updates user location
        locationManager.startUpdatingLocation()
        //Sends the most accurate location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        camera = GMSCameraPosition.cameraWithLatitude(lat,
                                                      longitude: long, zoom: 15)
        
        /* If NAVIGATION BAR IS NOT TRANSPARENT
         //Status Bar: 20 px
         //Nav. Bar: 44 px
         //Button on the bottom: 50px
         mapView = GMSMapView.mapWithFrame(CGRectMake(0, 64, screenSize.width, screenSize.height-114), camera: camera!)
         */
        //If Navigation Bar is Transparent
        mapView = GMSMapView.mapWithFrame(CGRectMake(0, 0, screenSize.width, screenSize.height-50), camera: camera!)
        
        
        mapView.myLocationEnabled = true
        //This class is GMSMapView Delegate!
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        
        mapView.settings.consumesGesturesInView = true
        
        //SET IMAGE ICON
        let image = UIImage(named: "start-icon")
        centerImage = UIImageView(image: image!)
        //Status Bar: 20 px
        //Nav. Bar: 44 px
        //Button on the bottom: 50px
        //Total on the top: 64 px
        //Total on the bottom: 50px. Therefore image should be moved to top 7 px extra.
        //If Nav Bar is not transparent
        //centerImage.frame = CGRect(x: screenSize.width/2-20, y: screenSize.height/2-27, width: 40, height: 40)
        
        centerImage.frame = CGRect(x: screenSize.width/2-20, y: (screenSize.height-50)/2-40, width: 40, height: 40)
        
        
        
        
        self.view.addSubview(mapView)
        self.view.insertSubview(centerImage, aboveSubview: mapView)
        

        //Initialize On Map components after the mapview is loaded
        initializeOnMapComponents()
        
        
        
        
    }
    
    func initializeOnMapComponents(){
        riderLabel = UILabel()
        riderLabel.text = "Number of Riders: "
        riderLabel.font = UIFont(name: "Georgia", size: 17)
        riderLabel.frame = CGRect(x: 6, y: screenSize.height-100, width: 150, height: 21)
        self.view.insertSubview(riderLabel, aboveSubview: mapView)
        
        
        lessRiderButton = UIButton(frame: CGRectMake(160,screenSize.height-101,25,25))
        lessRiderButton.setTitle("-", forState: .Normal)
        lessRiderButton.backgroundColor = UIColor.blackColor()
        lessRiderButton.layer.cornerRadius = 0.5 * (lessRiderButton?.bounds.size.width)!
       // lessRiderButton!.setImage(UIImage(named:"start-icon.png"), forState: .Normal)
        lessRiderButton.addTarget(self, action: #selector(lessRiderButtonPressed), forControlEvents: .TouchUpInside)
        lessRiderButton.clipsToBounds = true
        self.view.insertSubview(lessRiderButton, aboveSubview: mapView)
        
        
        riderCountDisplayLabel = UILabel()
        riderCountDisplayLabel.text = "\(numberOfRiders)"
        riderCountDisplayLabel.font = UIFont(name: "Georgia", size: 26)
        riderCountDisplayLabel.frame = CGRect(x: 205, y: screenSize.height-105, width: 21, height: 28)
        self.view.insertSubview(riderCountDisplayLabel, aboveSubview: mapView)
        
        moreRiderButton = UIButton(frame: CGRectMake(240,screenSize.height-101,25,25))
        moreRiderButton.setTitle("+", forState: .Normal)
        moreRiderButton.backgroundColor = UIColor.blackColor()
        moreRiderButton.layer.cornerRadius = 0.5 * (moreRiderButton?.bounds.size.width)!
        // lessRiderButton!.setImage(UIImage(named:"start-icon.png"), forState: .Normal)
        moreRiderButton.addTarget(self, action: #selector(moreRiderButtonPressed), forControlEvents: .TouchUpInside)
        moreRiderButton.clipsToBounds = true
        self.view.insertSubview(moreRiderButton, aboveSubview: mapView)
    }
    
    //When this view is displayed first time ever, user has to allow location manager to use the real location
    //However the view is loaded before user press allow button
    //Thats why initialize mapview when status is changed
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            
            //Real Device
            if let location = locationManager.location {
                long = location.coordinate.longitude
                lat = location.coordinate.latitude
                
                mapLocationLoad()
                
            }
            
        }
    }
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition camera: GMSCameraPosition) {
        // print("\(camera.target.latitude) \(camera.target.longitude)")
        markerLat = camera.target.latitude
        markerLong = camera.target.longitude
        
    }
    
    /*
     -------------------------
     MARK: - Button Actions
     -------------------------
     */
    
    
    @IBAction func menuButtonTapped(sender: UIBarButtonItem) {
        //When menu is displayed, enable gestures to drag the menu to the left
        mapView.settings.consumesGesturesInView = false
        //When menu is displayed, do not allow map to move
        mapView.settings.scrollGestures = false
        
        /*
         Tell the delegate (ContainerViewController) to execute its implementation of the
         RiderMainViewControllerDelegate protocol method toggleMenuView()
         */
        delegate?.toggleMenuView!()
        
        
    }
    
    @IBAction func bottomButtonPressed(sender: AnyObject) {
        
        
        switch (riderState) {
        case .setPickupState:
            //bottomButton.backgroundColor = UIColor.redColor()
            bottomButton.setTitle("SET DESTINATION & GO!", forState: .Normal)
            
            let position = CLLocationCoordinate2D(latitude: markerLat, longitude: markerLong)
            startMarker = GMSMarker(position: position)
            startMarker.map = mapView
            
            //  let zoomOut = GMSCameraUpdate.zoomTo(14)
            //  mapView.animateWithCameraUpdate(zoomOut)
            // let position2 = CLLocationCoordinate2D(latitude: lat, longitude: long)
            //  mapView.animateWithCameraUpdate(GMSCameraUpdate.setTarget(position2))
            
            centerImage.image = UIImage(named: "destination-icon")
            // centerImageForDest?.hidden = false
            
            //Change the State
            riderState = .setDestinationState
        case .setDestinationState:
            
            bottomButton.hidden = true
            anotherDestButton.hidden = false
            cancelRideButton.hidden = false
            
            //Change The State
            riderState = .cancelState
        default:
            break
        }
        
        
    }
    
    
    //Rider Can Send Additional Requests at the Same Time!
    func setAnotherDestinationButtonPressed(){
        
        
    }
    
    func cancelRideButtonPressed(){
        
        mapView.clear()
        
        bottomButton.backgroundColor = UIColor.purpleColor()
        bottomButton.setTitle("Set Pickup Location", forState: .Normal)
        bottomButton.hidden = false
        
        anotherDestButton.hidden = true
        cancelRideButton.hidden = true
        
        centerImage.image = UIImage(named: "start-icon")
        
        //Change the state
        riderState = .setPickupState
    }
    
    func lessRiderButtonPressed(){
        if numberOfRiders > 1{
            numberOfRiders -= 1
        }
        riderCountDisplayLabel.text = "\(numberOfRiders)"
        
    }
    
    func moreRiderButtonPressed(){
        if numberOfRiders < 4 {
            numberOfRiders += 1
        }
        riderCountDisplayLabel.text = "\(numberOfRiders)"
        
    }
    
    
    
    
    
    
}
