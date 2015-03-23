//
//  UICustomDevice.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 21/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit

class UICustomDevice
{
    class func isIOS8OrHigher() -> Bool
    {
        var systemVersion:NSString = UIDevice.currentDevice().systemVersion;
        return systemVersion.floatValue >= 8.0;
    }
}