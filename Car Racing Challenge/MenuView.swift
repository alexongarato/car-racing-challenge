//
//  MenuView.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 21/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit
import iAd

class MenuView: AbstractView, ADBannerViewDelegate
{
    private var desc        : UITextView!;
    private var title       : UITextView!;
//    private var instructs   : UITextView!;
    private var actions     : Array<UILabel>!;
    private var fontColor   : UIColor = UIColor.blackColor();
    private var scaleFactor : CGFloat = 1;
    private var _bannerView : ADBannerView!;
    private var _adLoaded   : Bool = false;
    
    override func didMoveToSuperview()
    {
        self.buildBanner();
        
        super.didMoveToSuperview();
        var img:UIImage! = UIImage(named: ImagesNames.Background)!;
        var imgView:UIImageView = UIImageView(image: img);
        imgView.frame = self.frame;
        self.addSubview(imgView)
        
        self.title = UITextView();
        self.title.textColor = fontColor;
        self.addSubview(self.title);
        self.title.editable = false;
        
        self.desc = UITextView();
        self.desc.textColor = fontColor;
        self.addSubview(self.desc);
        self.desc.editable = false;
        
//        self.instructs = UITextView();
//        self.instructs.textColor = fontColor;
//        self.addSubview(self.instructs);
//        self.instructs.editable = false;
        
        if(self.width > 375 && self.width < 414)
        {
            self.scaleFactor = 2;
        }
        if(self.width > 414)
        {
            self.scaleFactor = 3;
        }
        
//        self.title.layer.borderWidth = 1;
//        self.desc.layer.borderWidth = 1;
//        self.instructs.layer.borderWidth = 1;
        
//        self.showBanner();
    }
    
    //-------- banner functions --------------------
    private func buildBanner()
    {
        // On iOS 6 ADBannerView introduces a new initializer, use it when available.
        if(ADBannerView.instancesRespondToSelector(Selector("initWithAdType:")))
        {
            Trace.log("ADAdType banner");
            _bannerView = ADBannerView(adType: ADAdType.Banner);
        }
        else
        {
            Trace.log("no ADAdType");
            _bannerView = ADBannerView();
        }
        
        _bannerView.delegate = self;
    }
    
    func showBanner()
    {
        Trace.log("ShowBanner");
        
        var bannerFrame:CGRect = _bannerView.frame;
        if (_bannerView.bannerLoaded)
        {
            Trace.log("banner loaded");
            
            _bannerView.y = self.height - _bannerView.height;
            self.addSubview(_bannerView);
        }
        else
        {
            Trace.log("banner not loaded");
        }
    }
    
    func bannerViewDidLoadAd(banner:ADBannerView)
    {
        Trace.log("bannerViewDidLoadAd");
        if(!_adLoaded)
        {
            _adLoaded = true;
            self.showBanner();
        }
    }
    
    private func bannerView(banner:ADBannerView, didFailToReceiveAdWithError:NSError)
    {
        Trace.log("didFailToReceiveAdWithError");
    }
    
    private func bannerViewActionShouldBegin(banner:ADBannerView, willLeaveApplication:Bool) -> Bool
    {
        Trace.log("bannerViewActionShouldBegin");
        return true;
    }
    
    private func bannerViewActionDidFinish(banner:ADBannerView)
    {
        Trace.log("bannerViewActionDidFinish");
    }
    //---------------------------------
    
    
    func setTitle(text:String)
    {
        self.title.text = text;
        self.title.font = Fonts.DefaultFont(FontSize.Big * self.scaleFactor);
        self.title.textAlignment = NSTextAlignment.Center;
        self.title.backgroundColor = UIColor.clearColor();
        self.title.sizeToFit();
        self.title.width = self.width - 10;
        self.title.center = self.center;
        self.title.y = self.center.y - (self.height * 0.41);
        
    }
    
    func setDescription(text:String)
    {
        self.desc.text = text;
        self.desc.font = Fonts.DefaultFont(FontSize.Default * self.scaleFactor);
        self.desc.textAlignment = NSTextAlignment.Center;
        self.desc.backgroundColor = UIColor.clearColor();
        self.desc.sizeToFit();
        self.desc.width = self.width - 10;
        self.desc.center = self.center;
        self.desc.y = self.title.y + self.title.height - 10;
    }
    
    func setInstructions(scoreToLifeUp:Int, scoreToLevelUp:Int)
    {
        var image:UIImage! = ImageHelper.imageScaledToFit(UIImage(named: ImagesNames.Instructions), sizeToFit: self.frame.size);
        var instructions:UIImageView = UIImageView(image: image);
        self.addSubview(instructions);
        instructions.center = self.center;
        if(self.height <= 480)
        {
            instructions.y += 20;
        }
        
//        self.instructs.text = "each \(scoreToLifeUp) points earned = 1 life up";
//        self.instructs.font = Fonts.DefaultFont(FontSize.Tiny * self.scaleFactor);
//        self.instructs.textAlignment = NSTextAlignment.Center;
//        self.instructs.backgroundColor = UIColor.clearColor();
//        self.instructs.sizeToFit();
//        self.instructs.width = self.width - 10;
//        self.instructs.center = self.center;
//        self.instructs.y = instructions.y + instructions.height - 41;
        
    }
    
    func setGameOver()
    {
        var image:UIImage! = UIImage(named: ImagesNames.Podium);
        var podium:UIImageView = UIImageView(image: image);
        self.addSubview(podium);
        podium.center = self.center;
        if(self.height > 480)
        {
            podium.y -= 20;
        }
        else
        {
            podium.y -= self.y;
        }
        podium.addTarget(self, selector: Selector("openGameCenter"));
    }
    
    func openGameCenter()
    {
        Trace.log("MenuView -> MenuView -> open game center");
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
        newAction.font = Fonts.DefaultFont(FontSize.Medium * self.scaleFactor);
        newAction.textAlignment = NSTextAlignment.Center;
        newAction.sizeToFit();
        newAction.width = self.width - 10;
        newAction.center = self.center;
        newAction.addTarget(target, selector: selector);
        
        var totalHeight:CGFloat = ((newAction.height + 10) * self.actions.count.floatValue);
        for(var i:Int = 0; i < self.actions.count; i++)
        {
            var action:UILabel = self.actions[i];
            
            if(self.height <= 480)
            {
                action.y = (self.height) * 0.9 - totalHeight + ((action.height + 10) * i.floatValue);
            }
            else
            {
                action.y = (self.height) * 0.82 - totalHeight + ((action.height + 20) * i.floatValue);
            }
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