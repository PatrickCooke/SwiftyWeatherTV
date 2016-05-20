//
//  ViewController.swift
//  SwiftyWeather
//
//  Created by Patrick Cooke on 5/16/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var dataManager = DataManager.sharedInstance
    var networkManager = NetworkManager.sharedInstance
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    @IBOutlet weak var LocationLabel    :UILabel!
    @IBOutlet weak var currentTempLabel :UILabel!
    @IBOutlet weak var feelsLikeLabel   :UILabel!
    @IBOutlet weak var windSpeedLabel   :UILabel!
    @IBOutlet weak var precipLabel      :UILabel!
    @IBOutlet weak var iconImageView    :UIImageView!
    @IBOutlet weak var addressSearchBar :UISearchBar!
    @IBOutlet weak var summaryTxtView   :UITextView!
    private var locArray = [Locations]()
    @IBOutlet weak var locTableView     :UITableView!

    
    
    //MARK: - Table Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let storedCity = locArray[indexPath.row]
        cell.textLabel!.text = storedCity.locDescription
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let objToDelete = locArray[indexPath.row]
            managedObjectContext.deleteObject(objToDelete)
            appDelegate.saveContext()
            loadLocArray()
            locTableView!.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let objectslected = locArray[indexPath.row]
        if let lat = objectslected.locLat {
            if let lon = objectslected.locLon {
                let coords = "\(lat),\(lon)"
                if let city = objectslected.locDescription {
                print("Pre \(coords)")
                dataManager.getDataFromServer(coords, city: city)
                }
            }
        }
    }
    
    
    
    //MARK: - Interactivity
    
    func fetchEntries() -> [Locations]? {
        let fetchRequest = NSFetchRequest(entityName: "Locations")
        print("fetch")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "locDescription", ascending: true)]
        do {
            let tempArray = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Locations]
            return tempArray
        }catch {
            return nil
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        performGeocode()
        addressSearchBar.resignFirstResponder()
        addressSearchBar.text = ""
    }
    
    private func loadLocArray() {
         locArray = fetchEntries()!
    }
    
    @IBAction private func saveLocationPressed () {
        let entityDescription = NSEntityDescription.entityForName("Locations", inManagedObjectContext: managedObjectContext)!
        let searchedCity = Locations(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
        searchedCity.locDescription = dataManager.currentWeather.curCity
        searchedCity.locLat = String(dataManager.currentWeather.locLat)
        searchedCity.locLon = String(dataManager.currentWeather.locLon)
        searchedCity.dateEntered = NSDate()
        appDelegate.saveContext()
        loadLocArray()
        locTableView!.reloadData()
        
    }
    
    private func performGeocode() {
        if networkManager.serverAvailable{
            if let address = addressSearchBar.text {
                dataManager.geoCoder(address)
            } else {
                print("Hey type something first")
            }
        } else {
            print("server not available at get")
        }
    }
    
    @IBAction private func getButtonPressed(sender: UIBarButtonItem) {
        addressSearchBar.resignFirstResponder()
        addressSearchBar.text = ""
        performGeocode()
    }
    
    func fillEverythingOut() {
        if let currentCity = dataManager.currentWeather.curCity{
            LocationLabel.text = currentCity
        }
        if let currentTemp = dataManager.currentWeather.curTemp{
            let curTemp = Int(currentTemp)
            currentTempLabel.text = ("\(curTemp)°F")
        }
        if let apptemp = dataManager.currentWeather.curAppTemp {
            let estimateTemp = Int(apptemp)
        feelsLikeLabel.text = ("\(estimateTemp) °F")
        }
        if let windspeed = dataManager.currentWeather.curWind {
            let windspeed2 = Int(windspeed)
            windSpeedLabel.text = "\(windspeed2) mph"
        }
        if let currentPrecip = dataManager.currentWeather.curPrecip {
            let precip = Int(currentPrecip * 100)
            precipLabel.text = "\(precip)%"
        }
        if let currentIcon = dataManager.currentWeather.curIcon {
            iconImageView.image = UIImage (named: currentIcon)
        }
        if let currentSummary = dataManager.currentWeather.curSummary {
            if let dailysummary = dataManager.currentWeather.dailySummary{
            summaryTxtView.text = "The current weather is: " + currentSummary + ". Upcoming: " + dailysummary
            }
        }
    }
    
    private func blankeverything() {
        LocationLabel.text = ""
        currentTempLabel.text = ""
        feelsLikeLabel.text = ""
        windSpeedLabel.text = ""
        precipLabel.text = ""
        iconImageView.image = nil
        summaryTxtView.text = ""
    }
    
     //MARK: - Data Methods
    
    func newDataRecv() {
        print("reloading data")
        blankeverything()
        fillEverythingOut()
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newDataRecv), name: "recvNewDataFromServer", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadLocArray()
        locTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

