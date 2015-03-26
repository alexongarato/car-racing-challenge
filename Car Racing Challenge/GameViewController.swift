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
    var scene           : GameScene!;
    var sceneView       : SKView!;
    var menuView        : MenuView!;
    var statusView      : GameStatusView!;
    var snapshotView    : UIImageView!;
    var bestScoreEver   : NSInteger = 0;
    var showResumeOnStartUp     : Bool = false;
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        Trace.log("GameCenter did finish");
        self.dismissViewControllerAnimated(true, completion: {
            self.applicationDidBecomeActive();
        });
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).gameController = self;
        
        //
        self.scene = GameScene();
        scene.size = UIScreen.mainScreen().applicationFrame.size;
        scene.updateStatusHandler = self.updateGameStatusHandler;
        scene.gameOverHandler = self.gameOverHandler;
        scene.levelUpHandler = self.levelUpHandler;
        
        Trace.log(scene.size.description as String);
        
        //
        sceneView = SKView();
        sceneView.frame = self.view.frame;
//        sceneView.showsFPS = Configs.DEBUG_MODE;
//        sceneView.showsNodeCount = Configs.DEBUG_MODE;
//        sceneView.ignoresSiblingOrder = true;
        sceneView.presentScene(scene);
        self.view.addSubview(sceneView);
        
        //
        self.statusView = GameStatusView();
        self.view.addSubview(self.statusView);
        
        scene.lifeUpHandler = self.statusView.showSuccessAnimation;
        scene.lifeDownHandler = self.statusView.showErrorAnimation;
        
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
        
        self.scene.reset();
        self.scene.build();
        
        startGame();
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated);
        (UIApplication.sharedApplication().delegate as! AppDelegate).startGameCenter();
    }
    
    func applicationDidBecomeActive()
    {
        if(self.showResumeOnStartUp)
        {
            self.showResumeOnStartUp = false;
            showMenu("RESUME\nCAR RACING\nCHALLENGE\n\n", desc: " \n \n \nARE YOU READY?", action: "YES!", selector: Selector("resumeLevelUp"));
        }
    }
    
    func showMenu(msg:String, desc:String, action:String, selector:Selector, showInstructions:Bool = false, showExitButton:Bool = true, showGameOver:Bool = false)
    {
        if(menuView != nil)
        {
            menuView.removeFromSuperview();
            menuView = nil;
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
            menuView.setInstructions(self.scene.lifeUpScore(), scoreToLevelUp: self.scene.levelUpScore());
        }
        else if(showGameOver)
        {
            menuView.setGameOver();
        }
        
        menuView.setAction(action, target: self, selector: selector);
        
        if(showExitButton)
        {
            menuView.setAction("exit", target: self, selector: Selector("exitHandler"));
        }
        
        menuView.present(nil);
        
        AudioHelper.playSound(AudioHelper.MenuOpenSound);
    }
    
    func exitHandler()
    {
        self.startGame();
    }
    
    func updateGameStatusHandler()
    {
        self.statusView.update(self.scene.currentLevel(),
            score: self.scene.currentScore(),
            nextScore: self.scene.levelUpScore(),
            lifes:scene.currentLifes(),
            scoreNextLife:self.scene.currentScoreToNextLife());
    }
    
    func startGame()
    {
        showMenu("car racing\nchallenge",
            desc: "How far can you go?", action: "PLAY", selector: Selector("startGameHandler"), showInstructions:true, showExitButton:false);
        AudioHelper.playSound(AudioHelper.EntranceSound);
    }
    
    func startGameHandler()
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
        showMenu("\nGAME OVER", desc: "SCORE:\(scene.currentScore())\nBEST:\(self.bestScoreEver)", action: "RESTART", selector: Selector("startGameHandler"), showGameOver:true);
        
        AudioHelper.playSound(AudioHelper.GameOverSound);
    }
    
    func levelUpHandler()
    {
        Trace.log("LEVEL UP");
        
        var desc:String!;
        if(scene.currentLevel() <= scene.maximunLevel())
        {
            desc = "\n\ncongratulations!";
        }
        else if(scene.currentLevel() == scene.maximunLevel() + 1)
        {
            desc = "\n\nThis is the highest\nracing track level!";
        }
        
        if(desc != nil)
        {
            scene.stop();
            showMenu("\nRACE TRACK\nUPGRADE \(scene.currentLevel())\n", desc: desc, action: "GO!", selector: Selector("resumeLevelUp"));
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
            self.showResumeOnStartUp = true;
//            showMenu("\nRESUME", desc: "are you ready?", action: "yes!", selector: Selector("resumeLevelUp"));
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
