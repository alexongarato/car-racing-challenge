//
//  Fonts.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 21/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit

class Fonts
{
    static func Digital7Italic(size:CGFloat) -> UIFont!
    {
        return UIFont(name: "Digital-7MonoItalic", size: size)!;
    }
}

struct FontSize
{
    /**
    8px
    */
    static var Tiny        : CGFloat = 8;
    /**
    15px
    */
    static var Small        : CGFloat = 13;
    /** 
    20px 
    */
    static var Default     : CGFloat = 20;
    /** 
    30px 
    */
    static var Medium      : CGFloat = 30;
    /** 
    40px 
    */
    static var Big         : CGFloat = 40;
}