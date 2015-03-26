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
    private var actions     : Array<UILabel>!;
    private var fontColor   : UIColor = UIColor.blackColor();
    
    override func didMoveToSuperview()
    {
        super.didMoveToSuperview();
//        self.enableBlur(UIBlurEffectStyle.Light);
        
        if(self.width == 375)
        {
            self.backgroundColor = UIColor(patternImage: UIImage(named: ImagesNames.MenuBackgroundiPhone6)!);
        }
        else
        {
            self.backgroundColor = UIColor(patternImage: UIImage(named: ImagesNames.MenuBackground)!);
        }
        
        self.title = UITextView();
        self.title.textColor = fontColor;
        self.addSubview(self.title);
        self.title.editable = false;
        
        self.desc = UITextView();
        self.desc.textColor = fontColor;
        self.addSubview(self.desc);
        self.desc.editable = false;
        
        self.instructs = UITextView();
        self.instructs.textColor = fontColor;
        self.addSubview(self.instructs);
        self.instructs.editable = false;
    }
    
    func setTitle(text:String)
    {
        self.title.text = text;
        self.title.font = Fonts.DefaultFont(FontSize.Big);
        self.title.textAlignment = NSTextAlignment.Center;
        self.title.backgroundColor = UIColor.clearColor();
        self.title.sizeToFit();
        self.title.width = self.width - 10;
        self.title.center = self.center;
        if(self.height > 480)
        {
            self.title.y = self.height * 0.1;
        }
        else
        {
            self.title.y = self.center.y - (self.height * 0.41);
        }
        
    }
    
    func setDescription(text:String)
    {
        self.desc.text = text;
        self.desc.font = Fonts.DefaultFont(FontSize.Default);
        self.desc.textAlignment = NSTextAlignment.Center;
        self.desc.backgroundColor = UIColor.clearColor();
        self.desc.sizeToFit();
        self.desc.width = self.width - 10;
        self.desc.center = self.center;
        if(self.height > 480)
        {
            self.desc.y = self.center.y - (self.height * 0.26);
        }
        else
        {
            self.desc.y = self.title.y + self.title.height;
        }
    }
    
    func setInstructions(scoreToLifeUp:Int, scoreToLevelUp:Int)
    {
        var image:UIImage! = UIImage(named: ImagesNames.Instructions);
        var instructions:UIImageView = UIImageView(image: image);
        self.addSubview(instructions);
        instructions.center = self.center;
        if(self.height <= 480)
        {
            if(self.desc != nil)
            {
                instructions.y = self.desc.y + self.desc.height + 10;
            }
        }
        
        self.instructs.text = "each \(scoreToLifeUp) points earned = 1 life up";
        self.instructs.font = Fonts.DefaultFont(FontSize.Tiny);
        self.instructs.textAlignment = NSTextAlignment.Center;
        self.instructs.backgroundColor = UIColor.clearColor();
        self.instructs.sizeToFit();
        self.instructs.width = self.width - 10;
        self.instructs.center = self.center;
        self.instructs.y = instructions.y + instructions.height - 41;
        
    }
    
    func setGameOver()
    {
        var image:UIImage! = UIImage(named: ImagesNames.Podium);
        var podium:UIImageView = UIImageView(image: image);
        self.addSubview(podium);
        podium.center = self.center;
        podium.y += 20;
        podium.addTarget(self, selector: Selector("openGameCenter"));
    }
    
    func openGameCenter()
    {
        Trace.log("MenuView -> open game center");
        GameCenterController.loadLeaderboard();
    }
    
    func setAction(text:String!, target:AnyObject, selector:Selector)
    {
        if(self.actions == nil)
        {
            self.actions = Array<UILabel>();
        }
        
        var newAction:UILabel = UILabel();
        newAction.textColor = fontColor;
        self.addSubview(newAction);
        self.actions.append(newAction);
        
        newAction.text = text;
        newAction.font = Fonts.DefaultFont(FontSize.Medium);
        newAction.textAlignment = NSTextAlignment.Center;
        newAction.sizeToFit();
        newAction.width = self.width - 10;
        newAction.center = self.center;
        newAction.addTarget(target, selector: selector);
        
        var totalHeight:CGFloat = ((newAction.height + 10) * self.actions.count.floatValue);
        for(var i:Int = 0; i < self.actions.count; i++)
        {
            var action:UILabel = self.actions[i];
            /*if(self.instructs != nil)
            {
//                action.center.y = self.instructs.y + self.instructs.height + (self.height - self.instructs.y + self.instructs.height).half - (action.height * i.floatValue) - 30;
                action.center.y = self.instructs.y + self.instructs.height + 40 + (action.height * i.floatValue);
            }
            else
            {*/
            
            if(self.height > 480)
            {
                action.y = self.height * 0.82 - totalHeight + ((action.height + 20) * i.floatValue);
            }
            else
            {
                action.y = self.height * 0.94 - totalHeight + ((action.height + 20) * i.floatValue);
            }
            
            //}
        }
    }
    
    func disableAction()
    {
        for(var i:Int = 0; i < self.actions.count; i++)
        {
            var action:UILabel = self.actions[i];
            action.gestureRecognizers?.removeAll(keepCapacity: false);
        }
    }
}