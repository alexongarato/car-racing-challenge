//
//  GameHelper.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 15/04/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit

private var _instance:GameHelper!;

class GameHelper
{
    class func getInstance() -> GameHelper
    {
        if(_instance == nil)
        {
            _instance = GameHelper();
        }
        return _instance;
    }
    
    func enemiesForLevel(_ level:Int) -> Array<EnemySheet>!
    {
        if let url:URL = Bundle.main.url(forResource: "Levels",  withExtension:"plist")
        {
            if let dict:NSDictionary = NSDictionary(contentsOf:url)
            {
                if let str = dict.value(forKey: "level\(level)") as? String
                {
                    let sheets = str.components(separatedBy: "-") as Array<String>;
                    var array = Array<EnemySheet>();
                    for i in 0 ..< sheets.count
                    {
                        let sheet = EnemySheet();
                        sheet.build(sheets[i]);
                        array.append(sheet);
                    }
                    print("enemies array count:\(array.count)");
                    return array;
                }
            }
        }
        
        print("enemies array ERROR for level \(level)");
        
        return nil;
    }
}

class EnemySheet
{
    var lineArr:Array<String>!;
    func build(_ str:String)
    {
        self.lineArr = str.components(separatedBy: ".") as Array<String>;
    }
}
