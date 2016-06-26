//
//  AddressFinder.swift
//  UniRide
//
//  Created by Tuna Onder on 6/17/16.
//  Copyright © 2016 Tuna Onder. All rights reserved.
//

import GoogleMaps

class AddressFinder{
    
    let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
    func getAddressForLatLng(latitude: String, longitude: String) -> String{
        let url = NSURL(string: "\(baseUrl)latlng=\(latitude),\(longitude)")
        let data = NSData(contentsOfURL: url!)
        let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        if let result = json["results"] as? NSArray {
            if let address = result[0]["address_components"]! as? NSArray {
                let number = address[0]["short_name"]! as! String
                let street = address[1]["long_name"]! as! String
                let city = address[2]["short_name"]! as! String
                return "\(number) \(street), \(city)"
            }
        }
        return "Could Not Get the Address"
    }
}

