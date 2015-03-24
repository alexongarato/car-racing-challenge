//
//  MenuView.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 21/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit

class MenuView: AbstractView
{
    private var desc        : UITextView!;
    private var title       : UITextView!;
    private var instructs   : UITextView!;
    private var action      : UILabel!;
    private var fontColor   : UIColor = UIColor.blackColor();
    
    override func didMoveToSuperview()
    {
        super.didMoveToSuperview();
        self.enableBlur(UIBlurEffectStyle.Light);
        
        self.title = UITextView();
        self.title.textColor = fontColor;
        self.addSubview(self.title);
        self.title.editable = false;
        
        self.desc = UITextView();
        self.desc.textColor = fontColor;
        self.addSubview(self.desc);
        self.desc.editable = false;
        self.desc.layer.borderWidth = 1;
        
        self.instructs = UITextView();
        self.instructs.textColor = fontColor;
        self.addSubview(self.instructs);
        self.instructs.editable = false;
        self.instructs.layer.borderWidth = 1;
        
        self.action = UILabel();
        self.action.textColor = fontColor;
        self.addSubview(action);
    }
    
    func setTitle(text:String)
    {
        self.title.text = text;
        self.title.font = Fonts.Digital7Italic(FontSize.Big);
        self.title.textAlignment = NSTextAlignment.Center;
        self.title.backgroundColor = UIColor.clearColor();
        self.title.sizeToFit();
        self.title.width = self.width - 10;
        self.title.center = self.center;
        self.title.y = self.center.y - (self.height * 0.4);
    }
    
    func setDescription(text:String, scoreToLifeUp:Int, scoreToLevelUp:Int)
    {
        self.desc.text = text;
        self.desc.font = Fonts.Digital7Italic(FontSize.Default);
        self.desc.textAlignment = NSTextAlignment.Center;
        self.desc.backgroundColor = UIColor.clearColor();
        self.desc.sizeToFit();
        self.desc.width = self.width - 10;
        self.desc.center = self.center;
        
        self.instructs.text = "instructions\nscore \(scoreToLifeUp) = 1 life each\nscore \(scoreToLevelUp) = level up";
        self.instructs.font = Fonts.Digital7Italic(FontSize.Small);
        self.instructs.textAlignment = NSTextAlignment.Center;
        self.instructs.backgroundColor = UIColor.clearColor();
        self.instructs.sizeToFit();
        self.instructs.width = self.width - 10;
        self.instructs.center = self.center;
        self.instructs.y = self.desc.y + self.desc.height + 5;
    }
    
    func setAction(text:String!, target:AnyObject, selector:Selector)
    {
        if(action == nil)
        {
            Utils.delayedCall(2, target: target, selector: selector, repeats: false);
            return;
        }
        
        self.action.text = text;
        self.action.font = Fonts.Digital7Italic(FontSize.Medium);
        self.action.textAlignment = NSTextAlignment.Center;
        self.action.sizeToFit();
        self.action.width = self.width - 10;
        self.action.center = self.center;
        self.action.y = self.center.y + (self.height * 0.3);
        self.action.addTarget(target, selector: selector);
    }
    
    func disableAction()
    {
        self.action.gestureRecognizers?.removeAll(keepCapacity: false);
    }
}