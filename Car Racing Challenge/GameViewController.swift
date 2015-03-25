//
//  GameViewController.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 08/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    var scene           : GameScene!;
    var sceneView       : SKView!;
    var menuView        : MenuView!;
    var statusView      : GameStatusView!;
    var snapshotView    : UIImageView!;
    var bestScoreEver   : NSInteger = 0;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).gameController = self;
        
        //
        self.scene = GameScene();
        scene.size = UIScreen.mainScreen().applicationFrame.size;
        scene.updateStatusHandler = self.gameStatusUpdateHandler;
        scene.gameOverHandler = self.gameOverHandler;
        scene.levelUpHandler = self.levelUpHandler;
        
        Trace.log(scene.size.description as String);
        
        //
        sceneView = SKView();
        sceneView.frame = self.view.frame;
        sceneView.showsFPS = Configs.DEBUG_MODE;
        sceneView.showsNodeCount = Configs.DEBUG_MODE;
        sceneView.ignoresSiblingOrder = true;
        sceneView.presentScene(scene);
        self.view.addSubview(sceneView);
        
        //
        self.statusView = GameStatusView();
        self.view.addSubview(self.statusView);
        
        let data:NSString = DataProvider.getString(SuiteNames.GameBestScoreSuite, key: SuiteNames.GameBestScoreKey) as NSString;
        if(data == "")
        {
            Trace.log("oops. best score not restored.");
        }
         else
        {
            self.bestScoreEver = NSInteger(data.floatValue);
            Trace.log("best score restored: \(self.bestScoreEver)");
            GameCenterController.reportScore(self.bestScoreEver);
        }
        
        //
        scene.reset();
        scene.build();
        
        showMenu("car racing\nchallenge", desc: "limitless score!\nHow far can you go?", action: "PRESS TO START", selector: Selector("startGame"), showInstructions:true);
        
        AudioHelper.playSound(AudioHelper.EntranceSound);
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated);
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).startGameCenter();
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated);
    }
    
    func showMenu(msg:String, desc:String, action:String, selector:Selector, showInstructions:Bool = false)
    {
        scene.stop();
        statusView.hide();
        menuView = MenuView();
        menuView.animationStyle = AnimationStyle.Scale;
        self.view.addSubview(menuView);
        menuView.setTitle(msg);
        menuView.setDescription(desc);
        if(showInstructions)
        {
            menuView.setInstructions(self.scene.lifeUpScore(), scoreToLevelUp: self.scene.levelUpScore());
        }
        menuView.setAction(action, target: self, selector: selector);
        menuView.present(nil);
        
        AudioHelper.playSound(AudioHelper.MenuOpenSound);
    }
    
    func gameStatusUpdateHandler()
    {
        self.statusView.update(self.scene.currentLevel(),
            score: self.scene.currentScore(),
            nextScore: self.scene.levelUpScore(),
            lifes:scene.currentLifes(),
            scoreNextLife:self.scene.currentScoreToNextLife());
    }
    
    func startGame()
    {
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
        
        AudioHelper.playSound(AudioHelper.SelectSound);
    }
    
    func restartGame()
    {
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
        if(scene.currentScore() > self.bestScoreEver)
        {
            self.bestScoreEver = scene.currentScore();
            DataProvider.saveData(SuiteNames.GameBestScoreSuite, key: SuiteNames.GameBestScoreKey, string: "\(self.bestScoreEver)");
            if(!GameCenterController.isReady())
            {
                GameCenterController.authenticate({ GameCenterController.reportScore(self.bestScoreEver); });
            }
            else
            {
                GameCenterController.reportScore(self.bestScoreEver);
            }
        }
        
        scene.stop();
        showMenu("\nGAME OVER", desc: "SCORE:\(scene.currentScore())\nBEST:\(self.bestScoreEver)", action: "TRY AGAIN", selector: Selector("restartGame"));
        
        AudioHelper.playSound(AudioHelper.GameOverSound);
    }
    
    func levelUpHandler()
    {
        Trace.log("LEVEL UP");
        
        var desc:String!;
        if(scene.currentLevel() <= scene.maximunLevel())
        {
            desc = "congratulations!";
        }
        else if(scene.currentLevel() == scene.maximunLevel() + 1)
        {
            desc = "This is the infinite highest level.\ngood luck!";
        }
        
        if(desc != nil)
        {
            scene.stop();
            showMenu("\nLEVEL \(scene.currentLevel())", desc: desc, action: "GO!", selector: Selector("resumeLevelUp"));
            scene.setTotalColumns(scene.currentColumns() - 1);
        }
        
        AudioHelper.playSound(AudioHelper.LevelUpSound);
    }
    
    func resumeLevelUp()
    {
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
    
    func applicationWillResignActive()
    {
        if(!self.scene.isGamePaused())
        {
            self.scene.stop();
            showMenu("\nRESUME", desc: "are you ready?", action: "yes!", selector: Selector("resumeLevelUp"));
        }
    }
    
    //################### PRAGMA
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
