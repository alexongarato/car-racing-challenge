//
//  GameScene.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 08/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import SpriteKit

class GameScene: SKScene
{
    //-- configs --
    let SCORE_TO_LEVEL_UP               : Int = 300;//500
    let SCORE_TO_EARN_LIFE              : Int = 100;//100
    private let MAX_COLUMNS             : Int = 5;
    private let MIN_COLUMNS             : Int = 5;
    private let ID_BT_LEFT              : String = "bt_left";
    private let ID_BT_RIGHT             : String = "bt_right";
    private let INT_BETWEEN_LEVELS      : CFTimeInterval = 0.01;
    private let PIXELS_BETWEEN_ENEMIES_1: Int = 15;
    private let MIN_PX_BT_ENEMIES_1     : Int = 5;
    private let IS_LIFE_BONUS_MODE      : Bool = false;
    private let IS_LEVEL_MODE           : Bool = true;
    private let INITIAL_USER_LIFES      : Int = 0;
    
    
    //-- pointers --
    var updateStatusHandler             : (()->Void)!;
    var gameOverHandler                 : (()->Void)!;
    var levelUpHandler                  : (()->Void)!;
    var lifeUpHandler                   : (()->Void)!;
    var lifeDownHandler                 : (()->Void)!;
    private var buttonLeft              : SKSpriteNode!;
    private var buttonRight             : SKSpriteNode!;
    private var mainCharacter           : CustomSpriteNode!;
    private var enemiesArray            : Array<CustomSpriteNode>!;
    private var buttonSize              : CGSize = CGSize();
    private var charactersSize          : CGSize = CGSize();
    private var pixelSize               : CGFloat = 0;
    private var defaultFrame            : CGRect!;
    private var totalColumns            : Int = -1;
    private var totalScoreCounter       : Int = 0;
    private var currentScoreCounter     : Int = 0;
    private var totalLifesCounter       : Int = -1;
    private var currentLifeCounter      : Int = -1;
    private var ready                   : Bool = false;
    private var builded                 : Bool = false;
    private var loopsTimeCounter        : CFTimeInterval = -1;
    private var intervalBetweenLoops    : CFTimeInterval = 0.5;
    private var pixelDistanceCounter    : Int = -1;
    private var currentMainCharColumn   : Int = -1;
    private var currentLevelCounter     : Int = 1;
    private var roadSides               : SKSpriteNode!;
    private var sideNodeFlag            : Bool = false;
    private var sideNodeVelCounter      : CFTimeInterval = 0;
    private var currentVelSound         : Float = 0;
    private var pixelsNode              : SKSpriteNode!;
    private var bg                      : SKSpriteNode!;
    private var isGameOver              : Bool = false;
    
    
    func currentScoreToNextLife() -> Int
    {
        return self.currentLifeCounter;
    }
    
    func currentColumns() -> Int
    {
        return self.totalColumns;
    }
    
    func setTotalColumns(value:Int)
    {
        if(value >= self.MIN_COLUMNS && value <= self.MAX_COLUMNS)
        {
            self.totalColumns = value;
            self.build();
        }
        else
        {
            Trace("INVALID COLUMN NUMBER (\(value))");
        }
    }
    
    func currentScore() -> Int
    {
        return self.totalScoreCounter;
    }
    
    func currentLifes() -> Int
    {
        return self.totalLifesCounter;
    }
    
    func currentLevel() -> Int
    {
        return self.currentLevelCounter;
    }
    
    func maximunLevel() -> Int
    {
        return self.MAX_COLUMNS - self.MIN_COLUMNS;
    }
    
    func isGamePaused() -> Bool
    {
        if let thisView = self.view
        {
            return thisView.paused;
        }
        
        return true;
    }
    
