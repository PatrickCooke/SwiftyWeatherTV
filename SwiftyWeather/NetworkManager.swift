//
//  NetworkManager.swift
//  SwiftyWeather
//
//  Created by Patrick Cooke on 5/16/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

import UIKit

class NetworkManager: NSObject {
    static let sharedInstance = NetworkManager()     
    var serverReach :Reachability?
    var serverAvailable = false
    
    func reachabilityChanged(note: NSNotification) {
        let reach = note.object as! Reachability
        serverAvailable = !(reach.currentReachabilityStatus().rawValue == NotReachable.rawValue)
        if serverAvailable {
            print("Server Available")
        } else {
            print("Server NOT Available")
        }
    }
    
    override init() {
        super.init()
        print("Starting Network Manager")
        let dataManager = DataManager.sharedInstance
        serverReach = Reachability(hostname: dataManager.baseURL)
        serverReach?.startNotifier()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reachabilityChanged(_:)), name: kReachabilityChangedNotification, object: nil)
    }


}
