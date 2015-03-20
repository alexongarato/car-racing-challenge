//
//  GameViewController.swift
//  Arcade Car Race
//
//  Created by Alex Ongarato on 08/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    var scene:GameScene!;
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        
        self.scene                      = GameScene();
        let skView                      = self.view as SKView;
        skView.showsFPS                 = Configs.DEBUG_MODE;
        skView.showsNodeCount           = Configs.DEBUG_MODE;
        skView.ignoresSiblingOrder      = true;
        scene.size                      = UIScreen.mainScreen().applicationFrame.size;
        scene.scaleMode                 = SKSceneScaleMode.ResizeFill;
        scene.view?.layer.borderWidth   = 1;
        scene.updateStatusHandler       = self.gameStatusUpdateHandler;
        scene.gameOverHandler           = self.gameOverHandler;
        skView.presentScene(scene);
        
        scene.build();
        scene.start();
        
        Trace.log(scene.size.description as String);
    }
    
    func gameStatusUpdateHandler()
    {
        Trace.log("SCORE:\(scene.currentScore())");
    }
    
    func gameOverHandler()
    {
        Trace.log("GAME OVER");
    }
    
    override func shouldAutorotate() -> Bool
    {
        return true;
    }
    
    override func supportedInterfaceOrientations() -> Int
    {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue);
        }
        else
        {
            return Int(UIInterfaceOrientationMask.All.rawValue);
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning();
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return false;
    }
}