    func build()
    {
        if(self.defaultFrame == nil)
        {
            self.defaultFrame = self.frame;
        }
        //        self.removeAllChildren();
        
        self.size = self.defaultFrame.size;
        AudioHelper.stopSound(AudioHelper.Vel4Sound);
        
        /**
        inicializar variaveis
        */
        self.isGameOver                 = false;
        self.totalColumns               = self.totalColumns == -1 ? self.MAX_COLUMNS : self.totalColumns;
        var totalPixelsX:Int            = Int((self.totalColumns * 3) + 2);
        //        self.enemiesArray               = Array<CustomSpriteNode>();
        self.pixelSize                  = CGFloat(self.size.width / totalPixelsX.floatValue);
        var totalPixelsY:Int            = Int((self.size.height / self.pixelSize));
        self.charactersSize.width       = self.pixelSize * 3;
        self.charactersSize.height      = self.pixelSize * 4;
        self.buttonSize.width           = self.size.width.half.roundValue;
        self.buttonSize.height          = self.size.height;
        self.currentMainCharColumn      = self.totalColumns / 2;
        self.pixelDistanceCounter       = self.PIXELS_BETWEEN_ENEMIES_1;
        self.currentVelSound            = 0;
        self.intervalBetweenLoops       = 0.5;
        
        //        self.currentLifeCounter         = self.scoreToEarnLife;
        //        self.totalLifesCounter          = self.defaultTotalLifes;
        
        if(self.enemiesArray == nil)
        {
            self.enemiesArray = Array<CustomSpriteNode>();
            var newEnemy:CustomSpriteNode!;
            
            for(var i:Int = 0; i < 10; i++)
            {
                newEnemy = CustomSpriteNode(texture: Utils.createCarTexture(self.charactersSize, pixelWidth: self.pixelSize, pixelHeight: self.pixelSize), size: self.charactersSize);
                newEnemy.size = self.charactersSize;
                newEnemy.anchorPoint.x = 0;
                newEnemy.anchorPoint.y = 1;
                newEnemy.zPosition = 10;
                self.enemiesArray.append(newEnemy);
            }
        }
        
        for enemyBlock in enemiesArray
        {
            enemyBlock.y = self.size.height + self.charactersSize.height;
            enemyBlock.x = self.pixelSize;
        }
        
        self.removeChildrenInArray(self.enemiesArray);
        
        Trace("GameScene -> pixelSize:\(self.pixelSize)");
        
        /**
        criar malha de pixels de acordo com a quantidade de pistas.
        */
        if(self.bg == nil)
        {
            bg = SKSpriteNode(imageNamed: ImagesNames.Background);
            bg.size = self.size;
            bg.anchorPoint.x = 0;
            bg.anchorPoint.y = 1;
            bg.x = 0;
            bg.y = bg.height;
            self.addChild(bg);
            //---------------------
            
            //desenha a malha no context
            pixelsNode = SKSpriteNode(texture: Utils.createPixelsGrid(self.size, totalPixelsX: totalPixelsX, totalPixelsY: totalPixelsY, pixelSize: self.pixelSize));
            self.addChild(pixelsNode);
            pixelsNode.zPosition = 1;
            pixelsNode.anchorPoint.x = 0;
            pixelsNode.anchorPoint.y = 1;
            pixelsNode.x = 0;
            pixelsNode.y = self.size.height;
            //---------------------
            
            
            //cria as laterias temporarias que serao desenhadas no context
            roadSides = SKSpriteNode(texture: Utils.createRoadPixels(self.size, totalPixelsX: totalPixelsX, totalPixelsY: totalPixelsY, pixelSize: self.pixelSize));
            self.addChild(roadSides);
            roadSides.zPosition = 1;
            roadSides.anchorPoint.x = 0;
            roadSides.anchorPoint.y = 1;
            roadSides.x = 0;
            roadSides.y = self.size.height;
            //---------------------
            
            
            /**
            cria os personagens do jogo
            */
            self.mainCharacter = CustomSpriteNode(texture: Utils.createCarTexture(self.charactersSize, pixelWidth: self.pixelSize, pixelHeight: self.pixelSize));
            self.mainCharacter.size = self.charactersSize;
            self.mainCharacter.anchorPoint.x = 0;
            self.mainCharacter.anchorPoint.y = 1;
            self.addChild(self.mainCharacter);
            
            /**
            cria os controles do jogo
            */
            self.buttonLeft = SKSpriteNode();
            self.buttonLeft.size = self.buttonSize;
            self.buttonLeft.anchorPoint.y = 1;
            self.buttonLeft.x = self.buttonLeft.width.half;
            self.buttonLeft.y = self.size.height;
            self.buttonLeft.name = self.ID_BT_LEFT;
            self.addChild(self.buttonLeft);
            
            self.buttonRight = SKSpriteNode();
            self.buttonRight.size = self.buttonSize;
            self.buttonRight.anchorPoint.y = 1;
            self.buttonRight.x = self.size.width - self.buttonRight.width.half;
            self.buttonRight.y = self.buttonLeft.y;
            self.buttonRight.name = self.ID_BT_RIGHT;
            self.addChild(self.buttonRight);
            
//            var pxCount:CGFloat = (55 / self.pixelSize).roundValue;
//            pxCount = pxCount == 0 ? 1 : pxCount;
//            var heightPixels:CGFloat = (totalPixelsY.floatValue - pxCount);
            
            if(self.size.height <= 480)
            {
                self.mainCharacter.y = self.size.height - (self.pixelSize * totalPixelsY.floatValue) + self.mainCharacter.height;
            }
             else
            {
                self.mainCharacter.y = self.size.height - (self.pixelSize * totalPixelsY.floatValue) + self.mainCharacter.height + (self.pixelSize);
            }
            
        }
        
        self.roadSides.y = self.size.height;
        self.mainCharacter.x = self.pixelSize + (self.charactersSize.width * self.currentMainCharColumn.floatValue);
        
        self.mainCharacter.zPosition = 20;
        self.buttonLeft.zPosition = 21;
        self.buttonRight.zPosition = 22;
        
        self.ready = false;
        self.view?.paused = true;
        
        self.builded = true;
    }
    
