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
    
    
    //Get the screen size of the device
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var startMarker: GMSMarker!
    
    var centerImage: UIImageView!
    var backToPickupButton: UIButton!
    var riderLabel: UILabel!
    var lessRiderButton: UIButton!
    var moreRiderButton: UIButton!
    var riderCountDisplayLabel: UILabel!
    var searchSubView: UIView!
    
    @IBOutlet var bottomButton: UIButton!
    var anotherDestButton: UIButton!
    var favListButton: UIButton!
    var addFavButton: UIButton!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController!
    var resultView: UITextView?
    
   
    
    //Current Location Coordinates
    var long: Double = 0
    var lat: Double = 0
    var markerLat: Double = 0
    var markerLong: Double = 0
    
    //Variables
    var numberOfRiders: Int = 1
     var mapAlreadyLoaded: Bool = false

    
    
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
        
        
        
        //Real Device
        if let location = locationManager.location {
            long = location.coordinate.longitude
            lat = location.coordinate.latitude
            
            
            mapLocationLoad()
            //Set Map Already loaded, so it cannot be called from status change method
            mapAlreadyLoaded = true
            
        }
        
        
        
        
        // Do any additional setup after loading the view.
        
        
        
        
        
        
        
        
    }
    


    
    /*
     -------------------------
     MARK: - Initialize View Components
     -------------------------
     */
    
    //change status bar color for this view
    override func viewWillAppear(animated: Bool) {
        //self.navigationController?.navigationBarHidden =  true
        
        //Status bar style and visibility
        UIApplication.sharedApplication().statusBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        //Change status bar color
        let statusBar: UIView = UIApplication.sharedApplication().valueForKey("statusBar") as! UIView
        if statusBar.respondsToSelector(Selector("setBackgroundColor:")) {
            statusBar.backgroundColor = UIColor.purpleColor()
        }
        
    }
    
    
    func initializeViewComponents(){
        
        
        //Transparent Navigation Bar
        /*     self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
         self.navigationController?.navigationBar.shadowImage = UIImage()
         self.navigationController?.navigationBar.translucent = true
         self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
         
         let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.purpleColor()]
         self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject] */
        
        //UnTransparent navigation bar
        //  UIApplication.sharedApplication().statusBarStyle = .BlackOpaqu
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.backgroundColor = UIColor.purpleColor()
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]

        bottomButton.backgroundColor = UIColor.purpleColor()
        

        
    }
    
    
    func mapLocationLoad(){
        
        
        //Updates user location
        locationManager.startUpdatingLocation()
        //Sends the most accurate location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        camera = GMSCameraPosition.cameraWithLatitude(lat,
                                                      longitude: long, zoom: 15)
        
        //  If NAVIGATION BAR IS NOT TRANSPARENT
        //Status Bar: 20 px
        //Nav. Bar: 44 px
        //Button on the bottom: 50px
        mapView = GMSMapView.mapWithFrame(CGRectMake(0, 64, screenSize.width, screenSize.height-114), camera: camera!)
        
        //If Navigation Bar is Transparent
        //   mapView = GMSMapView.mapWithFrame(CGRectMake(0, 0, screenSize.width, screenSize.height-50), camera: camera!)
        
        
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
        //Total on the bottom:
        //First Find the total map height and divide it by 2.
        //Move the image to bottom by 64 px because of the top view.
        //Move the image to up by 40 px because bottom of the image should be at center of the map
        //If Nav Bar is not transparent
        centerImage.frame = CGRect(x: screenSize.width/2-20, y: ((screenSize.height-114)/2+24), width: 40, height: 40)
        
        //centerImage.frame = CGRect(x: screenSize.width/2-20, y: (screenSize.height-50)/2-40, width: 40, height: 40)
        
    
        
        self.view.addSubview(mapView)
        self.view.insertSubview(centerImage, aboveSubview: mapView)
        
        
        //Initialize On Map components after the mapview is loaded
        initializeOnMapComponents()
        
       
        
        
    }
    
    func initializeOnMapComponents(){
        riderLabel = UILabel()
        riderLabel.text = "Number of Riders: "
        riderLabel.font = UIFont(name: "Georgia", size: 16)
        riderLabel.frame = CGRect(x: 6, y: screenSize.height-100, width: 135, height: 21)
        self.view.insertSubview(riderLabel, aboveSubview: mapView)
        
        
        lessRiderButton = UIButton(frame: CGRectMake(145,screenSize.height-101,25,25))
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
        riderCountDisplayLabel.frame = CGRect(x: 185, y: screenSize.height-105, width: 21, height: 28)
        self.view.insertSubview(riderCountDisplayLabel, aboveSubview: mapView)
        
        moreRiderButton = UIButton(frame: CGRectMake(215,screenSize.height-101,25,25))
        moreRiderButton.setTitle("+", forState: .Normal)
        moreRiderButton.backgroundColor = UIColor.blackColor()
        moreRiderButton.layer.cornerRadius = 0.5 * (moreRiderButton?.bounds.size.width)!
        // lessRiderButton!.setImage(UIImage(named:"start-icon.png"), forState: .Normal)
        moreRiderButton.addTarget(self, action: #selector(moreRiderButtonPressed), forControlEvents: .TouchUpInside)
        moreRiderButton.clipsToBounds = true
        self.view.insertSubview(moreRiderButton, aboveSubview: mapView)
        
        backToPickupButton = UIButton(frame: CGRectMake(8,125,32,32))
        backToPickupButton.setTitle("<-", forState: .Normal)
        backToPickupButton.backgroundColor = UIColor.purpleColor()
        backToPickupButton.layer.cornerRadius = 0.5 * (backToPickupButton?.bounds.size.width)!
        backToPickupButton.addTarget(self, action: #selector(backToPickupButtonPressed), forControlEvents: .TouchUpInside)
        backToPickupButton.clipsToBounds = true
        self.view.insertSubview(backToPickupButton, aboveSubview: mapView)
        backToPickupButton.hidden = true
        

        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = resultsViewController
        
        
        searchController.searchBar.searchBarStyle = .Default
        
        //Remove Gray Background Around Search Bar
        searchController.searchBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchSubView = UIView(frame: CGRectMake(0, 70, screenSize.width, 40.0))
        
        searchSubView.addSubview(searchController.searchBar)
        self.view.insertSubview(searchSubView, aboveSubview: mapView)
        
        
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
        
        
        favListButton = UIButton(frame: CGRect(x: 6, y: screenSize.height-115, width: screenSize.width-150, height: 35))
        favListButton.backgroundColor = UIColor.purpleColor()
        favListButton.setTitle("Favourite Destinations", forState: .Normal)
        favListButton.addTarget(self, action: #selector(favListButtonPressed), forControlEvents: .TouchUpInside)
        favListButton.layer.cornerRadius = 10
        favListButton.clipsToBounds = true
        favListButton.titleLabel?.font = UIFont(name: "Georgia", size: 15)
        self.view.insertSubview(favListButton, aboveSubview: mapView)
        favListButton.hidden = true
        
        
        anotherDestButton = UIButton(frame: CGRect(x: 6, y: screenSize.height-115, width: screenSize.width-100, height: 35))
        anotherDestButton.backgroundColor = UIColor.purpleColor()
        anotherDestButton.setTitle("Set Alternative Destination!", forState: .Normal)
        anotherDestButton.addTarget(self, action: #selector(setAnotherDestinationButtonPressed), forControlEvents: .TouchUpInside)
        anotherDestButton.layer.cornerRadius = 10
        anotherDestButton.clipsToBounds = true
        anotherDestButton.titleLabel?.font = UIFont(name: "Georgia", size: 15)
        self.view.insertSubview(anotherDestButton, aboveSubview: mapView)
        anotherDestButton.hidden = true
        
    }
    
    //When this view is displayed first time ever, user has to allow location manager to use the real location
    //However the view is loaded before user press allow button
    //Thats why initialize mapview when status is changed
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            
            
            if mapAlreadyLoaded == false {
                //Real Device
                if let location = locationManager.location {
                    long = location.coordinate.longitude
                    lat = location.coordinate.latitude
                    
                    mapLocationLoad()
                    
                }
            }
           
            
        }
    }
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition camera: GMSCameraPosition) {
        // print("\(camera.target.latitude) \(camera.target.longitude)")
        markerLat = camera.target.latitude
        markerLong = camera.target.longitude
        
    }
    
    //Update Address when Map becomes stable
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {

            (searchController?.searchBar)!.text = " " + AddressFinder().getAddressForLatLng("\(markerLat)", longitude: "\(markerLong)")
      
        
        
        
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
            backToPickupButton.hidden = false
            favListButton.hidden = false
            
            
            //Rider Count Components
            riderLabel.hidden = true
            moreRiderButton.hidden = true
            lessRiderButton.hidden = true
            riderCountDisplayLabel.hidden = true
          
            
            //Change the State
            riderState = .setDestinationState
        case .setDestinationState:
            
            bottomButton.setTitle("Cancel Ride Request", forState: .Normal)
            bottomButton.backgroundColor = UIColor.redColor()
            
            anotherDestButton.hidden = false
            backToPickupButton.hidden = true
            searchSubView.hidden = true
            favListButton.hidden = true
            
            
            
            //Change The State
            riderState = .cancelState
        case .cancelState:
            mapView.clear()
            
            bottomButton.backgroundColor = UIColor.purpleColor()
            bottomButton.setTitle("Set Pickup Location", forState: .Normal)
           
            searchSubView.hidden = false
            anotherDestButton.hidden = true
            
            centerImage.image = UIImage(named: "start-icon")
            
            //Rider Count Components
            riderLabel.hidden = false
            moreRiderButton.hidden = false
            lessRiderButton.hidden = false
            riderCountDisplayLabel.hidden = false
            
            
            
            //Change the state
            riderState = .setPickupState
            
       
        }
        
        
    }
    
    
    //Rider Can Send Additional Requests at the Same Time!
    func setAnotherDestinationButtonPressed(){
        
        
    }
    
    func backToPickupButtonPressed(){
        mapView.clear()
        bottomButton.setTitle("Set Pickup Location", forState: .Normal)
        
        centerImage.image = UIImage(named: "start-icon")
        backToPickupButton.hidden = true
        
        //Rider Count Components
        riderLabel.hidden = false
        moreRiderButton.hidden = false
        lessRiderButton.hidden = false
        riderCountDisplayLabel.hidden = false
        
        riderState = .setPickupState
    }
    
    func favListButtonPressed(){
        
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

extension RiderMainViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWithPlace place: GMSPlace) {
        searchController.active = false
        // Do something with the selected place.
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: NSError){
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}


