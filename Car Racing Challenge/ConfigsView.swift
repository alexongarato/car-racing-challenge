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
    var scaleFactor:CGFloat = 1;
    
    override func didMoveToSuperview()
    {
        super.didMoveToSuperview();
        var img:UIImage! = UIImage(named: ImagesNames.Background)!;
        var imgView:UIImageView = UIImageView(image: img);
        imgView.frame = self.frame;
        self.addSubview(imgView);
        self.layer.masksToBounds = true;
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
//        self.container.layer.borderWidth = 1;
        
        var image:UIImage! = UIImage(named: ImagesNames.Podium);
        podium = UIImageView(image: image);
//        if(self.scaleFactor > 1)
//        {
//            podium.scale(1.5);
//        }
        self.addSubview(podium);
        podium.addTarget(self, selector: Selector("openGameCenter:"));
        podium.center = self.center;
        
        buildMenu();
    }
    
    func openGameCenter(sender:AnyObject!)
    {
        (sender as! UITapGestureRecognizer).view?.onTouchAnima();
        
        Trace("ConfigsView -> open game center");
        GameCenterController.loadLeaderboard();
    }
    
    override func removeFromSuperview()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self);
        super.removeFromSuperview();
    }
    
    func buildMenu()
    {
        self.actions.removeAll(keepCapacity: false);
        
        addAction(label: "SOUNDS", selector: "soundHandler", key:SuiteNames.KeySound, active:true);
        if(PurchaseController.getInstance().userCanPurchase())
        {
            addAction();
            
            addAction(label: "REMOVE ADS", selector: "adsHandler", key:SuiteNames.KeyAds, active:!PurchaseController.getInstance().hasPurchased());
            addAction(label: "RESTORE PURCHASE", selector: "restoreHandler", active:!PurchaseController.getInstance().hasPurchased());
            
            addAction();
            
            addAction(label: "RATE THIS APP", selector: "rateHandler", key:nil, active:true);
            addAction(label: "SHARE ON TWITTER", selector: "twitterHandler", key:nil, active:SocialController.getInstance().isTwitterAvailable());
            addAction(label: "SHARE ON FACEBOOK", selector: "facebookHandler", key:nil, active:SocialController.getInstance().isFacebookAvailable());
        }
        
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
            
            if(model.key == nil)
            {
                action.text = (model.label == nil) ? dash : model.label;
            }
            else
            {
                label = DataProvider.getBoolData(SuiteNames.SuiteConfigs, key: model.key) ? "ON" : "OFF";
                action.text = "\(model.label):\(label)";
            }
            
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
        self.container.center = self.center;
        self.container.y -= self.podium.height.half + 10;
        self.podium.y = self.container.y + self.container.height;
        
        
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
        Utils.showAlert(title: "Remove Ads", message: "All Ads will be removed.\n\nThank you!", action: "Done", cancel: nil, completion: nil);
    }
    
    func restoredHandler()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self);
        NSNotificationCenter.defaultCenter().postNotificationName(Events.removeAds, object:self);
        PurchaseController.getInstance().hasPurchased(true);
        buildMenu();
        Utils.showAlert(title: "Remove Ads", message: "Purchase restored.\n\nThank you!", action: "Done", cancel: nil, completion: nil);
    }
    
    func rateHandler()
    {
        Trace("rate handler");
        var url:NSURL! = NSURL(string: Routes.RATE_US_URL)!;
        UIApplication.sharedApplication().openURL(url);
    }
    
    func facebookHandler()
    {
        Trace("facebook share");
        shareBuilder(SocialController.facebookType);
    }
    
    func twitterHandler()
    {
        Trace("twitter share");
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