    func reset()
    {
        self.totalColumns = -1;
        
        self.ready = false;
        self.view?.paused = true;
        self.builded = false;
        self.pixelDistanceCounter = -1;
        self.currentMainCharColumn = -1;
        self.intervalBetweenLoops = 0.5;
        self.currentLevelCounter = 1;
        self.currentScoreCounter = 0;
        self.totalScoreCounter = 0;
        self.totalLifesCounter = self.INITIAL_USER_LIFES;
        self.currentLifeCounter = self.SCORE_TO_EARN_LIFE;
        self.updateStatusHandler();
    }
    
    func stop()
    {
        //        self.builded = false;
        self.ready = false;
        self.view?.paused = true;
        AudioHelper.stopSound(AudioHelper.Vel4Sound);
    }
    
    func start()
    {
        if(!self.builded)
        {
            Trace("GAME IS NOT READY!");
            return;
        }
        
        AudioHelper.playSound("vel_\(Int(self.currentVelSound)).wav");
        
        self.ready = true;
        self.paused = false;
        self.view?.paused = false;
        self.updateStatusHandler();
        startTrackAnima();
    }
    
    private var newDistance:Int = 0;
    override func update(currentTime: CFTimeInterval)
    {
        if(!self.ready)
        {
            return;
        }
        
        if(currentTime >= loopsTimeCounter)
        {
            if(self.currentVelSound < 4)
            {
                self.currentVelSound += 0.5;
                AudioHelper.playSound("vel_\(Int(self.currentVelSound)).wav");
            }
            //-----------
            loopsTimeCounter = currentTime + intervalBetweenLoops;
            //-----------
            
            self.pixelDistanceCounter++;
            newDistance = (self.PIXELS_BETWEEN_ENEMIES_1 - self.currentLevelCounter);
            newDistance = newDistance < MIN_PX_BT_ENEMIES_1 ? MIN_PX_BT_ENEMIES_1 : newDistance;
//            newDistance = 10;
            if(self.pixelDistanceCounter >= newDistance)
            {
                self.pixelDistanceCounter = 0;
                addNewEnemy();
            }
            
            for enemyBlock in enemiesArray
            {
                if(enemyBlock.parent != nil)
                {
                    /**
                    move o inimigo para baixo
                    */
                    enemyBlock.y -= pixelSize;
                    
                    /**
                    quando o inimigo sai da tela. end of life.
                    */
                    if(enemyBlock.y + enemyBlock.height.half < 0)
                    {
                        if(!enemyBlock.isTouched)
                        {
                            self.totalScoreCounter++;
                            self.currentScoreCounter++;
                            
                            if(IS_LIFE_BONUS_MODE)
                            {
                                self.currentLifeCounter--;
                                if(self.currentLifeCounter < 0)
                                {
                                    self.currentLifeCounter = self.SCORE_TO_EARN_LIFE;
                                    self.totalLifesCounter++;
                                    
                                    if(self.lifeUpHandler != nil)
                                    {
                                        self.lifeUpHandler();
                                    }
                                    
                                    AudioHelper.playSound(AudioHelper.PickupCoinSound);
                                }
                            }
                            
                            if(IS_LEVEL_MODE)
                            {
                                if(self.currentScoreCounter >= self.SCORE_TO_LEVEL_UP)
                                {
                                    self.currentScoreCounter = 0;
                                    self.currentLevelCounter++;
                                    self.levelUpHandler();
                                }
                            }
                        }
                        
                        
                        self.removeChildrenInArray([enemyBlock]);
                        self.updateStatusHandler();
                    }
                }
            }
        }
        
        for enemyBlock in enemiesArray
        {
            if(enemyBlock.parent != nil)
            {
                if(enemyBlock.x >= mainCharacter.x - 1 && enemyBlock.x <= mainCharacter.x + 1
                    && enemyBlock.y - charactersSize.height < mainCharacter.y && enemyBlock.y > mainCharacter.y - charactersSize.height + 2)
                {
                    if(!enemyBlock.isTouched)
                    {
                        enemyBlock.isTouched = true;
                        
                        AudioHelper.playSound(AudioHelper.lostLifeSound);
                        
                        self.totalLifesCounter--;
                        if(self.lifeDownHandler != nil)
                        {
                            self.lifeDownHandler();
                        }
                        
                        if(self.totalLifesCounter < 0)
                        {
                            self.totalLifesCounter = 0;
                            self.isGameOver = true;
                            self.gameOverHandler();
                        }
                        
                        self.updateStatusHandler();
                    }
                }
            }
        }
        
        if(self.intervalBetweenLoops > 0.03)
        {
            self.intervalBetweenLoops -= 0.003;
        }
    }
    
