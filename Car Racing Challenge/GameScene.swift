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
    let SCORE_TO_LEVEL_UP               : Int = 150;//500
    let SCORE_TO_EARN_LIFE              : Int = 999999;//100
    fileprivate let MAX_COLUMNS             : Int = 5;
    fileprivate let MIN_COLUMNS             : Int = 5;
    fileprivate let ID_BT_LEFT              : String = "bt_left";
    fileprivate let ID_BT_RIGHT             : String = "bt_right";
    fileprivate let INT_BETWEEN_LEVELS      : CFTimeInterval = 0.01;
    fileprivate let PIXELS_BETWEEN_ENEMIES_1: Int = 19;
    fileprivate let MIN_PX_BT_ENEMIES_1     : Int = 10;
    fileprivate let IS_LIFE_BONUS_MODE      : Bool = false;
    fileprivate let IS_LEVEL_MODE           : Bool = true;
    fileprivate let INITIAL_USER_LIFES      : Int = 0;
    fileprivate let ROAD_PIXELS_INTERVAL    : Int = 4;
    
    
    //-- pointers --
    var updateStatusHandler             : (()->Void)!;
    var gameOverHandler                 : (()->Void)!;
    var levelUpHandler                  : (()->Void)!;
    var lifeUpHandler                   : (()->Void)!;
    var lifeDownHandler                 : (()->Void)!;
    fileprivate var leftButton              : SKSpriteNode!;
    fileprivate var rightButton             : SKSpriteNode!;
    fileprivate var mainCharacter           : CustomSpriteNode!;
    fileprivate var poolOfEnemiesSprites    : Array<CustomSpriteNode> = Array<CustomSpriteNode>();
    fileprivate var buttonSize              : CGSize = CGSize();
    fileprivate var charactersSize          : CGSize = CGSize();
    fileprivate var pixelSize               : CGFloat = 0;
    fileprivate var defaultFrame            : CGRect!;
    fileprivate var totalColumns            : Int = -1;
    fileprivate var totalScoreCounter       : Int = 0;
    fileprivate var currentScoreCounter     : Int = 0;
    fileprivate var totalLifesCounter       : Int = -1;
    fileprivate var currentLifeCounter      : Int = -1;
    fileprivate var ready                   : Bool = false;
    fileprivate var builded                 : Bool = false;
    fileprivate var loopsTimeCounter        : CFTimeInterval = -1;
    fileprivate var intervalBetweenLoops    : CFTimeInterval = 0.5;
    fileprivate var minIntervalForThisDevice: CFTimeInterval = 0.5;
    fileprivate var pixelDistanceCounter    : Int = -1;
    fileprivate var currentMainCharColumn   : Int = -1;
    fileprivate var currentLevelCounter     : Int = 1;
    fileprivate var trackTexture               : SKSpriteNode!;
    fileprivate var sideNodeFlag            : Bool = false;
    fileprivate var sideNodeVelCounter      : CFTimeInterval = 0;
    fileprivate var currentVelSound         : Float = 0;
    fileprivate var pixelsGridTexture              : SKSpriteNode!;
    fileprivate var lcdTexture                      : SKSpriteNode!;
    fileprivate var isGameOver              : Bool = false;
    fileprivate var currentEnemiesVector    : Array<EnemySheet>!;
    fileprivate var currEnemiesVectorCounter: Int = 0;
    fileprivate var mainTimer               : Timer!;
    
    func currentScoreToNextLife() -> Int
    {
        return self.currentLifeCounter;
    }
    
    func currentColumns() -> Int
    {
        return self.totalColumns;
    }
    
    func setTotalColumns(_ value:Int)
    {
        if(value >= self.MIN_COLUMNS && value <= self.MAX_COLUMNS)
        {
            self.totalColumns = value;
            self.build();
        }
        else
        {
            print("INVALID COLUMN NUMBER (\(value))");
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
            return thisView.isPaused;
        }
        
        return true;
    }
    
    func build()
    {
        if(self.defaultFrame == nil)
        {
            self.defaultFrame = self.frame;
        }
        
        self.resetTimer();
        
        self.size = self.defaultFrame.size;
        AudioHelper.stopSound(AudioHelper.Vel4Sound);
        
        /**
        inicializar variaveis
        */
        self.isGameOver                 = false;
        self.totalColumns               = self.totalColumns == -1 ? self.MAX_COLUMNS : self.totalColumns;
        let totalPixelsX:Int            = Int((self.totalColumns * 3) + 2);
        //        self.enemiesArray               = Array<CustomSpriteNode>();
        self.pixelSize                  = CGFloat(self.size.width / totalPixelsX.floatValue);
        let totalPixelsY:Int            = Int((self.size.height / self.pixelSize));
        self.charactersSize.width       = self.pixelSize * 3;
        self.charactersSize.height      = self.pixelSize * 4;
        self.buttonSize.width           = self.size.width.half.roundValue;
        self.buttonSize.height          = self.size.height;
        self.currentMainCharColumn      = self.totalColumns / 2;
        self.pixelDistanceCounter       = self.PIXELS_BETWEEN_ENEMIES_1;
        self.currentVelSound            = 0;
        self.resetIntervalBetweenLoops();
        self.currentEnemiesVector       = GameHelper.getInstance().enemiesForLevel(self.currentLevelCounter);
        self.currEnemiesVectorCounter   = 0;
        
        if(self.poolOfEnemiesSprites.count > 0)
        {
            self.removeChildren(in: self.poolOfEnemiesSprites);
            self.poolOfEnemiesSprites.removeAll(keepingCapacity: false);
        }
        
        print("GameScene -> pixelSize:\(self.pixelSize)");
        
        /**
        criar malha de pixels de acordo com a quantidade de pistas.
        */
        if(self.mainCharacter == nil)
        {
            //#C3DD85
            if(UICustomDevice.avoidTexture())
            {
                self.scene?.backgroundColor = Colors.green;
            }
            else
            {
                lcdTexture = SKSpriteNode(imageNamed: ImagesNames.Background);
                lcdTexture.size = self.size;
                lcdTexture.anchorPoint.x = 0;
                lcdTexture.anchorPoint.y = 1;
                lcdTexture.x = 0;
                lcdTexture.y = lcdTexture.height;
                self.addChild(lcdTexture);
                //---------------------
            }
            //desenha a malha no context
            pixelsGridTexture = SKSpriteNode(texture: Utils.createPixelsGrid(self.size, totalPixelsX: totalPixelsX, totalPixelsY: totalPixelsY, pixelSize: self.pixelSize));
            self.addChild(pixelsGridTexture);
            pixelsGridTexture.zPosition = 1;
            pixelsGridTexture.anchorPoint.x = 0;
            pixelsGridTexture.anchorPoint.y = 1;
            pixelsGridTexture.x = 0;
            pixelsGridTexture.y = self.size.height;
            //---------------------
            

            //cria as laterias temporarias que serao desenhadas no context
            trackTexture = SKSpriteNode(texture: Utils.createRoadPixels(CGSize(width: self.size.width, height: self.size.height + (self.pixelSize * (ROAD_PIXELS_INTERVAL.floatValue * 2))), totalPixelsX: totalPixelsX, totalPixelsY: totalPixelsY + ROAD_PIXELS_INTERVAL * 2, pixelSize: self.pixelSize));
            self.addChild(trackTexture);
            trackTexture.zPosition = 1;
            trackTexture.anchorPoint.x = 0;
            trackTexture.anchorPoint.y = 1;
            trackTexture.x = 0;
            trackTexture.y = self.size.height;
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
            self.leftButton = SKSpriteNode();
            self.leftButton.size = self.buttonSize;
            self.leftButton.anchorPoint.y = 1;
            self.leftButton.x = self.leftButton.width.half;
            self.leftButton.y = self.size.height;
            self.leftButton.name = self.ID_BT_LEFT;
            self.addChild(self.leftButton);
            
            self.rightButton = SKSpriteNode();
            self.rightButton.size = self.buttonSize;
            self.rightButton.anchorPoint.y = 1;
            self.rightButton.x = self.size.width - self.rightButton.width.half;
            self.rightButton.y = self.leftButton.y;
            self.rightButton.name = self.ID_BT_RIGHT;
            self.addChild(self.rightButton);

            self.mainCharacter.y = self.size.height - (self.pixelSize * totalPixelsY.floatValue) + self.mainCharacter.height;
        }
        
        self.trackTexture.y = self.size.height;
        self.mainCharacter.x = self.pixelSize + (self.charactersSize.width * self.currentMainCharColumn.floatValue);
        
        if(self.lcdTexture != nil)
        {
            self.lcdTexture.zPosition = 17;
        }
        self.pixelsGridTexture.zPosition = 18;
        self.trackTexture.zPosition = 19;
        self.mainCharacter.zPosition = 20;
        self.leftButton.zPosition = 21;
        self.rightButton.zPosition = 22;
        
        self.ready = false;
        self.view?.isPaused = true;
        
        self.builded = true;
    }
    
    func resetTimer()
    {
        if(self.mainTimer != nil)
        {
            self.mainTimer.invalidate();
            self.mainTimer = nil;
        }
    }
    
    func resetIntervalBetweenLoops()
    {
        self.intervalBetweenLoops = 0.5;
        if(UIDevice.current.model == "iPad")
        {
            self.minIntervalForThisDevice = 0.035;
        }
        else
        {
            self.minIntervalForThisDevice = 0.03;
        }
    }
    
    func reset()
    {
        self.resetTimer();
        self.totalColumns = -1;
        self.ready = false;
        self.view?.isPaused = true;
        self.builded = false;
        self.pixelDistanceCounter = -1;
        self.currentMainCharColumn = -1;
        self.resetIntervalBetweenLoops();
        self.currentLevelCounter = 1;
        self.currentScoreCounter = 0;
        self.totalScoreCounter = 0;
        self.totalLifesCounter = self.INITIAL_USER_LIFES;
        self.currentLifeCounter = self.SCORE_TO_EARN_LIFE;
        self.updateStatusHandler();
    }
    
    func stop()
    {
        self.resetTimer();
        self.ready = false;
        self.view?.isPaused = true;
        self.trackTexture.removeAllActions();
        self.trackTexture.isPaused = true;
        //self.resetIntervalBetweenLoops();
        //self.currentVelSound = 0;
        AudioHelper.stopSound(AudioHelper.Vel4Sound);
    }
    
    func start()
    {
        if(!self.builded)
        {
            print("GAME IS NOT READY!");
            return;
        }
        
        AudioHelper.playSound("vel_\(Int(self.currentVelSound)).wav");
        
        self.ready = true;
        self.isPaused = false;
        self.view?.isPaused = false;
        self.trackTexture.isPaused = false;
        self.updateStatusHandler();
        /*startTrackAnima();*/
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        if(!self.ready)
        {
            self.resetTimer();
            return;
        }
        
        if(currentTime > self.loopsTimeCounter)
        {
            self.loopsTimeCounter = currentTime + self.intervalBetweenLoops;
            self.update();
        }
    }
    
    fileprivate var newDistance:Int = -1;
    func update()
    {
        //self.mainTimer = Utils.delayedCall(self.intervalBetweenLoops, target: self, selector: Selector("update"), repeats: false);
        
        self.trackTexture.y -= self.pixelSize;
        if(self.trackTexture.y <= self.size.height)
        {
            self.trackTexture.y = self.size.height + (self.pixelSize * self.ROAD_PIXELS_INTERVAL.floatValue);
        }
        
        if(self.intervalBetweenLoops > self.minIntervalForThisDevice)
        {
            self.intervalBetweenLoops -= 0.1;
            if(self.intervalBetweenLoops < self.minIntervalForThisDevice)
            {
                self.intervalBetweenLoops = self.minIntervalForThisDevice;
            }
        }
        
        if(self.currentVelSound < 4)
        {
            self.currentVelSound += 0.5;
            AudioHelper.playSound("vel_\(Int(self.currentVelSound)).wav");
        }
        
        self.pixelDistanceCounter += 1;
        self.newDistance = (self.PIXELS_BETWEEN_ENEMIES_1 - self.currentLevelCounter);
        self.newDistance = self.newDistance < self.MIN_PX_BT_ENEMIES_1 ? self.MIN_PX_BT_ENEMIES_1 : self.newDistance;
        if(self.pixelDistanceCounter >= self.newDistance)
        {
            self.pixelDistanceCounter = 0;
            self.addNewEnemy();
        }
        
        
        for enemyBlock in self.poolOfEnemiesSprites
        {
            if(!enemyBlock.isDead)
            {
                enemyBlock.y -= self.pixelSize;
                
                if(enemyBlock.y + enemyBlock.height.half < 0)//se saiu da tela
                {
                    enemyBlock.isDead = true;
                    
                    if(!enemyBlock.isTouched)//se nao foi tocado
                    {
                        self.totalScoreCounter += 1;
                        self.currentScoreCounter += 1;
                        
                        if(self.IS_LIFE_BONUS_MODE)
                        {
                            self.currentLifeCounter -= 1;
                            if(self.currentLifeCounter < 0)
                            {
                                self.currentLifeCounter = self.SCORE_TO_EARN_LIFE;
                                self.totalLifesCounter += 1;
                                
                                if(self.lifeUpHandler != nil)
                                {
                                    self.lifeUpHandler();
                                }
                                
                                AudioHelper.playSound(AudioHelper.PickupCoinSound);
                            }
                        }
                        
                        if(self.IS_LEVEL_MODE)
                        {
                            if(self.currentScoreCounter >= self.SCORE_TO_LEVEL_UP)
                            {
                                self.currentScoreCounter = 0;
                                self.currentLevelCounter += 1;
                                self.levelUpHandler();
                                self.resetIntervalBetweenLoops();
                                self.build();
                            }
                        }
                    }
                    
                    //self.removeChildrenInArray([enemyBlock]);
                    self.updateStatusHandler();
                }
                else if(enemyBlock.x >= self.mainCharacter.x - 1 && enemyBlock.x <= self.mainCharacter.x + 1
                    && enemyBlock.y - self.charactersSize.height < self.mainCharacter.y && enemyBlock.y > self.mainCharacter.y - self.charactersSize.height + 2)
                {
                    
                    if(!enemyBlock.isTouched)
                    {
                        enemyBlock.isTouched = true;
                        
                        AudioHelper.playSound(AudioHelper.lostLifeSound);
                        
                        self.totalLifesCounter -= 1;
                        
                        if(self.IS_LIFE_BONUS_MODE)
                        {
                            if(self.lifeDownHandler != nil)
                            {
                                self.lifeDownHandler();
                            }
                        }
                        
                        if(self.totalLifesCounter < 0)
                        {
                            self.totalLifesCounter = 0;
                            self.isGameOver = true;
                            print("x:\(enemyBlock.x)|y:\(enemyBlock.y)");
                            self.gameOverHandler();
                        }
                        
                        self.updateStatusHandler();
                    }
                }
            }
        }
        
        for i in stride(from: (self.poolOfEnemiesSprites.count-1), to:0, by:-1)
        {
            let enemyBlock = self.poolOfEnemiesSprites[i];
            if(enemyBlock.isDead)
            {
                self.poolOfEnemiesSprites.removeLast();
            }
            else
            {
                break;
            }
        }
    }
    
    fileprivate func addNewEnemy()
    {
        var newEnemy:CustomSpriteNode!;
        func createEnemy(_ col:CGFloat)
        {
            //            newEnemy = self.poolOfEnemiesSprites[0];
            newEnemy = CustomSpriteNode(texture: Utils.createCarTexture(self.charactersSize, pixelWidth: self.pixelSize, pixelHeight: self.pixelSize), size: self.charactersSize);
            newEnemy.size = self.charactersSize;
            newEnemy.anchorPoint.x = 0;
            newEnemy.anchorPoint.y = 1;
            newEnemy.y = self.size.height + self.charactersSize.height;
            newEnemy.x = self.pixelSize + (self.charactersSize.width * col);
            newEnemy.zPosition = self.pixelsGridTexture.zPosition + 1;
            self.poolOfEnemiesSprites.append(newEnemy);
            self.addChild(newEnemy);
        }
        
        if (self.currentEnemiesVector != nil && self.currEnemiesVectorCounter < self.currentEnemiesVector.count)
        {
            let sheet = self.currentEnemiesVector[self.currEnemiesVectorCounter]
            for i in 0 ..< sheet.lineArr.count
            {
                if(sheet.lineArr[i].hasPrefix("1"))
                {
                    createEnemy(i.floatValue);
                }
            }
        }
        else
        {
            //TODO - se nao existir array do level, usar modo aleatorio.
            createEnemy(Utils.random(self.totalColumns - 1).floatValue);
        }
        self.currEnemiesVectorCounter += 1;
    }
    
    
    //---------- road anima -------------
    /*private func trackAction() -> SKAction
    {
        var act = SKAction.moveToY(self.size.height - 1, duration: 0.05 + self.intervalBetweenLoops);
        act.timingMode = SKActionTimingMode.Linear;
        return act;
    }
    
    private func trackCompletion()
    {
        if(!self.isGameOver/* && !self.isGamePaused()*/)
        {
            startTrackAnima();
        }
        else
        {
            print("ERROR");
        }
    }
    
    private func startTrackAnima()
    {
        self.trackTexture.y = self.size.height + (self.pixelSize * self.ROAD_PIXELS_INTERVAL.floatValue) + 1;
        self.trackTexture.runAction(self.trackAction(), completion: self.trackCompletion);
    }*/
    //----------
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if(!self.ready)
        {
            return;
        }
        
        /* Called when a touch begins */
        for touch: AnyObject in touches
        {
            let location = touch.location(in: self)
            let node:SKNode = self.atPoint(location);
            if(node.name == self.ID_BT_LEFT)
            {
                AudioHelper.playSound(AudioHelper.SelectSound);
                
                self.currentMainCharColumn-=1;
                if(self.currentMainCharColumn < 0)
                {
                    self.currentMainCharColumn = 0;
                }
            }
            
            if(node.name == self.ID_BT_RIGHT)
            {
                AudioHelper.playSound(AudioHelper.SelectSound);
                
                self.currentMainCharColumn+=1;
                if(self.currentMainCharColumn > self.totalColumns - 1)
                {
                    self.currentMainCharColumn = self.totalColumns - 1;
                }
            }
            
            let tmp = self.mainCharacter.physicsBody;
            self.mainCharacter.physicsBody = nil;
            self.mainCharacter.x = self.pixelSize + (self.charactersSize.width * self.currentMainCharColumn.floatValue);
            self.mainCharacter.physicsBody = tmp;
        }
    }
}


