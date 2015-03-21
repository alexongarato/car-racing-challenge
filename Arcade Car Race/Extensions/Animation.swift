//
//  Animation.swift
//  Arcade Car Race
//
//  Created by Alex Ongarato on 21/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation

struct AnimationTime
{
    /** 1.00 sec */
    static var VerySlow : NSTimeInterval = 1.00;
    /** 0.50 secs */
    static var Slow     : NSTimeInterval = 0.50;
    /** 0.30 secs */
    static var Default  : NSTimeInterval = 0.30;//0.30
    /** 0.25 secs */
    static var Fast     : NSTimeInterval = 0.25;
    /** 0.20 secs */
    static var VeryFast : NSTimeInterval = 0.20;
}

enum AnimationStyle:Int
{
    case Scale     = 1
    case SlideUp   = 2
};