    private func trackAction() -> SKAction
    {
        var act = SKAction.moveToY(self.size.height - (self.pixelSize * 3) - 1, duration: 0.08 + self.intervalBetweenLoops);
        act.timingMode = SKActionTimingMode.Linear;
        return act;
    }
    
    private func trackCompletion()
    {
        if(!self.isGameOver && !self.isGamePaused())
        {
            startTrackAnima();
        }
    }
    
    private func startTrackAnima()
    {
        roadSides.paused = false;
        roadSides.y = self.size.height;
        roadSides.runAction(trackAction(), completion: trackCompletion);
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        if(!self.ready)
        {
            return;
        }
        
        /* Called when a touch begins */
        for touch: AnyObject in touches
        {
            let location = touch.locationInNode(self)
            var node:SKNode = self.nodeAtPoint(location);
            if(node.name == self.ID_BT_LEFT)
            {
                AudioHelper.playSound(AudioHelper.SelectSound);
                
                self.currentMainCharColumn--;
                if(self.currentMainCharColumn < 0)
                {
                    self.currentMainCharColumn = 0;
                }
            }
            
            if(node.name == self.ID_BT_RIGHT)
            {
                AudioHelper.playSound(AudioHelper.SelectSound);
                
                self.currentMainCharColumn++;
                if(self.currentMainCharColumn > self.totalColumns - 1)
                {
                    self.currentMainCharColumn = self.totalColumns - 1;
                }
            }
            
            self.mainCharacter.x = self.pixelSize + (self.charactersSize.width * self.currentMainCharColumn.floatValue);
        }
    }
    
    private var enemyCurrentPositionX:CGFloat = 0;
    //    private var enemyCurrentPositionIncrement:CGFloat = 1;
    private func addNewEnemy()
    {
        var newEnemy:CustomSpriteNode!;
        self.enemyCurrentPositionX = Utils.random(self.totalColumns - 1).floatValue;
        func createEnemy()
        {
            newEnemy = self.enemiesArray[0];
            newEnemy.isTouched = false;
            newEnemy.y = self.size.height + self.charactersSize.height;
            newEnemy.x = self.pixelSize + (self.charactersSize.width * self.enemyCurrentPositionX);
            newEnemy.zPosition = 10;
            self.enemiesArray.removeAtIndex(0);
            self.enemiesArray.append(newEnemy);
            if(newEnemy.parent == nil)
            {
                self.addChild(newEnemy);
            }
        }
        createEnemy();
        
        //zig-zag
        /*if(self.currentScoreCounter >= Int((self.SCORE_TO_LEVEL_UP.floatValue * self.currentLevelCounter.floatValue) * 0.5))
        {
        createEnemy();
        newEnemy.x = self.pixelSize + (self.charactersSize.width * self.enemyCurrentPositionX);
        self.enemyCurrentPositionX += enemyCurrentPositionIncrement;
        if(self.enemyCurrentPositionIncrement > 0)
        {
        if(self.enemyCurrentPositionX >= self.totalColumns.floatValue)
        {
        self.enemyCurrentPositionIncrement = -1;
        }
        }
        else if(self.enemyCurrentPositionIncrement < 0)
        {
        if(self.enemyCurrentPositionX <= 0)
        {
        self.enemyCurrentPositionIncrement = 1;
        }
        }
        }
        else
        {
        createEnemy();
        }*/
    }
}


