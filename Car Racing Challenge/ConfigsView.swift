//
//  ConfigsViewController.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 03/04/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import UIKit

class ConfigsView:AbstractView
{
    var actions:Array<ActionModel> = Array<ActionModel>();
    var container:AbstractView!;
    var podium:UIImageView!;
    var fb:UIImageView!;
    var tt:UIImageView!;
    var scaleFactor:CGFloat = 1;
    var bestScore: UILabel!;
    var _timer:NSTimer!;
    var _currentScore:Float = 0;
    var _totalScore:Float = 0;
    var _animaTime:NSTimeInterval = 0;
    
    override func didMoveToSuperview()
    {
        super.didMoveToSuperview();
        self.layer.masksToBounds = true;
        self.backgroundColor = UIColor(white: 0.9, alpha: 1);
        //-----
        
        if(self.width > 375)// && self.width < 414)
        {
            self.scaleFactor = 2;
        }
        
        self.container = AbstractView();
        self.addSubview(self.container);
        self.container.frame = UIScreen.mainScreen().applicationFrame;
        self.container.layer.masksToBounds = true;
        self.container.width = self.width;
        self.container.height = 200;
        self.container.center = self.center;
        
        var image:UIImage! = UIImage(named: ImagesNames.Podium);
        self.podium = UIImageView(image: image);
        self.addSubview(self.podium);
        self.podium.addTarget(self, selector: Selector("openGameCenter:"));
        self.podium.center = self.center;
        
        //---fb
        self.fb = UIImageView(image: UIImage(named: ImagesNames.FBIcon)!);
        self.addSubview(self.fb);
        self.fb.center = self.center;
        self.fb.x -= self.podium.width * 1.5;
        self.fb.addTarget(self, selector: Selector("facebookHandler:"));
        
        
        //---tt
        self.tt = UIImageView(image: UIImage(named: ImagesNames.TTIcon)!);
        self.addSubview(self.tt);
        self.tt.center = self.center;
        self.tt.x += self.podium.width * 1.5;
        self.tt.addTarget(self, selector: Selector("twitterHandler:"));
        
        //best score
        let data:NSString = DataProvider.getString(SuiteNames.SuiteBestScore, key: SuiteNames.KeyBestScore) as NSString;
        _totalScore = data.floatValue;
        //_totalScore = 9000;
        _animaTime = NSTimeInterval(0.005);
        
        Trace("animatime:\(_animaTime)");
        
        self.bestScore = UILabel();
        self.bestScore.textColor = UIColor.blackColor();
        self.bestScore.textAlignment = NSTextAlignment.Center;
        self.bestScore.font = Fonts.DefaultFont(FontSize.Default * self.scaleFactor);
        self.bestScore.text = "BEST SCORE:0";
        self.bestScore.sizeToFit();
        self.bestScore.width = self.width + 2;
        self.bestScore.height += 30;
        self.bestScore.center.x = self.center.x;
        self.addSubview(self.bestScore);
        self.bestScore.alpha = 0.4;
        self.bestScore.layer.borderWidth = 0.5;
        self.bestScore.layer.borderColor = UIColor.blackColor().alpha(0.2).CGColor;
        
        buildMenu();
        
        _timer = Utils.delayedCall(AnimationTime.Slow, target: self, selector: Selector("updateScore"), repeats: false);
    }
    
    func updateScore()
    {
        if(_timer != nil)
        {
            _timer.invalidate();
            _timer = nil;
        }
        
        if(_currentScore < _totalScore)
        {
            _timer = Utils.delayedCall(_animaTime, target: self, selector: Selector("updateScore"), repeats: false);
            
            _currentScore += _totalScore/100;
            
            self.bestScore.text = "BEST SCORE:\(Int(_currentScore))";
            self.bestScore.sizeToFit();
            self.bestScore.width = self.width + 2;
            self.bestScore.height += 30;
            self.bestScore.center.x = self.center.x;
        }
    }
    
    override func removeFromSuperview()
    {
        if(_timer != nil)
        {
            _timer.invalidate();
            _timer = nil;
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self);
        super.removeFromSuperview();
    }
    
