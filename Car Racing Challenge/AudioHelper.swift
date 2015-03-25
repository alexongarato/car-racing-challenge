//
//  AudioHelper.swift
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 23/03/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

import Foundation
import AVFoundation

private var snds: NSMutableDictionary = NSMutableDictionary();

class AudioHelper
{
    static var EntranceSound    : String = "entrance.wav";
    static var SelectSound      : String = "Blip_Select.wav";
    static var GameOverSound    : String = "Explosion2.wav";
    static var PickupCoinSound  : String = "Pickup_Coin.wav";
    static var LevelUpSound     : String = "level_up.wav";
    static var Vel0Sound        : String = "vel_0.wav";
    static var Vel1Sound        : String = "vel_1.wav";
    static var Vel2Sound        : String = "vel_2.wav";
    static var Vel3Sound        : String = "vel_3.wav";
    static var Vel4Sound        : String = "vel_4.wav";
    static var MenuOpenSound    : String = "menu_open.wav";
    static var StartGameSound   : String = "entrance2.wav";
    static var lostLifeSound    : String = "Randomize.wav";
    
    class func didFinishLaunchingWithOptions()
    {
        buildAudio(EntranceSound,   volume: 0.4, timeStart: 0, rate: 1.0, loops: 0);
        buildAudio(SelectSound,     volume: 0.15, timeStart: 0, rate: 1.0, loops: 0);
        buildAudio(GameOverSound,   volume: 0.4, timeStart: 0, rate: 1.0, loops: 0);
        buildAudio(PickupCoinSound, volume: 0.4, timeStart: 0, rate: 1.0, loops: 0);
        buildAudio(LevelUpSound,    volume: 0.4, timeStart: 0, rate: 1.0, loops: 0);
        buildAudio(Vel0Sound,       volume: 0.4, timeStart: 0, rate: 1.0, loops: 0);
        buildAudio(Vel1Sound,       volume: 0.3, timeStart: 0, rate: 1.0, loops: 0);
        buildAudio(Vel2Sound,       volume: 0.2, timeStart: 0, rate: 1.0, loops: 0);
        buildAudio(Vel3Sound,       volume: 0.1, timeStart: 0, rate: 1.0, loops: 0);
        buildAudio(Vel4Sound,       volume: 0.05, timeStart: 0, rate: 1.0, loops: -1);
        buildAudio(MenuOpenSound,   volume: 0.4, timeStart: 0, rate: 1.0, loops: 0);
        buildAudio(StartGameSound,  volume: 0.4, timeStart: 0, rate: 1.0, loops: 0);
        buildAudio(lostLifeSound,   volume: 0.2, timeStart: 0, rate: 1.0, loops: 0);
    }
    
    private class func buildAudio(name:String, volume:Float, timeStart:NSTimeInterval, rate:Float, loops:Int)
    {
        var path    : String! = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent(name);
        var err     : NSError!;
        var snd      :CustomAVAudioPlayer!;
        
        if (NSFileManager.defaultManager().fileExistsAtPath(path))
        {
            var url = NSURL(fileURLWithPath: path)!;
            var snd:CustomAVAudioPlayer! = CustomAVAudioPlayer(contentsOfURL: url, error: nil);
            if(snd != nil)
            {
                snd.volume = volume;
                snd.numberOfLoops = loops;
                snd.currentTime = timeStart;
                snd.enableRate = true;
                snd.rate = rate;
                
                snds.setValue(snd, forKey: name);
            }
            
        } else
        {
            Trace.log("Sound file '\(name)' doesn't exist at '\(path)'");
        }
    }
    
    class func stopSound(name:String) -> CustomAVAudioPlayer!
    {
        var tmp:AnyObject! = snds.valueForKey(name);
        var snd:CustomAVAudioPlayer!;
        if (tmp != nil)
        {
            if let sndTmp = tmp as? CustomAVAudioPlayer
            {
                snd = sndTmp;
                snd.stop();
            }
        }
        else
        {
            Trace.log("Sound file '\(name)' error");
        }
        
        return snd;
    }
    
    class func playSound(name:String) -> CustomAVAudioPlayer!
    {
        var tmp:AnyObject! = snds.valueForKey(name);
        var snd:CustomAVAudioPlayer!;
        if (tmp != nil)
        {
            if let sndTmp = tmp as? CustomAVAudioPlayer
            {
                snd = sndTmp;
                snd.prepareToPlay();
                snd.play();
            }
        }
        else
        {
            Trace.log("Sound file '\(name)' error");
        }
        
        return snd;
    }
}

class CustomAVAudioPlayer:AVAudioPlayer, AVAudioPlayerDelegate
{
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool)
    {
//        self.finalize();
    }
}