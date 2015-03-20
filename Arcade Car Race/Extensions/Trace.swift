//
//  Trace.swift
//  Arcade Car Race
//
//  Created by Alex Ongarato on 3/20/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
class Trace
{
    class func warning(value:String)
    {
        NSLog("WARNING -> \(value)");
    }
    
    class func error(value:String)
    {
        NSLog("ERROR -> \(value)");
    }
    
    class func log(value:String)
    {
        NSLog(value);
    }
}