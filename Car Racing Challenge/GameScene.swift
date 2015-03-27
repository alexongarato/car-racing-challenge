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
    //-- pointers --
    private var buttonLeft              : SKSpriteNode!;
    private var buttonRight             : SKSpriteNode!;
    private var mainCharacter           : CustomSpriteNode!;
    private var enemiesArray            : Array<CustomSpriteNode>!;
    private var buttonSize              : CGSize = CGSize();
    private var charactersSize          : CGSize = CGSize();
    private var pixelSize               : CGFloat = 0;
    var updateStatusHandler             : (()->Void)!;
    var gameOverHandler                 : (()->Void)!;
    var levelUpHandler                  : (()->Void)!;
    var lifeUpHandler                   : (()->Void)!;
    var lifeDownHandler                 : (()->Void)!;
    private var defaultFrame            : CGRect!;
    private var totalColumns            : Int = -1;
    private var totalScoreCounter       : Int = 0;
    private var currentScoreCounter     : Int = 0;
    private var totalLifesCounter       : Int = -1;
    private var currentLifeCounter      : Int = -1;
    private var defaultTotalLifes       : Int = 1;
    private var ready                   : Bool = false;
    private var builded                 : Bool = false;
    private var loopsTimeCounter        : CFTimeInterval = -1;
    private var intervalBetweenLoops    : CFTimeInterval = 0.5;
    private var pixelDistanceCounter    : Int = -1;
    private var currentMainCharColumn   : Int = -1;
    private var currentLevelCounter     : Int = 1;
    private var sidesNode               : SKSpriteNode!;
    private var sideNodeFlag            : Bool = false;
    private var sideNodeVelCounter      : CFTimeInterval = 0;
    private var currentVelSound         : Float = 0;
    private var pixelsNode              : SKSpriteNode!;
    private var bg                      : SKSpriteNode!;
    
    //-- configs --
    private let scoreToLevelUp          : Int = 2;//500
    private var scoreToEarnLife         : Int = 100;//100
    private let maximunColumns          : Int = 5;
    private let minimumColumns          : Int = 3;
    private let IDBtLeft                : String = "bt_left";
    private let IDBtRight               : String = "bt_right";
    private let intervalBetweenLevels   : CFTimeInterval = 0.01;
    private let pixelDistanceBtwEnemies : Int = 15;
    
    func currentScoreToNextLife() -> Int
    {
        return self.currentLifeCounter;
    }
    
    func levelUpScore() -> Int
    {
        return self.scoreToLevelUp;
    }
    
    func lifeUpScore() -> Int
    {
        return self.scoreToEarnLife;
    }
    
    func currentColumns() -> Int
    {
        return self.totalColumns;
    }
    
    func setTotalColumns(value:Int)
    {
        if(value >= self.minimumColumns && value <= self.maximunColumns)
        {
            self.totalColumns = value;
            self.build();
        }
        else
        {
            Trace.error("INVALID COLUMN NUMBER (\(value))");
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
        return self.maximunColumns - self.minimumColumns;
    }
    
    func isGamePaused() -> Bool
    {
        if let thisView = self.view
        {
            return thisView.paused;
        }
        return false;
    }
    
    func build()
    {
        if(self.defaultFrame == nil)
        {
            self.defaultFrame = self.frame;
        }
        
        self.removeAllChildren();
        self.sidesNode = nil;
        self.size = self.defaultFrame.size;
        AudioHelper.stopSound(AudioHelper.Vel4Sound);
        
        /**
        inicializar variaveis
        */
        self.totalColumns               = self.totalColumns == -1 ? self.maximunColumns : self.totalColumns;
//        self.totalLifesCounter          = self.defaultTotalLifes;
        var totalPixelsX:Int            = Int((self.totalColumns * 3) + 2);
        self.enemiesArray               = Array<CustomSpriteNode>();
        self.pixelSize                  = CGFloat(self.size.width / totalPixelsX.floatValue);
        var totalPixelsY:Int            = Int((self.size.height / self.pixelSize));
        self.charactersSize.width       = self.pixelSize * 3;
        self.charactersSize.height      = self.pixelSize * 4;
        self.buttonSize.width           = self.size.width.half.roundValue;
        self.buttonSize.height          = self.pixelSize * 4;
        self.currentMainCharColumn      = self.totalColumns / 2;
        self.pixelDistanceCounter       = self.pixelDistanceBtwEnemies;
        self.currentVelSound            = 0;
        self.intervalBetweenLoops       = 0.5;
//        self.currentLifeCounter         = self.scoreToEarnLife;
        
        self.bg = nil;
        self.pixelsNode = nil;
        self.sidesNode = nil;
        self.mainCharacter = nil;
        self.buttonLeft = nil;
        self.buttonRight = nil;
        
        Trace.log("GameScene -> pixelSize:\(self.pixelSize)");
        
        /**
        criar malha de pixels de acordo com a quantidade de pistas.
        */
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
        sidesNode = SKSpriteNode(texture: Utils.createRoadPixels(self.size, totalPixelsX: totalPixelsX, totalPixelsY: totalPixelsY, pixelSize: self.pixelSize));
        self.addChild(sidesNode);
        sidesNode.zPosition = 1;
        sidesNode.anchorPoint.x = 0;
        sidesNode.anchorPoint.y = 1;
        sidesNode.x = 0;
        sidesNode.y = self.size.height;
        //---------------------
        
        
        /**
        cria os personagens do jogo
        */
        self.mainCharacter = CustomSpriteNode(texture: Utils.createCarTexture(self.charactersSize, pixelWidth: self.pixelSize, pixelHeight: self.pixelSize));
        self.mainCharacter.size = self.charactersSize;
        self.mainCharacter.anchorPoint.x = 0;
        self.mainCharacter.anchorPoint.y = 1;
        self.mainCharacter.x = self.pixelSize + (self.charactersSize.width * self.currentMainCharColumn.floatValue);
        self.addChild(self.mainCharacter);
        
        /**
        cria os controles do jogo
        */
        self.buttonLeft = SKSpriteNode(imageNamed: ImagesNames.Background);
        self.buttonLeft.size = self.buttonSize;
        self.buttonLeft.anchorPoint.y = 1;
        self.buttonLeft.x = self.buttonLeft.width.half;
        var pxCount:CGFloat = (55 / self.pixelSize).roundValue;
        pxCount = pxCount == 0 ? 1 : pxCount;
        var heightPixels:CGFloat = (totalPixelsY.floatValue - pxCount);
        self.buttonLeft.y = self.size.height - (self.pixelSize * heightPixels);
        self.buttonLeft.name = self.IDBtLeft;
        self.addChild(self.buttonLeft);
        var labelLeft:SKLabelNode = SKLabelNode(fontNamed: FontNames.Default);
        labelLeft.text = "LEFT";
        labelLeft.fontSize = FontSize.Default;
        labelLeft.fontColor = UIColor.blackColor();
        labelLeft.position.y -= 30;
        labelLeft.name = self.IDBtLeft;
        self.buttonLeft.addChild(labelLeft);
        
        self.buttonRight = SKSpriteNode(imageNamed: ImagesNames.Background);
        self.buttonRight.size = self.buttonSize;
        self.buttonRight.anchorPoint.y = 1;
        self.buttonRight.x = self.size.width - self.buttonRight.width.half;
        self.buttonRight.y = self.buttonLeft.y;
        self.buttonRight.name = self.IDBtRight;
        self.addChild(self.buttonRight);
        var labelRight:SKLabelNode = SKLabelNode(fontNamed: FontNames.Default);
        labelRight.text = "RIGHT";
        labelRight.fontSize = FontSize.Default;
        labelRight.fontColor = UIColor.blackColor();
        labelRight.position.y -= 30;
        labelRight.name = self.IDBtRight;
        self.buttonRight.addChild(labelRight);
        
        self.mainCharacter.y = self.buttonLeft.y + self.mainCharacter.height;
        
        /**
        configurar posicao z da interface
        */
        self.mainCharacter.zPosition = 20;
        self.buttonLeft.zPosition = 21;
        self.buttonRight.zPosition = 22;
        
        
        self.builded = true;
    }
    
    func reset()
    {
        self.totalColumns = -1;
        self.totalLifesCounter = self.defaultTotalLifes;
        self.ready = false;
        self.builded = false;
        self.pixelDistanceCounter = -1;
        self.currentMainCharColumn = -1;
        self.intervalBetweenLoops = 0.5;
        self.currentLevelCounter = 1;
        self.currentScoreCounter = 0;
        self.totalScoreCounter = 0;
        self.currentLifeCounter = self.scoreToEarnLife;
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
            Trace.error("GAME IS NOT READY!");
            return;
        }
        
        AudioHelper.playSound("vel_\(Int(self.currentVelSound)).wav");
        
        self.ready = true;
        self.view?.paused = false;
        self.updateStatusHandler();
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        if(!self.ready)
        {
            return;
        }
        
        if(currentTime >= self.sideNodeVelCounter)
        {
            self.sideNodeVelCounter = currentTime + intervalBetweenLoops * 0.5;
            
            if(!sideNodeFlag)
            {
                sideNodeFlag = true;
                sidesNode.y = self.size.height - pixelSize;
            }
            else
            {
                sideNodeFlag = false;
                sidesNode.y = self.size.height;
            }
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
            if(self.pixelDistanceCounter >= self.pixelDistanceBtwEnemies)
            {
                self.pixelDistanceCounter = 0;
                addNewEnemy();
            }
            
            for enemyBlock in enemiesArray
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
                        self.currentLifeCounter--;
                        
                        if(self.currentLifeCounter < 0)
                        {
                            self.currentLifeCounter = self.scoreToEarnLife;
                            self.totalLifesCounter++;
                            
                            if(self.lifeUpHandler != nil)
                            {
                                self.lifeUpHandler();
                            }
                            
                            AudioHelper.playSound(AudioHelper.PickupCoinSound);
                        }
                        
                        if(self.currentScoreCounter >= self.scoreToLevelUp)
                        {
                            self.currentScoreCounter = 0;
                            self.currentLevelCounter++;
                            self.levelUpHandler();
                        }
                    }
                    
                    self.removeChildrenInArray([enemyBlock]);
                    if(enemiesArray.count > 0)
                    {
                        enemiesArray.removeAtIndex(0);
                    }
                    self.updateStatusHandler();
                }
            }
        }
        
        for enemyBlock in enemiesArray
        {
//            if(enemyBlock.intersectsNode(mainCharacter)/* && !Configs.DEBUG_MODE*/)
            if(enemyBlock.x >= mainCharacter.x - 1 && enemyBlock.x <= mainCharacter.x + 1
                && enemyBlock.y - charactersSize.height < mainCharacter.y && enemyBlock.y > mainCharacter.y - charactersSize.height + 2)
            {
                if(!enemyBlock.isTouched)
                {
                    enemyBlock.isTouched = true;
                    
                    /**
                    customizar inimigo quando atingido
                    */
                    enemyBlock.color = UIColor.blueColor();
                    
                    
                    /**
                    atualizacao das variaveis do jogo
                    */
                    AudioHelper.playSound(AudioHelper.lostLifeSound);
                    
                    self.totalLifesCounter--;
                    self.updateStatusHandler();
                    
                    if(self.lifeDownHandler != nil)
                    {
                        self.lifeDownHandler();
                    }
                    
                    if(self.totalLifesCounter < 0)
                    {
                        self.totalLifesCounter = 0;
                        self.gameOverHandler();
                    }
                }
            }
        }
        
        if(self.intervalBetweenLoops > 0.03)
        {
            self.intervalBetweenLoops -= 0.003;
        }
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
            if(node.name == self.IDBtLeft)
            {
                AudioHelper.playSound(AudioHelper.SelectSound);
                
                self.currentMainCharColumn--;
                if(self.currentMainCharColumn < 0)
                {
                    self.currentMainCharColumn = 0;
                }
            }
            
            if(node.name == self.IDBtRight)
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
    
    private func addNewEnemy()
    {
        var newEnemy:CustomSpriteNode = CustomSpriteNode(texture: Utils.createCarTexture(self.charactersSize, pixelWidth: self.pixelSize, pixelHeight: self.pixelSize), size: self.charactersSize);
        newEnemy.size = self.charactersSize;
        newEnemy.anchorPoint.x = 0;
        newEnemy.anchorPoint.y = 1;
        newEnemy.x = self.pixelSize + (self.charactersSize.width * Utils.random(self.totalColumns - 1).floatValue);
        newEnemy.y = self.size.height + self.charactersSize.height;
        newEnemy.zPosition = 10;
//        newEnemy.width -= 0.01;//resolve o bug do intersectsNode
        self.addChild(newEnemy);
        self.enemiesArray.append(newEnemy);
    }
}


