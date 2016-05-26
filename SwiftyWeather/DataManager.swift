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
                //print("Json: \(jsonResult)")
                self.currentWeather.curCity = city
                let tempWeatherDict = jsonResult.objectForKey("currently") as! NSDictionary
                self.currentWeather.curSummary = tempWeatherDict.objectForKey("summary") as! String
                self.currentWeather.curTemp = tempWeatherDict.objectForKey("temperature") as! Double
                self.currentWeather.curAppTemp = tempWeatherDict.objectForKey("apparentTemperature") as! Double
                self.currentWeather.curPrecip = tempWeatherDict.objectForKey("precipProbability") as! Double
                self.currentWeather.curHumid = tempWeatherDict.objectForKey("humidity") as! Double
                self.currentWeather.curIcon = tempWeatherDict.objectForKey("icon") as! String
                self.currentWeather.curWind = tempWeatherDict.objectForKey("windSpeed") as! Double
                
                let hourlyWeatherDict = jsonResult.objectForKey("hourly") as! NSDictionary
                self.currentWeather.hourlySummary = hourlyWeatherDict.objectForKey("summary") as! String
                
                let dailyWeatherDict = jsonResult.objectForKey("daily") as! NSDictionary
                //print("\(dailyWeatherDict)")
                self.currentWeather.dailySummary = dailyWeatherDict.objectForKey("summary") as! String
                let dataDailyArray = dailyWeatherDict.objectForKey("data") as! [NSDictionary]
                //print("\(dataDailyArray)")
                
                
                var dailyWArray = [DailyWeather]()
                for dayWeatherDict in dataDailyArray {
                
                    let dailyW = DailyWeather()
                    let tempMax = dayWeatherDict.objectForKey("temperatureMax")
                    //print("Max: \(tempMax)")
                    dailyW.dayMaxTemp = tempMax as! Double
                    let tempMin = dayWeatherDict.objectForKey("temperatureMin")
                    dailyW.dayMinTemp = tempMin as! Double
                    let odds = dayWeatherDict.objectForKey("precipProbability")
                    dailyW.precipOdds = odds as! Double
                    let type = dayWeatherDict.objectForKey("precipType")
                    dailyW.precipType = type as! String
                    let time = dayWeatherDict.objectForKey("time")
                    dailyW.time = time as! Double
                    let summary = dayWeatherDict.objectForKey("summary")
                    dailyW.daysum = summary as! String
                   
                    
                    dailyWArray.append(dailyW)
                }
                self.currentWeather.dailyforcast = dailyWArray
                print("Got \(self.currentWeather.dailyforcast)")
                //print("Got \(DailyWeather.valueForKey("precipType"))") <- This Errored Out... does not a key value for "precipType"
                
                
                
/*                //What do I do here????????????????????????????????
                
                let tempDict = dataDailyArray.firstObject as! NSArray
                for ???? in tempDict {
                   self.currentWeather.dailyMax =
                }
                
                print(self.currentWeather.dailyMax) 
 */
                

                
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
