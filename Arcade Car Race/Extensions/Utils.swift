//
//  Utils.swift
//  Arcade Car Race
//
//  Created by Alex Ongarato on 17/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
class Utils
{
    class func random(i:Int) -> Int
    {
        return Int(arc4random_uniform(UInt32(1+i)));
    }
}