    func buildMenu()
    {
        self.actions.removeAll(keepCapacity: false);
        
        addAction(label: "SOUNDS", selector: "soundHandler", key:SuiteNames.KeySound, active:true);
        if(PurchaseController.getInstance().userCanPurchase() && !PurchaseController.getInstance().hasPurchased())
        {
            addAction();
            addAction(label: "REMOVE ADS", selector: "adsHandler", key:SuiteNames.KeyAds, active:true);
            addAction(label: "RESTORE PURCHASE", selector: "restoreHandler", active:true);
            addAction();
        }
        addAction(label: "RATE S2", selector: "rateHandler", key:nil, active:true);
        
        self.container.removeAllSubviews();
        
        var action:UILabel!;
        var model:ActionModel!;
        var label:String!;
        let dash:String = " - ";
        var lastY:CGFloat = 0;
        for(var i:Int = 0; i < self.actions.count; i++)
        {
            label = "";
            model = self.actions[i];
            action = UILabel();
            action.textColor = UIColor.blackColor();
            action.textAlignment = NSTextAlignment.Center;
            if(model.active)
            {
                action.font = Fonts.LightFont(FontSize.Medium * self.scaleFactor);
                
                if(model.selector != nil)
                {
                    action.addTarget(self, selector: Selector(model.selector));
                }
            }
            else
            {
                action.font = Fonts.LightFont(FontSize.Default * self.scaleFactor);
                action.alpha = 0.3;
            }
            
            if(model.key == nil)
            {
                action.text = (model.label == nil) ? dash : model.label;
            }
            else
            {
                label = DataProvider.getBoolData(SuiteNames.SuiteConfigs, key: model.key) ? "ON" : "OFF";
                action.text = "\(model.label):\(label)";
                action.bold(label);
            }
            
            action.bold("S2");
            
            self.container.addSubview(action);
            action.sizeToFit();
            action.width = self.container.width;
            if(action.text == dash)
            {
                action.height = 18;
            }
            action.y = lastY;
            if(self.height <= 480)
            {
                lastY += action.height * 1.3;
            }
            else
            {
                lastY += action.height * 1.5;
            }
        }
        
        self.container.height = lastY;
        self.container.center.x = self.center.x;
        self.container.y = (UIScreen.mainScreen().applicationFrame.height - self.container.height).half - 25;
        self.podium.y = self.container.y + self.container.height;
        self.fb.y = self.podium.y;
        self.tt.y = self.podium.y;
        self.bestScore.y = self.container.y - self.bestScore.height * 1.5;
    }
    
    func addAction(label:String! = nil, selector:String! = nil, key:String! = nil, active:Bool = false)
    {
        var action:ActionModel = ActionModel();
        action.label = label;
        action.selector = selector;
        action.key = key;
        action.active = active;
        self.actions.append(action);
    }
    
    //----- HANDLERS ---------
    func openGameCenter(sender:AnyObject!)
    {
        (sender as! UITapGestureRecognizer).view?.onTouchAnima();
        
        Trace("ConfigsView -> open game center");
        GameCenterController.loadLeaderboard();
    }
    
    func soundHandler()
    {
        Trace("sound handler");
        DataProvider.saveData(SuiteNames.SuiteConfigs, key: SuiteNames.KeySound, value: !DataProvider.getBoolData(SuiteNames.SuiteConfigs, key: SuiteNames.KeySound));
        buildMenu();
        AudioHelper.playSound(AudioHelper.MenuOpenSound);
    }
    
    func adsHandler()
    {
        Trace("ads handler");
        if(!DataProvider.getBoolData(SuiteNames.SuiteConfigs, key: SuiteNames.KeyAds))
        {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("purchasedHandler"), name: Events.AdsPurchased, object: nil);
            PurchaseController.getInstance().buyRemoveAds(tryRestore: false);
            AudioHelper.playSound(AudioHelper.MenuOpenSound);
        }
    }
    
    func restoreHandler()
    {
        Trace("restore handler");
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("restoredHandler"), name: Events.AdsPurchased, object: nil);
        PurchaseController.getInstance().buyRemoveAds(tryRestore: true);
        AudioHelper.playSound(AudioHelper.MenuOpenSound);
    }
    
    //----observer
    func purchasedHandler()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self);
        NSNotificationCenter.defaultCenter().postNotificationName(Events.removeAds, object:self);
        PurchaseController.getInstance().hasPurchased(true);
        buildMenu();
        AlertController.getInstance().showAlert(title: "Thank you!", message: "All Ads has been removed.", action: "Done", completion: nil);
    }
    
    func restoredHandler()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self);
        NSNotificationCenter.defaultCenter().postNotificationName(Events.removeAds, object:self);
        PurchaseController.getInstance().hasPurchased(true);
        buildMenu();
        AlertController.getInstance().showAlert(title: "Thank you!", message: "Purchase has been restored.", action: "Done", completion: nil);
    }
    
    func rateHandler()
    {
        Trace("rate handler");
        AudioHelper.playSound(AudioHelper.MenuOpenSound);
        var url:NSURL! = NSURL(string: Routes.RATE_US_URL)!;
        UIApplication.sharedApplication().openURL(url);
    }
    
    func facebookHandler(sender:AnyObject!)
    {
        (sender as! UITapGestureRecognizer).view?.onTouchAnima();
        
        Trace("facebook share");
        AudioHelper.playSound(AudioHelper.MenuOpenSound);
        shareBuilder(SocialController.facebookType);
    }
    
    func twitterHandler(sender:AnyObject!)
    {
        (sender as! UITapGestureRecognizer).view?.onTouchAnima();
        
        Trace("twitter share");
        AudioHelper.playSound(AudioHelper.MenuOpenSound);
        shareBuilder(SocialController.twitterType);
    }
    
    private func shareBuilder(type:String)
    {
        SocialController.getInstance().share(type, text:"I'm playing Car Racing Challenge. It's awesome!", url:Routes.ITUNES_URL, image:UIImage(named: "export_icon_180.png"));
    }
    
    
    //----------- MODEL CLASS ---------
    class ActionModel
    {
        var label:String!;
        var selector:String!;
        var key:String!;
        var active:Bool = false;
    }
}

