//
//  ViewController.swift
//  SwiftyWeather
//
//  Created by Patrick Cooke on 5/16/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var dataManager = DataManager.sharedInstance
    var networkManager = NetworkManager.sharedInstance
    @IBOutlet weak var LocationLabel    :UILabel!
    @IBOutlet weak var currentTempLabel :UILabel!
    @IBOutlet weak var feelsLikeLabel   :UILabel!
    @IBOutlet weak var windSpeedLabel   :UILabel!
    @IBOutlet weak var precipLabel      :UILabel!
    @IBOutlet weak var iconImageView    :UIImageView!
    @IBOutlet weak var addressSearchBar :UISearchBar!
    @IBOutlet weak var summaryTxtView   :UITextView!

    
    //MARK: - Data Methods
    
    @IBAction private func getButtonPressed(sender: UIBarButtonItem) {
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
    
    func fillEverythingOut() {
        if let currentTemp = dataManager.currentWeather.curTemp{
            currentTempLabel.text = String(currentTemp)
        }
        if let apptemp = dataManager.currentWeather.curAppTemp {
        feelsLikeLabel.text = String(apptemp)
        }
        if let windspeed = dataManager.currentWeather.curWind {
            windSpeedLabel.text = "\(windspeed) mph"
        }
        if let currentPrecip = dataManager.currentWeather.curPrecip {
            precipLabel.text = String(currentPrecip)
        }
        iconImageView.image = UIImage (named: dataManager.currentWeather.curIcon)
        if let currentSummary = dataManager.currentWeather.curSummary {
            if let dailysummary = dataManager.currentWeather.dailySummary{
            summaryTxtView.text = "The current weather is: " + currentSummary + ". Today's weather will: " + dailysummary
            }
        }
    }
    
    func newDataRecv() {
        print("reloading data")
        fillEverythingOut()
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newDataRecv), name: "recvNewDataFromServer", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

