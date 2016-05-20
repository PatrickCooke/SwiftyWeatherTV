//
//  DataManager.swift
//  SwiftyWeather
//
//  Created by Patrick Cooke on 5/16/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit
import CoreLocation

class DataManager: NSObject {

    static let sharedInstance = DataManager()
    
    var baseURL = "api.forecast.io"
    var API = "ae7b4ae2894051dd473dcb9521444186"
    var currentWeather = Weather()

    
    func geoCoder(addressString: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        defer {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString("\(addressString)") { (placemarks, error) in
            if let placemark = placemarks?[0] {
                guard let addressDict = placemark.addressDictionary else {
                    return
                }
                guard let city = addressDict["City"] else {
                    return
                }
                guard let loc = placemark.location else {
                    return
                }
                self.currentWeather = Weather()
                //print("City: \(city) Lat:\(loc.coordinate.latitude) \(loc.coordinate.longitude)")
                self.currentWeather.curCity = (city) as! String
                self.currentWeather.locLat = loc.coordinate.latitude
                self.currentWeather.locLon = loc.coordinate.longitude
                let coords = "\(self.currentWeather.locLat),\(self.currentWeather.locLon)"
                self.currentWeather.locCoord = coords
                self.getDataFromServer(coords, city: city as! String)
            }
        }
    }
    
    func getDataFromServer(coord: String, city :String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        defer {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        let urlString = "https://\(baseURL)/forecast/\(API)/\(coord)"
        let url = NSURL(string: urlString)
        let urlRequest = NSURLRequest(URL: url!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
        let urlSession = NSURLSession.sharedSession()
        let task = urlSession.dataTaskWithRequest(urlRequest) { (data, response, error) in
            guard let unwrappedData =  data else {
                print("No Data")
                return
            }
            do {
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(unwrappedData, options: .MutableContainers)
//                print("Json: \(jsonResult)")
                self.currentWeather.curCity = city
                let tempWeatherDict = jsonResult.objectForKey("currently") as! NSDictionary
                self.currentWeather.curSummary = tempWeatherDict.objectForKey("summary") as! String
                self.currentWeather.curTemp = tempWeatherDict.objectForKey("temperature") as! Double
                self.currentWeather.curAppTemp = tempWeatherDict.objectForKey("apparentTemperature") as! Double
                self.currentWeather.curPrecip = tempWeatherDict.objectForKey("precipProbability") as! Double
                self.currentWeather.curHumid = tempWeatherDict.objectForKey("humidity") as! Double
                self.currentWeather.curIcon = tempWeatherDict.objectForKey("icon") as! String
                self.currentWeather.curWind = tempWeatherDict.objectForKey("windSpeed") as! Double
                
                let tempWeatherDict2 = jsonResult.objectForKey("daily") as! NSDictionary
                self.currentWeather.dailySummary = tempWeatherDict2.objectForKey("summary") as! String

                
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "recvNewDataFromServer", object: nil))
                })
            } catch {
                print("JSON Parsing Error")
            }
            
        }
        task.resume()
        
    }
    
}
