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
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0));
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress));
        zeroAddress.sin_family = sa_family_t(AF_INET);
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue();
        }
        
        var flags: SCNetworkReachabilityFlags = 0;
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0
        {
            return false;
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0;
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0;
        let connected = (isReachable && !needsConnection) ? true : false;
        
        return connected;
    }
    
    class func showDefaultOfflineMessage()
    {
        AlertController.getInstance().showAlert(title: "OFFLINE", message: "Please check\nthe internet connection\nand try again.", action: "OK", completion: nil);
    }
}