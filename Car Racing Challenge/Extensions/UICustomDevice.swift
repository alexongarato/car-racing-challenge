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
        let systemVersion:NSString = UIDevice.current.systemVersion as NSString;
        return systemVersion.floatValue >= 8.0;
    }
    
    
    class func avoidTexture() -> Bool
    {
        let systemVersion:NSString = UIDevice.current.systemVersion as NSString;
        let height:Bool = UIScreen.main.applicationFrame.height == 480;
        return systemVersion.floatValue < 8.0 && height;
    }
    /*
    class func getCurrentModel() -> NSString
    {
        var size : UInt = 0;
        sysctlbyname("hw.machine", nil, &size, nil, 0);
        var machine = [CChar](count: Int(size), repeatedValue: 0);
        sysctlbyname("hw.machine", &machine, &size, nil, 0);
        var p:NSString = String.fromCString(machine)!;
        
        if(p.isEqualToString("i386")  || p.isEqualToString("x86_64"))
        {
            if(UIScreen.mainScreen().bounds.width == 320 && UIScreen.mainScreen().bounds.height == 480)
            {
                p = "iPhone3,1";
            }
            else if(UIScreen.mainScreen().bounds.width == 320 && UIScreen.mainScreen().bounds.height > 480)
            {
                p = "iPhone5,4";
            }
            else if(UIScreen.mainScreen().bounds.width == 375)
            {
                p = "iPhone7,2";
            }
            else if(UIScreen.mainScreen().bounds.width > 375)
            {
                p = "iPhone7,1";
            }
        }
        
        //Debugger.trace(p);
        
        return p;
    }
    
    class func isOlder() -> Bool
    {
        var p:NSString = getCurrentModel();
        return (p.isEqualToString("iPhone1,1")
            || p.isEqualToString("iPhone1,2")
            || p.isEqualToString("iPhone2,1")) as Bool;
    }
    
    class func isiPhone4() -> Bool
    {
        var p:NSString = getCurrentModel();
        return (p.isEqualToString("iPhone3,1") || p.isEqualToString("iPhone3,3")) as Bool;
    }
    
    class func isiPhone4S() -> Bool
    {
        var p:NSString = getCurrentModel();
        return (p.isEqualToString("iPhone4,1"));
    }
    
    class func isiPhone4_4S() -> Bool
    {
        var p:NSString = getCurrentModel();
        return (p.isEqualToString("iPhone3,1")
            || p.isEqualToString("iPhone3,3")
            || p.isEqualToString("iPhone4,1")) as Bool;
    }
    
    class func isiPhone5() -> Bool
    {
        var p:NSString = getCurrentModel();
        return (p.isEqualToString("iPhone5,1") || p.isEqualToString("iPhone5,2")) as Bool;
    }
    
    class func isiPhone5C() -> Bool
    {
        var p:NSString = getCurrentModel();
        return (p.isEqualToString("iPhone5,3") || p.isEqualToString("iPhone5,4")) as Bool;
    }
    
    class func isiPhone5S() -> Bool
    {
        var p:NSString = getCurrentModel();
        return (p.isEqualToString("iPhone6,1") || p.isEqualToString("iPhone6,2")) as Bool;
    }
    
    class func isiPhone5_5C_5S() -> Bool
    {
        var p:NSString = getCurrentModel();
        return (p.isEqualToString("iPhone5,1")
            || p.isEqualToString("iPhone5,2")
            || p.isEqualToString("iPhone5,3")
            || p.isEqualToString("iPhone5,4")
            || p.isEqualToString("iPhone6,1")
            || p.isEqualToString("iPhone6,2")) as Bool;
    }
    
    class func isiPhone4_4S_5_5C_5S() -> Bool
    {
        var p:NSString = getCurrentModel();
        return (p.isEqualToString("iPhone3,1")
            || p.isEqualToString("iPhone3,3")
            || p.isEqualToString("iPhone4,1")
            || p.isEqualToString("iPhone5,1")
            || p.isEqualToString("iPhone5,2")
            || p.isEqualToString("iPhone5,3")
            || p.isEqualToString("iPhone5,4")
            || p.isEqualToString("iPhone6,1")
            || p.isEqualToString("iPhone6,2")) as Bool;
    }
    
    class func isiPhone6() -> Bool
    {
        var p:NSString = getCurrentModel();
        return (p.isEqualToString("iPhone7,2")) as Bool;
    }
    
    class func isiPhone6P() -> Bool
    {
        var p:NSString = getCurrentModel();
        return (p.isEqualToString("iPhone7,1")) as Bool;
    }
    
    class func isiPhone6_6P() -> Bool
    {
        var p:NSString = getCurrentModel();
        return (p.isEqualToString("iPhone7,2") || p.isEqualToString("iPhone7,1")) as Bool;
    }

    class func isIOS8OrHigher() -> Bool
    {
        var systemVersion:NSString = UIDevice.currentDevice().systemVersion;
        return systemVersion.floatValue >= 8.0;
    }
    */
}


/*
if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
if ([platform isEqualToString:@"i386"])         return @"Simulator";
if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
*/
