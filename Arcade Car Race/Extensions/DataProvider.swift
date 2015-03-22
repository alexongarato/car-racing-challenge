//
//  DataProvider.swift
//  Infinity Car Race
//
//  Created by Alex Ongarato on 3/20/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import CoreData

private var _private_nsuser_defaults    : NSUserDefaults!;
private var _private_domain             : String = ".cacheDomain";
class DataProvider
{
    class func applicationDidLaunch()
    {
        
        if let bundle = NSBundle.mainBundle().bundleIdentifier
        {
            _private_domain = "\(bundle)\(_private_domain)";
        }
        
        if(_private_nsuser_defaults == nil)
        {
            _private_nsuser_defaults = NSUserDefaults(suiteName: _private_domain);
            
            Trace.log("DataProvider -> initialized \(_private_domain)");
        }
    }
    
    class func createKey(suiteName:NSString, key:NSString) -> String
    {
        return "\(suiteName)-\(key)";
    }
    
    //################## USER DEFAULTS #####################
    class func getString(suiteName:String, key:String) -> String
    {
        var temp:String = "";
        
        if let str = getData(suiteName, key:key) as? String
        {
            temp  = str;
        }
        
        return temp;
    }
    
    class func getData(suiteName:String, key:String) -> AnyObject!
    {
        if let object: AnyObject = _private_nsuser_defaults.objectForKey(createKey(suiteName, key:key))
        {
            return object;
        }
        else
        {
            return nil;
        }
    }
    
    class func getBoolData(suiteName:String, key:String) -> Bool
    {
        let object: Bool = _private_nsuser_defaults.boolForKey(createKey(suiteName, key:key))
        return object;
    }
    
    class func saveData(suiteName:String, key:String, object:AnyObject!) -> Bool
    {
        if(object == nil)
        {
            return false;
        }
        
        _private_nsuser_defaults.setObject(object, forKey: createKey(suiteName, key:key));
        _private_nsuser_defaults.synchronize();
        
        return true;
    }
    
    class func saveData(suiteName:String, key:String, string:NSString!) -> Bool
    {
        if(string == nil)
        {
            return false;
        }
        
        _private_nsuser_defaults.setValue(string, forKey: createKey(suiteName, key:key));
        _private_nsuser_defaults.synchronize();
        
        return true;
    }
    
    class func saveData(suiteName:String, key:String, value:Bool)
    {
        _private_nsuser_defaults.setBool(value, forKey: createKey(suiteName, key:key));
        _private_nsuser_defaults.synchronize();
    }
    
    private class func emptySpaceForName(suiteName:String)
    {
        var keys:NSArray = NSDictionary(dictionary: _private_nsuser_defaults.dictionaryRepresentation()).allKeys;
        
        for (var i:Int = 0; i < keys.count; i++)
        {
            var key:String = keys[i] as! String;
            if(key.hasPrefix(suiteName))
            {
                Trace.warning("removing[\(i)]: \(key)");
                _private_nsuser_defaults.removeObjectForKey(key);
            }
        }
        
        _private_nsuser_defaults.synchronize();
        Trace.warning("DataProvider -> Cache cleaned.");
    }
}