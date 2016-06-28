//
//  DriverMainViewController.swift
//  UniRide
//
//  Created by Tuna Onder on 6/8/16.
//  Copyright © 2016 Tuna Onder. All rights reserved.
//

import UIKit
import GoogleMaps
import Parse


@objc
// Define DriverMainViewControllerDelegate as a protocol with two optional methods
protocol DriverMainViewControllerDelegate {
    
    optional func toggleMenuView()
    optional func collapseMenuView()
}

enum DriverState{
    case setStartState
    case setDestinationState
    case goState
    case cancelState
}

class DriverMainViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, DriverMenuViewControllerDelegate {
    
    /*
     This instance variable designates the object that adopts the DriverMainViewControllerDelegate protocol.
     DriverContainerViewController adopts this protocol and implements its two optional methods (see its code).
     */
    var delegate: DriverMainViewControllerDelegate?
    
    
    // A reference to the location manager
    var locationManager: CLLocationManager!
    //Google Maps View
    var mapView = GMSMapView()
    
    var camera: GMSCameraPosition?
    
    //Get the screen size of the device
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController!
    var resultView: UITextView?
    
    var myThemeColor: UIColor = UIColor(red: 101/255.0, green: 179/255.0, blue: 234/255.0, alpha: 1.0)
    
    //View Components
    @IBOutlet var bottomButton: UIButton!
    var centerImage: UIImageView!
    var searchSubView: UIView!
    
    var startMarker: GMSMarker!
    var destMarker: GMSMarker!
    
    //Set Driver State
    var driverState: DriverState = .setStartState
    
    //Vars
    var long: Double = 0
    var lat: Double = 0
    var markerLat: Double = 0
    var markerLong: Double = 0
    var startLatitude = Double()
    var startLongitude = Double()
    var destinationLatitude = Double()
    var destinationLongitude = Double()
    var startAddress: String = ""
    var mapAlreadyLoaded: Bool = false
    //Route Origin and Destination
    var origin = String()
    var destination = String()
    
    //TEMP
    let bilkentLatitude = 39.866826
    let bilkentLongitude = 32.747355
    
    //Draw Route Components
    var mapTasks = DriverMapTasks()
    //Contains Route Data
    var routeData: String = ""
    var routePolyline: GMSPolyline!
    var coordinatesArray = [Double]()
    var originMarker: GMSMarker!
    var waypoints = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeViewComponents()
        
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

    
    //Coordinates of Center Of the map change when camera moves
    func mapView(mapView: GMSMapView, didChangeCameraPosition camera: GMSCameraPosition) {
        markerLat = camera.target.latitude
        markerLong = camera.target.longitude
        
    }
    
    //Update Address when Map becomes stable
  /*  func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        
        (searchController?.searchBar)!.text = " " + AddressFinder().getAddressForLatLng("\(markerLat)", longitude: "\(markerLong)")
 
        
    } */
    
    /*
     -------------------------
     MARK: - Button Actions
     -------------------------
     */
    
    @IBAction func bottomButtonPressed(sender: AnyObject) {
        
        switch(driverState){
        case .setStartState:
            
            bottomButton.setTitle("Set Destination!", forState: .Normal)
            
            let position = CLLocationCoordinate2D(latitude: markerLat, longitude: markerLong)
            startLatitude = markerLat
            startLongitude = markerLong
            startMarker = GMSMarker(position: position)
            startMarker.icon = UIImage(named: "start-flag")
            startMarker.map = mapView
            
            centerImage.image = UIImage(named: "destination-icon")
            
            //Change the State
            driverState = .setDestinationState
            
            //Set the address
            startAddress = (searchController?.searchBar.text)!
            
        case .setDestinationState:
            bottomButton.setTitle("Go!", forState: .Normal)
            
            //Add Marker
            let position = CLLocationCoordinate2D(latitude: markerLat, longitude: markerLong)
            destMarker = GMSMarker(position: position)
            destMarker.icon = UIImage(named: "dest-flag")
            destMarker.map = mapView
            
            destinationLatitude = markerLat
            destinationLongitude = markerLong
            
            centerImage.hidden = true
            
            
            drawRoute()
            
            //Change The State
            driverState = .goState
            
        case .goState:
            sendDriveRequest()
            
            bottomButton.setTitle("Cancel!", forState: .Normal)
            bottomButton.backgroundColor = UIColor.redColor()
            
            //Change The State
            driverState = .cancelState
            
            
            

            
        case .cancelState:
             mapView.clear()
            
             bottomButton.backgroundColor = myThemeColor
             bottomButton.setTitle("Set Start Location", forState: .Normal)
            
             centerImage.hidden = false
             centerImage.image = UIImage(named: "start-icon")
             
             //Clear Coordinates Array
             coordinatesArray.removeAll()
             mapTasks.coordinatesArray.removeAll()
             mapTasks.stepDistances.removeAll()
             
             //Change the state
             driverState = .setStartState
            
            
        }
        
        
    }
    
