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
    
    override func didMoveToSuperview()
    {
        super.didMoveToSuperview();
        var img:UIImage! = UIImage(named: ImagesNames.Background)!;
        var imgView:UIImageView = UIImageView(image: img);
        imgView.frame = self.frame;
        self.addSubview(imgView);
        self.layer.masksToBounds = true;
        //-----
        
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
        self.addSubview(podium);
        podium.addTarget(self, selector: Selector("openGameCenter:"));
        podium.center = self.center;
        
        buildMenu();
    }
    
    func openGameCenter(sender:AnyObject!)
    {
        (sender as! UITapGestureRecognizer).view?.onTouchAnima();
        
        Trace.log("ConfigsView -> open game center");
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
        
        addAction("SOUNDS", selector: "soundHandler", key:SuiteNames.KeySound, active:true);
        if(PurchaseController.getInstance().userCanPurchase())
        {
            addAction("REMOVE ADS", selector: "adsHandler", key:SuiteNames.KeyAds, active:!PurchaseController.getInstance().hasPurchased());
            addAction("RESTORE PURCHASES", selector: "restoreHandler", active:!PurchaseController.getInstance().hasPurchased());
        }
        
        self.container.removeAllSubviews();
        
        var action:UILabel!;
        var model:ActionModel!;
        var label:String = "";
        for(var i:Int = 0; i < self.actions.count; i++)
        {
            label = "";
            model = self.actions[i];
            action = UILabel();
            if(model.key == nil)
            {
                action.text = model.label;
            }
            else
            {
                label = DataProvider.getBoolData(SuiteNames.SuiteConfigs, key: model.key) ? "ON" : "OFF";
                action.text = "\(model.label): \(label)";
            }
            
            action.font = Fonts.LightFont(FontSize.Medium);
            action.textColor = UIColor.blackColor();
            action.textAlignment = NSTextAlignment.Center;
            if(model.active)
            {
                action.addTarget(self, selector: Selector(model.selector));
            }
            else
            {
                action.alpha = 0.3;
            }
            self.container.addSubview(action);
            action.sizeToFit();
            action.width = self.container.width;
            action.y = (action.height + 20) * i.floatValue;
            
            self.container.height = action.y + action.height * 2;
            self.podium.y = self.container.y + self.container.height;
        }
        
        
    }
    
    func addAction(label:String, selector:String, key:String! = nil, active:Bool)
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
        Trace.log("sound handler");
        DataProvider.saveData(SuiteNames.SuiteConfigs, key: SuiteNames.KeySound, value: !DataProvider.getBoolData(SuiteNames.SuiteConfigs, key: SuiteNames.KeySound));
        buildMenu();
        AudioHelper.playSound(AudioHelper.MenuOpenSound);
    }
    
    func adsHandler()
    {
        Trace.log("ads handler");
        if(!DataProvider.getBoolData(SuiteNames.SuiteConfigs, key: SuiteNames.KeyAds))
        {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("purchasedHandler"), name: Events.AdsPurchased, object: nil);
            PurchaseController.getInstance().buyRemoveAds();
            AudioHelper.playSound(AudioHelper.MenuOpenSound);
        }
    }
    
    func restoreHandler()
    {
        Trace.log("restore handler");
        AudioHelper.playSound(AudioHelper.MenuOpenSound);
    }
    
    //----observer
    func purchasedHandler()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self);
        PurchaseController.getInstance().hasPurchased(true);
        buildMenu();
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

