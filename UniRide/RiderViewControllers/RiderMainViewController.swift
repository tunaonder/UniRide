//
//  RiderMainViewController.swift
//  UniRide
//
//  Created by Tuna Onder on 6/7/16.
//  Copyright © 2016 Tuna Onder. All rights reserved.
//

import UIKit
import GoogleMaps
import Parse

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
    case setAlternativeState
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
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController!
    var resultView: UITextView?
    
    var startMarker: GMSMarker!
    var destMarker1: GMSMarker!
    var destMarker2: GMSMarker!
    
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
    
    
    
    
    
    //Current Location Coordinates
    var long: Double = 0
    var lat: Double = 0
    var markerLat: Double = 0
    var markerLong: Double = 0
    
    //Variables
    var numberOfRiders: Int = 1
    var mapAlreadyLoaded: Bool = false
    var pickUpAddress: String = ""
    var pickUpLatitude = Double()
    var pickUpLongitude = Double()
    
    //TEMP
    let bilkentLatitude = 39.866826
    let bilkentLongitude = 32.747355
    
    var myThemeColor: UIColor = UIColor(red: 101/255.0, green: 179/255.0, blue: 234/255.0, alpha: 1.0)
    
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
        //TEMP
        else {
            long = bilkentLongitude
            lat = bilkentLatitude
            mapLocationLoad()
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
            statusBar.backgroundColor = myThemeColor
            
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
        self.navigationController?.navigationBar.backgroundColor = myThemeColor
        //Remove the 1 px seperator between nav bar and the view below
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        bottomButton.backgroundColor = myThemeColor
        
        
        
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
        backToPickupButton.backgroundColor = myThemeColor
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
        
        
        // searchController.searchBar.searchBarStyle = .Default
        
        //Remove Gray Background Around Search Bar
        //searchController.searchBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.barTintColor = myThemeColor
        
        // searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchSubView = UIView(frame: CGRectMake(0, 64, screenSize.width, 40.0))
        searchSubView.backgroundColor = myThemeColor
        
        searchSubView.addSubview(searchController.searchBar)
        self.view.insertSubview(searchSubView, aboveSubview: mapView)
        
        
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
        
        
        favListButton = UIButton(frame: CGRect(x: 6, y: screenSize.height-115, width: screenSize.width-150, height: 35))
        favListButton.backgroundColor = myThemeColor
        favListButton.setTitle("Favourite Destinations", forState: .Normal)
        favListButton.addTarget(self, action: #selector(favListButtonPressed), forControlEvents: .TouchUpInside)
        favListButton.layer.cornerRadius = 10
        favListButton.clipsToBounds = true
        favListButton.titleLabel?.font = UIFont(name: "Georgia", size: 15)
        self.view.insertSubview(favListButton, aboveSubview: mapView)
        favListButton.hidden = true
        
        addFavButton = UIButton(frame: CGRectMake(screenSize.width-130,screenSize.height-115,35,35))
        //lessRiderButton.setTitle("-", forState: .Normal)
        //lessRiderButton.backgroundColor = UIColor.blackColor()
        //  addFavButton.layer.cornerRadius = 0.5 * (addFavButton?.bounds.size.width)!
        addFavButton!.setImage(UIImage(named:"fav-icon.png"), forState: .Normal)
        addFavButton.addTarget(self, action: #selector(lessRiderButtonPressed), forControlEvents: .TouchUpInside)
        //addFavButton.clipsToBounds = true
        self.view.insertSubview(addFavButton, aboveSubview: mapView)
        addFavButton.hidden = true
        
        
        anotherDestButton = UIButton(frame: CGRect(x: 6, y: screenSize.height-115, width: screenSize.width-100, height: 35))
        anotherDestButton.backgroundColor = myThemeColor
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
    
    //Coordinates of Center Of the map change when camera moves
    func mapView(mapView: GMSMapView, didChangeCameraPosition camera: GMSCameraPosition) {
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
            bottomButton.setTitle("Set Destination & Go!", forState: .Normal)
            
            let position = CLLocationCoordinate2D(latitude: markerLat, longitude: markerLong)
            pickUpLatitude = markerLat
            pickUpLongitude = markerLong
            startMarker = GMSMarker(position: position)
            startMarker.icon = UIImage(named: "start-flag")
            startMarker.map = mapView
            
            //   let zoomOut = GMSCameraUpdate.zoomTo(14)
            //   mapView.animateWithCameraUpdate(zoomOut)
            // let position2 = CLLocationCoordinate2D(latitude: lat, longitude: long)
            //  mapView.animateWithCameraUpdate(GMSCameraUpdate.setTarget(position2))
            
            centerImage.image = UIImage(named: "destination-icon")
            backToPickupButton.hidden = false
            favListButton.hidden = false
            addFavButton.hidden = false
            
            
            //Rider Count Components
            riderLabel.hidden = true
            moreRiderButton.hidden = true
            lessRiderButton.hidden = true
            riderCountDisplayLabel.hidden = true
            
            
            //Change the State
            riderState = .setDestinationState
            
            //Set the address
            pickUpAddress = (searchController?.searchBar.text)!
        case .setDestinationState:
            
            bottomButton.setTitle("Cancel Ride Request", forState: .Normal)
            bottomButton.backgroundColor = UIColor.redColor()
            
            anotherDestButton.hidden = false
            backToPickupButton.hidden = true
            searchSubView.hidden = true
            favListButton.hidden = true
            addFavButton.hidden = true
            
            //Add Marker
            let position = CLLocationCoordinate2D(latitude: markerLat, longitude: markerLong)
            destMarker1 = GMSMarker(position: position)
            destMarker1.icon = UIImage(named: "dest-flag")
            destMarker1.map = mapView
            
            centerImage.hidden = true
            
            
            //Change The State
            riderState = .cancelState
            
            //Send Ride Request to Server with the Destination Address
            sendRideRequest((searchController?.searchBar.text)!)
            
            
            
        case .cancelState:
            mapView.clear()
            
            bottomButton.backgroundColor = myThemeColor
            bottomButton.setTitle("Set Pickup Location", forState: .Normal)
            
            searchSubView.hidden = false
            anotherDestButton.hidden = true
            favListButton.hidden = true
            addFavButton.hidden = true
            
            centerImage.hidden = false
            centerImage.image = UIImage(named: "start-icon")
            
            //Rider Count Components
            riderLabel.hidden = false
            moreRiderButton.hidden = false
            lessRiderButton.hidden = false
            riderCountDisplayLabel.hidden = false
            
            
            
            //Change the state
            riderState = .setPickupState
            
            //Clear Data
            pickUpAddress = ""
            pickUpLatitude = Double()
            pickUpLongitude = Double()
            
            //Cancel Request To Server
            cancelRideRequest()
            
            
        case .setAlternativeState:
            //Add Marker
            let position = CLLocationCoordinate2D(latitude: markerLat, longitude: markerLong)
            destMarker2 = GMSMarker(position: position)
            destMarker2.icon = UIImage(named: "dest-flag")
            destMarker2.map = mapView
            
            bottomButton.setTitle("Cancel Ride Request", forState: .Normal)
            bottomButton.backgroundColor = UIColor.redColor()
            
            anotherDestButton.hidden = false
            backToPickupButton.hidden = true
            searchSubView.hidden = true
            favListButton.hidden = true
            addFavButton.hidden = true
            centerImage.hidden = true
            
            anotherDestButton.hidden = true
            
            //Change the state
            riderState = .cancelState
            
            //Send Ride Request to Server with the Destination Address
            sendRideRequest((searchController?.searchBar.text)!)
            
        }
        
        
        
    }
    
    
    //Rider Can Send Additional Requests at the Same Time!
    func setAnotherDestinationButtonPressed(){
        anotherDestButton.hidden = true
        searchSubView.hidden = false
        favListButton.hidden = false
        addFavButton.hidden = false
        centerImage.hidden = false
        
        bottomButton.setTitle("Set Alternative Destination", forState: .Normal)
        bottomButton.backgroundColor = myThemeColor
        
        //Change the state
        riderState = .setAlternativeState
        
    }
    
    func backToPickupButtonPressed(){
        mapView.clear()
        bottomButton.setTitle("Set Pickup Location", forState: .Normal)
        
        centerImage.image = UIImage(named: "start-icon")
        backToPickupButton.hidden = true
        favListButton.hidden = true
        addFavButton.hidden = true
        
        //Rider Count Components
        riderLabel.hidden = false
        moreRiderButton.hidden = false
        lessRiderButton.hidden = false
        riderCountDisplayLabel.hidden = false
        
        riderState = .setPickupState
        
        //Clear
        pickUpAddress = ""
        pickUpLatitude = Double()
        pickUpLongitude = Double()
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
    
    
    /*
     -------------------------
     MARK: - Send Request to Server
     -------------------------
     */
    
    func sendRideRequest(destination: String){
        
        let riderRequest = PFObject(className: "RiderRequest")
        
        riderRequest["user"] = PFUser.currentUser()
        riderRequest["riderCount"] = numberOfRiders
        let pickUpCoords = [pickUpLatitude, pickUpLongitude]
        riderRequest["pickUpCoords"] = pickUpCoords
        let destinationCoords = [markerLat, markerLong]
        riderRequest["destinationCoords"] = destinationCoords
        riderRequest["pickUpAddress"] = pickUpAddress
        riderRequest["destinationAddress"] = destination
        
        riderRequest.saveInBackgroundWithBlock { (success, error) -> Void in
            
            if error == nil {
          
                AlertView().displayAlert("Your Ride Request from \(self.pickUpAddress) to \(destination) is Sent!", message: "Waiting for Available Drivers.", view: self)
                
                
                
            }
                
            else{
                print(error)
                
                
            }
            
        }
        
    }
    
    func cancelRideRequest(){
        let riderQuery = PFQuery(className: "RiderRequest")
        riderQuery.whereKey("user", equalTo: PFUser.currentUser()!)
        
        riderQuery.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error) -> Void in
            
            if error == nil {
                
                if let objects = objects as [PFObject]! {
                    
                    for object in objects {
                        
                        object.deleteInBackground()
                    }
                }
                
                AlertView().displayAlert("Notification", message: "Your Ride Request is Cancelled.", view: self)
            } else {
                
                print(error)
            }
            
        })
    }
    
    /*
     -------------------------
     MARK: - ALERT VIEW
     -------------------------
     */
    
    func displayAlert(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
            
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        
        
    }
    
    
    
    
    
}

extension RiderMainViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWithPlace place: GMSPlace) {
        searchController.active = false
        // Do something with the selected place.
       // print("Place name: ", place.name)
       // print("Place address: ", place.formattedAddress)
       // print("Place attributions: ", place.attributions)
        
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
        
        mapView.animateToLocation(location)

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


