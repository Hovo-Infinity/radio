//
//  AppDelegate.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 7/25/17.
//  Copyright © 2017 Hovhannes Stepanyan. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSecondaryAudio),
                                               name: .AVAudioSessionSilenceSecondaryAudioHint,
                                               object: AVAudioSession.sharedInstance())
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        application.isIdleTimerDisabled = false
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.isIdleTimerDisabled = true
        application.beginReceivingRemoteControlEvents();
        setupCommandCenter()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        application.endReceivingRemoteControlEvents()
    }
    
    @objc func handleSecondaryAudio(notification: Notification) {
        // Determine hint type
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt,
            let type = AVAudioSessionSilenceSecondaryAudioHintType(rawValue: typeValue) else {
                return
        }
        
        if type == .begin {
            // Other app audio started playing - mute secondary audio
            AVAudioPlayer.sharedAudioPlayer().pause()
        } else {
            // Other app audio stopped playing - restart secondary audio
            AVAudioPlayer.sharedAudioPlayer().play()
        }
    }
    
    private func setupCommandCenter() {
        guard let currentItem = AVPlayer.sharedPlayer.currentItem else { return }
        let asset = currentItem.asset
        var nowPlayingInfo = [String: Any]()
        for metaDataItems in asset.commonMetadata {
            //getting the title of the song
            if metaDataItems.commonKey!.rawValue == "title" {
                let titleData = metaDataItems.value as! NSString
                nowPlayingInfo[MPMediaItemPropertyTitle] = titleData
            }
            //getting the "Artist of the mp3 file"
            if metaDataItems.commonKey!.rawValue == "artist" {
                let artistData = metaDataItems.value as! NSString
                nowPlayingInfo[MPMediaItemPropertyArtist] = artistData
                print("artist ---> \(artistData)")
            }
            //getting the thumbnail image associated with file
            if metaDataItems.commonKey!.rawValue == "artwork" {
                let imageData = metaDataItems.value as! Data
                let image2: UIImage = UIImage(data: imageData)!
                nowPlayingInfo[MPMediaItemPropertyArtwork] = image2
            }
        }
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: currentItem.duration.seconds)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            AVQueuePlayer.sharedPlayer.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            AVQueuePlayer.sharedPlayer.pause()
            return .success
        }
        commandCenter.changePlaybackPositionCommand.addTarget(handler: {
            if $0 is MPChangePlaybackPositionCommandEvent {
                let timePosition = ($0 as! MPChangePlaybackPositionCommandEvent).positionTime
                AVPlayer.sharedPlayer.currentItem?.seek(to: CMTime(seconds: timePosition, preferredTimescale: 1))
            }
            return .success
        })
        
    }

}