    @IBAction func menuButtonTapped(sender: AnyObject) {
        //When menu is displayed, enable gestures to drag the menu to the left
        mapView.settings.consumesGesturesInView = false
        //When menu is displayed, do not allow map to move
        mapView.settings.scrollGestures = false
        
        /*
         Tell the delegate (DriverContainerViewController) to execute its implementation of the
         DriverMainViewControllerDelegate protocol method toggleMenuView()
         */
        
        delegate?.toggleMenuView!()
    }
    
    func itemSelected() {
        //Collapse the Menu
        delegate?.collapseMenuView!()
        
        performSegueWithIdentifier("carInfoSegue", sender: self)
    }
    
    func sendDriveRequest(){
        
    }
    
    func drawRoute(){
        origin = "\(startLatitude),\(startLongitude)"
        destination = "\(destinationLatitude),\(destinationLongitude)"
        
        self.mapTasks.getDirections(origin, destination: destination, waypoints: nil, travelMode: nil, completionHandler: { (status, success) -> Void in
            if success {
                
                // self.configureMapAndMarkersForRoute()
                self.drawOnTheMap()
                self.putMarkers()
                // self.displayRouteInfo()
            }
            else {
                print(status)
            }
        })

    }
    
    func drawOnTheMap() {
        routeData = mapTasks.overviewPolyline["points"] as! String
        
        
        let path: GMSPath = GMSPath(fromEncodedPath: routeData)!
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = mapView
    }
    
    func putMarkers(){
        /*        stepCoordinates = mapTasks.stepCoordinates
         for stepCoordinate in stepCoordinates{
         originMarker = GMSMarker(position: stepCoordinate)
         originMarker.map = self.mapView
         originMarker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
         }*/
        
        coordinatesArray = mapTasks.coordinatesArray
        
        print(coordinatesArray.count)
        print(mapTasks.stepDistances.count)
        
        for i in 0 ..< mapTasks.stepDistances.count{
            
        //    print (mapTasks.stepDistances[i])
            
            let x = coordinatesArray[2*i]
            let y = coordinatesArray[2*i+1]
            
            let location = CLLocationCoordinate2D(latitude: x, longitude: y)
            
            originMarker = GMSMarker(position: location)
            originMarker.map = self.mapView
            originMarker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())

            
        }
        
        print("-----")
        
        
      /*   for var i = 0; i<coordinatesArray.count-1; i = i+2 {
            //Only DestinationPont Marker. Temporary
            //if (i == coordinatesArray.count-2){
            let x = coordinatesArray[i]
            let y = coordinatesArray[i+1]
            print(mapTasks.stepDistances[i/2])
            
            let location = CLLocationCoordinate2D(latitude: x, longitude: y)
            
            originMarker = GMSMarker(position: location)
            originMarker.map = self.mapView
            originMarker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            //  }
            
            
            
            
        }
        
               coordinatesArray2D = mapTasks.coordinatesArray2D
         
         for var i = 0; i<coordinatesArray2D.count; i = i+1 {
         
         
         let location = coordinatesArray2D[i]
         
         originMarker = GMSMarker(position: location)
         originMarker.map = self.mapView
         originMarker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
         
         
 
         
         
         }*/
        
        
        
    }
    
    /*
     -------------------------
     MARK: - Send Request to Server
     -------------------------
     */
    
    func sendDriverRequest(destination: String){
        
        let driverRequest = PFObject(className: "DriverRequest")
        
        driverRequest["user"] = PFUser.currentUser()
        driverRequest["coords"] = coordinatesArray
        driverRequest["distances"] = mapTasks.stepDistances
        let startCoords = [startLatitude, startLongitude]
        driverRequest["startCoords"] = startCoords
        let destinationCoords = [destinationLatitude, destinationLongitude]
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
    
}

extension DriverMainViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWithPlace place: GMSPlace) {
        searchController.active = false
        
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

