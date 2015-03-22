//
//  MenuView.swift
//  Infinity Car Race
//
//  Created by Alex Ongarato on 21/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit

class MenuView: AbstractView
{
    private var desc        : UITextView!;
    private var title       : UILabel!;
    private var action      : UILabel!;
    private var fontColor   : UIColor = UIColor.blackColor();
    
    override func didMoveToSuperview()
    {
        super.didMoveToSuperview();
        self.enableBlur(UIBlurEffectStyle.Light);
        
        self.title = UILabel();
        self.title.textColor = fontColor;
        self.addSubview(self.title);
        
        self.desc = UITextView();
        self.desc.textColor = fontColor;
        self.addSubview(self.desc);
        
        self.action = UILabel();
        self.action.textColor = fontColor;
        self.addSubview(action);
    }
    
    func setTitle(text:String)
    {
        self.title.text = text;
        self.title.font = Fonts.Digital7Italic(FontSize.Medium);
        self.title.sizeToFit();
        self.title.center = self.center;
        self.title.y = self.center.y - (self.height * 0.3);
    }
    
    func setDescription(text:String)
    {
        self.desc.text = text;
        self.desc.font = Fonts.Digital7Italic(FontSize.Default);
        self.desc.textAlignment = NSTextAlignment.Center;
        self.desc.backgroundColor = UIColor.clearColor();
        self.desc.width = self.width - 30;
        self.desc.height = 100;
        self.desc.center = self.center;
        self.desc.y = self.center.y  - (self.height * 0.1);
    }
    
    func setAction(text:String, target:AnyObject, selector:Selector)
    {
        self.action.text = text;
        self.action.font = Fonts.Digital7Italic(FontSize.Medium);
        self.action.sizeToFit();
        self.action.center = self.center;
        self.action.y = self.center.y + (self.height * 0.2);
        self.action.addTarget(target, selector: selector);
    }
    
    func disableAction()
    {
        self.action.gestureRecognizers?.removeAll(keepCapacity: false);
    }
}