//
//  ImageHelper.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 3/25/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit

class ImageHelper
{
    class func imageWithName(name:String) -> UIImage!
    {
        return UIImage(named: name);
    }
}

struct ImagesNames
{
    static var PixelOn:String = "PixelOn";
    static var PixelOff:String = "PixelOff";
    static var Background:String = "Background";
    static var MenuBackground:String = "MenuBG";
    static var Podium:String = "Podium";
    static var Instructions:String = "Instructions";
}