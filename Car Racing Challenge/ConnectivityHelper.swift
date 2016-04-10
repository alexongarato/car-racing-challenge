//
//  ConnectivityHelper.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 25/04/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation

import Foundation
import SystemConfiguration

class ConnectivityHelper
{
    class func isReachable() -> Bool
    {
        var reachability: Reachability;
        do
        {
            reachability = try Reachability.reachabilityForInternetConnection();
        } catch
        {
            NSLog("Unable to create Reachability");
            return false;
        }
        
        return reachability.isReachable();
    }
    
    class func showDefaultOfflineMessage()
    {
        AlertController.getInstance().showAlert("OFFLINE", message: "Please check\nthe internet connection\nand try again.", action: "OK", completion: nil);
    }
}