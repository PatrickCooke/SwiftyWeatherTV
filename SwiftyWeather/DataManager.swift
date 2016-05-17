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
                self.currentWeather.locLat = loc.coordinate.latitude 
                self.currentWeather.locLon = loc.coordinate.longitude
                let coords = "\(self.currentWeather.locLat),\(self.currentWeather.locLon)"
                self.currentWeather.locCoord = coords
                //print("locCoord = \(self.currentWeather.locCoord)")
                self.getDataFromServer(coords)
            }
        }
    }
    
    func getDataFromServer(coord: String) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        defer {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        let url = NSURL(string: "https://\(baseURL)/forecast/\(API)/\(coord)")
        //print("\(url)")
        let urlRequest = NSURLRequest(URL: url!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        let urlSession = NSURLSession.sharedSession()
        let task = urlSession.dataTaskWithRequest(urlRequest) { (data, response, error) in
            guard let unwrappedData =  data else {
                print("No Data")
                return
            }
            do {
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(unwrappedData, options: .MutableContainers)
                print("Json: \(jsonResult)")
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
    
    func fileIsInDocuments(filename: String) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        return fileManager.fileExistsAtPath(getDocumentPathForFile(filename))
    }
    
    func getDocumentPathForFile(filename: String) -> String {
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        return documentPath.stringByAppendingPathComponent(filename)
    }
    
    private func getImageFromServer(localFilename: String, remoteFilename: String) { 
        let remoteURL = NSURL(string: remoteFilename)
        let imageData = NSData(contentsOfURL: remoteURL!)
        let imageTemp = UIImage(data: imageData!)
        if let _ = imageTemp {
            imageData!.writeToFile(getDocumentPathForFile(localFilename), atomically: false)
        }
    }
    
}
