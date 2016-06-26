//
//  DriverMapTasks.swift
//  UniRide
//
//  Created by Tuna Onder on 2/25/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import GoogleMaps

class DriverMapTasks: NSObject  {
    
    
    //The following URL modifies the previous request such that the journey is routed through Lexington without stopping:
    //https://maps.googleapis.com/maps/api/directions/json?origin=Boston,MA&destination=Concord,MA&waypoints=Charlestown,MA|via:Lexington,MA&key=YOUR_API_KEY
    
    //Optimize waypoints:
    //ttps://maps.googleapis.com/maps/api/directions/json?origin=Adelaide,SA&destination=Adelaide,SA&waypoints=optimize:true|Barossa+Valley,SA|Clare,SA|Connawarra,SA|McLaren+Vale,SA&key=YOUR_API_KEY
    
    
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var selectedRoute: Dictionary<NSObject, AnyObject>!
    
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    
    var originCoordinate: CLLocationCoordinate2D!
    
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var tempCoordinate: CLLocationCoordinate2D!
    
    var originAddress: String!
    
    var destinationAddress: String!
    
    
    var steps = Array<Dictionary<NSObject, AnyObject>>!()
    
    //ALL COORDINATES
    var stepCoordinates = [CLLocationCoordinate2D]()
    
    var coordinatesArray = [Double]()
    var coordinatesArray2D = [CLLocationCoordinate2D]()
    
    
    var totalDistanceInMeters: UInt = 0
    
    var totalDistance: String!
    
    var totalDurationInSeconds: UInt = 0
    
    var totalDuration: String!
    
    
    
    
    
    override init() {
        super.init()
    }
    
    
    
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: AnyObject!, completionHandler: ((status: String, success: Bool) -> Void)) {
        if let originLocation = origin {
            if let destinationLocation = destination {
                
                
                var wayPointData = ""
                if waypoints != nil {
                    for waypoint in waypoints {
                        wayPointData = wayPointData + waypoint + "|"
                    }
                }
                
                
                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&waypoints=optimize:true|" + wayPointData
                
                directionsURLString = directionsURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
                //  print(directionsURLString)
                
                let directionsURL = NSURL(string: directionsURLString)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let directionsData = NSData(contentsOfURL: directionsURL!)
                    
                    do {
                        let dictionary: Dictionary<NSObject, AnyObject> = try NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>
                        
                        let status = dictionary["status"] as! String
                        
                        if status == "OK" {
                            self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<NSObject, AnyObject>>)[0]
                            self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<NSObject, AnyObject>
                            
                            
                            let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
                            
                            
                            let startLocationDictionary = legs[0]["start_location"] as! Dictionary<NSObject, AnyObject>
                            
                            
                            self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                            
                            
                            let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<NSObject, AnyObject>
                            self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                            
                            
                            for leg in legs {
                                let steps = leg["steps"] as! Array<Dictionary<NSObject, AnyObject>>
                                for step in steps{
                                    
                                    let startLocations = step["start_location"] as! Dictionary<NSObject, AnyObject>
                                    /*       self.tempCoordinate = CLLocationCoordinate2DMake(startLocations["lat"] as! Double, startLocations["lng"] as! Double)
                                     if let coordinate = self.tempCoordinate {
                                     self.stepCoordinates.append(coordinate)
                                     
                                     }*/
                                    
                                    
                                    
                                    
                                    
                                    ////////
                                    let x = startLocations["lat"] as! Double
                                    let y = startLocations["lng"] as! Double
                                    self.coordinatesArray.append(x)
                                    self.coordinatesArray.append(y)
                                    
                                    
                                    
                                    
                                    //Calculate Step DISTANCE from google maps!
                                    let distance = step["distance"] as! Dictionary<NSObject, AnyObject>
                                    let distanceValue = distance["value"] as! Double
                                    print("Step distance: \(distanceValue)")
                                    
                                    let stepEndDic = step["end_location"] as! Dictionary<NSObject, AnyObject>
                                    
                                    
                                    let x2 = stepEndDic["lat"] as! Double
                                    let y2 = stepEndDic["lng"] as! Double
                                    
                                    let stepHead:CLLocation = CLLocation(latitude: x, longitude: y)
                                    let stepEnd:CLLocation = CLLocation(latitude: x2, longitude: y2)
                                    
                                    //Perpendicular Distance of step head and step end
                                    let coordinateSystemDistance:CLLocationDistance = stepHead.distanceFromLocation(stepEnd)
                                    print("Coordinate System Distance: \(coordinateSystemDistance)")
                                    
                                    
                                    
                                    //DECRYPTION-----------------
                                    let polyline = step["polyline"] as! Dictionary<NSObject, AnyObject>
                                    let encryptedString = polyline["points"] as! String
                                    
                                    
                                    
                                    //  var stepCoordinates = [CLLocationCoordinate2D]()
                                    //  var poly = Polyline.init(encodedPolyline: encryptedString)
                                    
                                    self.coordinatesArray2D.appendContentsOf(decodePolyline(encryptedString)!)
                                    //     print("length=\(stepCoordinates.count)")
                                    //      print(stepCoordinates[stepCoordinates.count-1])
                                    
                                    
                                    //---------------------
                                    
                                    
                                }
                                
                                
                                
                                
                                
                            }
                            
                            // self.stepCoordinates.append(self.destinationCoordinate)
                            
                            
                            
                            
                            //////
                            let x = endLocationDictionary["lat"] as! Double
                            let y = endLocationDictionary["lng"] as! Double
                            self.coordinatesArray.append(x)
                            self.coordinatesArray.append(y)
                            ///////
                            
                            
                            self.originAddress = legs[0]["start_address"] as! String
                            self.destinationAddress = legs[legs.count - 1]["end_address"] as! String
                            
                            //    print(self.originAddress)
                            //    print(self.destinationAddress)
                            
                            self.calculateTotalDistanceAndDuration()
                            
                            completionHandler(status: status, success: true)
                        }
                        else {
                            completionHandler(status: status, success: false)
                        }
                        
                        
                        
                    } catch let error as NSError {
                        print(error)
                        completionHandler(status: "", success: false)
                    }
                    
                    
                    
                    
                    
                })
                
            }
            else {
                completionHandler(status: "Destination is nil.", success: false)
            }
        }
        else {
            completionHandler(status: "Origin is nil", success: false)
        }
        
        
        
        
        
    }
    
    func calculateTotalDistanceAndDuration() {
        let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
        
        totalDistanceInMeters = 0
        totalDurationInSeconds = 0
        
        for leg in legs {
            totalDistanceInMeters += (leg["distance"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
            totalDurationInSeconds += (leg["duration"]as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
        }
        
        
        let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
        totalDistance = "Total Distance: \(distanceInKilometers) Km"
        
        
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        totalDuration = "Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
    }
    
    
    
    
}
