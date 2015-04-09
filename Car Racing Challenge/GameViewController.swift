//
//  GameViewController.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 08/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class GameViewController: UIViewController, GKGameCenterControllerDelegate
{
    var scene                   : GameScene!;
    var sceneView               : SKView!;
    var menuView                : MenuView!;
    var statusView              : GameStatusView!;
    var snapshotView            : UIImageView!;
    var showResumeOnStartUp     : Bool = false;
    private var _bestScore      : NSInteger = 0;
    
    override func viewDidLoad()
    {
        //------ INIT DATA ------
        if(!DataProvider.getBoolData(SuiteNames.SuiteConfigs, key: SuiteNames.KeyFirstTime))
        {
            DataProvider.saveData(SuiteNames.SuiteConfigs, key: SuiteNames.KeySound, value: true);
            setBestScore(0);
            DataProvider.saveData(SuiteNames.SuiteConfigs, key: SuiteNames.KeyAds, value: false);
            DataProvider.saveData(SuiteNames.SuiteConfigs, key: SuiteNames.KeyFirstTime, value: true);
        }
        //------
        
        super.viewDidLoad();
        
        AppDelegate.getInstance().gameController = self;
        
        var purchased:Bool = PurchaseController.getInstance().hasPurchased();
        
        sceneView = SKView();
        sceneView.frame = self.view.frame;
        
        sceneView.ignoresSiblingOrder = true;
        self.view.addSubview(sceneView);
        
        sceneView.showsFPS = Configs.DEBUG_MODE;
        sceneView.showsNodeCount = Configs.DEBUG_MODE;
        
        self.scene = GameScene();
        scene.size = UIScreen.mainScreen().applicationFrame.size;
        scene.updateStatusHandler = self.updateGameStatusHandler;
        scene.gameOverHandler = self.gameOverHandler;
        scene.levelUpHandler = self.levelUpHandler;
        sceneView.presentScene(scene);
        
        Trace("GameViewController -> \(scene.size.description as String)");
        
        self.statusView = GameStatusView();
        self.view.addSubview(self.statusView);
        
        scene.lifeUpHandler = self.statusView.showSuccessAnimation;
        scene.lifeDownHandler = self.statusView.showErrorAnimation;
        
        let data:NSString = DataProvider.getString(SuiteNames.SuiteBestScore, key: SuiteNames.KeyBestScore) as NSString;
        _bestScore = NSInteger(data.floatValue);
        Trace("GameViewController -> best score restored: \(_bestScore)");
        GameCenterController.reportScore(self.getBestScore());
        
        self.scene.reset();
        self.scene.build();
        
        Trace("GameViewController -> start game center");
        GameCenterController.start();
        
        startGame();
    }
    
    func showMenu(msg:String, desc:String, action:String, selector:Selector!, showInstructions:Bool = false, showExitButton:Bool = true, showGameOver:Bool = false)
    {
        if(menuView != nil)
        {
            return;
//            menuView.removeFromSuperview();
//            menuView = nil;
        }
        
        scene.stop();
        statusView.hide();
        menuView = MenuView();
        menuView.animationStyle = AnimationStyle.Scale;
        self.view.addSubview(menuView);
        menuView.setTitle(msg);
        menuView.setDescription(desc);
        
        if(showInstructions)
        {
            menuView.setInstructions(self.scene.SCORE_TO_EARN_LIFE, scoreToLevelUp: self.scene.SCORE_TO_LEVEL_UP);
        }
        else if(showGameOver)
        {
            menuView.setGameOver();
        }
        
        if(selector != nil)
        {
            menuView.setAction(action, target: self, selector: selector);
        }
        
        if(showExitButton)
        {
            menuView.setAction("exit", target: self, selector: Selector("exitHandler:"));
        }
        
        menuView.present(nil);
        
        AudioHelper.playSound(AudioHelper.MenuOpenSound);
    }
    
    func getBestScore() -> NSInteger
    {
        return _bestScore;
    }
    
    func setBestScore(score:NSInteger)
    {
        Trace("GameViewController -> best score saved: \(score)");
        DataProvider.saveData(SuiteNames.SuiteBestScore, key: SuiteNames.KeyBestScore, string: "\(score)");
        _bestScore = score;
    }
    
    func exitHandler(sender:AnyObject!)
    {
        (sender as! UITapGestureRecognizer).view?.onTouchAnima();
        
        self.startGame();
    }
    
    func updateGameStatusHandler()
    {
        self.statusView.update(self.scene.currentLevel(),
            score: self.scene.currentScore(),
            nextScore: self.scene.SCORE_TO_LEVEL_UP,
            lifes:scene.currentLifes(),
            scoreNextLife:self.scene.currentScoreToNextLife());
    }
    
    func startGame()
    {
        if(menuView != nil)
        {
            menuView.removeFromSuperview();
            menuView = nil;
        }
        
        showMenu("car racing\nchallenge",
            desc: "", action: "PLAY", selector: Selector("startGameHandler:"), showInstructions:true, showExitButton:false);
        AudioHelper.playSound(AudioHelper.EntranceSound);
        
        self.showBanner();
    }
    
    func startGameHandler(sender:AnyObject!)
    {
        (sender as! UITapGestureRecognizer).view?.onTouchAnima();
        
        menuView.disableAction();
        statusView.show();
        
        func complete(animated:Bool)
        {
            if(self.menuView != nil)
            {
                self.menuView.removeFromSuperview();
                self.menuView = nil;
            }
            self.scene.reset();
            self.scene.build();
            self.scene.start();
        }
        
        self.menuView.dismiss(complete);
        
        AudioHelper.playSound(AudioHelper.StartGameSound);
    }
    
    func gameOverHandler()
    {
        scene.stop();
        Utils.vibrate();
        
        if(scene.currentScore() > self.getBestScore())
        {
            self.setBestScore(scene.currentScore())
            if(!GameCenterController.isReady())
            {
                GameCenterController.authenticate({ GameCenterController.reportScore(self.getBestScore()); });
            }
            else
            {
                GameCenterController.reportScore(self.getBestScore());
            }
        }
        
        showMenu("GAME OVER", desc: "\n\nSCORE:\(scene.currentScore())\n\nBEST:\(self.getBestScore())", action: "RESTART", selector: Selector("startGameHandler:"), showGameOver:true);
        AudioHelper.playSound(AudioHelper.GameOverSound);
        
        self.showBanner();
    }
    
    func levelUpHandler()
    {
        Trace("GameViewController -> LEVEL UP");
        
        var ttl:String = "\nLEVEL \(scene.currentLevel())\n";
        var desc:String!;
        var act:String = "LET'S GO!";
        var selector:Selector = Selector("resumeLevelUp:");
        
        if(!Configs.SAMPLE_MODE)
        {
            /*if(scene.currentLevel() <= scene.maximunLevel())
            {*/
                desc = "\n\ncongratulations!";
            /*}
            else if(scene.currentLevel() == scene.maximunLevel() + 1)
            {
                desc = "\n\nThis is the highest\nracing track level!";
            }
            if(desc != nil)
            {*/
                scene.stop();
                showMenu(ttl, desc: desc, action: act, selector: selector, showExitButton:false);
                scene.setTotalColumns(scene.currentColumns() - 1);
                self.showBanner();
            //}
        }
        else
        {
            scene.stop();
            selector = nil;
            ttl = "FREE VERSION";
            desc = "This free version is limited\nto one level only.";
            showMenu(ttl, desc: desc, action: "", selector: nil, showExitButton:true);
            self.showBanner();
        }
        
        AudioHelper.playSound(AudioHelper.LevelUpSound);
    }
    
    func resumeLevelUp(sender:AnyObject!)
    {
        (sender as! UITapGestureRecognizer).view?.onTouchAnima();
        
        menuView.disableAction();
        statusView.show();
        
        func complete(animated:Bool)
        {
            if(self.menuView != nil)
            {
                self.menuView.removeFromSuperview();
                self.menuView = nil;
            }
            
            self.scene.start();
        }
        
        self.menuView.dismiss(complete);
    }
    
    //################### PRAGMA
    func applicationWillResignActive()
    {
        Trace("GameViewController -> app will resign active");
        
        if(!self.scene.isGamePaused())
        {
            self.scene.stop();
            self.showResumeOnStartUp = true;
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated);
    }
    
    func applicationDidBecomeActive()
    {
        Trace("GameViewController -> app did become active");
        
        if(self.showResumeOnStartUp)
        {
            self.showResumeOnStartUp = false;
            showMenu("RESUME\n\n", desc: " \n \n \nARE YOU READY?", action: "YES!", selector: Selector("resumeLevelUp:"));
        }
        
        Utils.hideAlert(nil);
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        Trace("GameViewController -> GameCenter did finish");
        
        self.dismissViewControllerAnimated(true, completion:
            {
                self.applicationDidBecomeActive();
        });
    }
    
    func showBanner()
    {
        if(Configs.SAMPLE_MODE)
        {
            Trace("GameViewController -> show banner");
        }
    }

    override func shouldAutorotate() -> Bool
    {
        return true;
    }
    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue);
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning();
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true;
    }
}
