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
    init(_ value:String)
    {
        if(Configs.DEBUG_MODE)
        {
            NSLog(value);
        }
    }
}