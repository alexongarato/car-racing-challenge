//
//  MenuView.swift
//  Arcade Car Race
//
//  Created by Alex Ongarato on 21/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit
class LevelUpView: AbstractView
{
    var desc : UILabel!;
    
    override func didMoveToSuperview()
    {
        super.didMoveToSuperview();
        self.enableBlur();
        
        var title:UILabel = UILabel();
        title.text = "ARCADE CAR RACE";
        title.font = Fonts.Digital7Italic(FontSize.Big);
        title.textColor = UIColor.whiteColor();
        title.sizeToFit();
        title.center = self.center;
        title.y = self.center.y - (self.height * 0.3);
        self.addSubview(title);
        
        desc = UILabel();
        desc.text = "START";
        desc.font = Fonts.Digital7Italic(FontSize.Big);
        desc.textColor = UIColor.whiteColor();
        desc.sizeToFit();
        desc.center = self.center;
        desc.y = self.center.y
        self.addSubview(desc);
    }
}