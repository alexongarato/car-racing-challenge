//
//  Extensions.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 21/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import SpriteKit

extension SKNode
{
    var x:CGFloat{get{return self.position.x;} set(value){self.position.x = value;}};
    var y:CGFloat{get{return self.position.y;} set(value){self.position.y = value;}};
}

extension SKSpriteNode
{
    var height:CGFloat{get{return self.size.height;} set(value){self.size.height = value;}};
    var width:CGFloat{get{return self.size.width;} set(value){self.size.width = value;}};
}

/*
extension SKScene
{
    var height:CGFloat{get{return self.size.height;} set(value){self.size.height = value;}};
    var width:CGFloat{get{return self.size.width;} set(value){self.size.width = value;}};
}
*/

class Pixel
{
    var active:Bool = false;
    var x:CGFloat = 0;
    var y:CGFloat = 0;
    
    init(x:CGFloat, y:CGFloat, active:Bool)
    {
        self.x = x;
        self.y = y;
        self.active = active;
    }
}

class CustomSpriteNode:SKSpriteNode
{
    var isTouched:Bool = false;
    var isDead:Bool = false;
}
