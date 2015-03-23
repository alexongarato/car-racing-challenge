//
//  Trace.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 3/20/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
class Trace
{
    class func warning(value:String)
    {
//        #if DEBUG
        if(Configs.DEBUG_MODE)
        {
            NSLog("WARNING -> \(value)");
        }
//        #endif
    }
    
    class func error(value:String)
    {
//        #if DEBUG
        if(Configs.DEBUG_MODE)
        {
            NSLog("ERROR -> \(value)");
        }
//        #endif
    }
    
    class func log(value:String)
    {
//        #if DEBUG
        if(Configs.DEBUG_MODE)
        {
            NSLog(value);
        }
//        #endif
    }
}