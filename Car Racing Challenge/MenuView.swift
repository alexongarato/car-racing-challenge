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
        self.backgroundColor = UIColor(patternImage: UIImage(named: ImagesNames.MenuBackground)!);
        
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
        self.title.y = self.center.y - (self.height * 0.4);
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
        self.desc.y -= 100;
    }
    
    func setInstructions(scoreToLifeUp:Int, scoreToLevelUp:Int)
    {
        
        var image:UIImage! = UIImage(named: ImagesNames.Instructions);
        var instructions:UIImageView = UIImageView(image: image);
        self.addSubview(instructions);
        instructions.center = self.center;
        instructions.y += 20;
        
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
//            Utils.delayedCall(2, target: target, selector: selector, repeats: false);
//            return;
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
        
        var totalHeight:CGFloat = (newAction.height.half * self.actions.count.floatValue)
        for(var i:Int = 0; i < self.actions.count; i++)
        {
            var action:UILabel = self.actions[i];
            action.y = self.center.y + (self.height * 0.28) - totalHeight + ((action.height + 20) * i.floatValue);
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