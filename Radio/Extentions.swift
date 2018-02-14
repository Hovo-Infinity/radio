//
//  Extentions.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 7/26/17.
//  Copyright © 2017 Hovhannes Stepanyan. All rights reserved.
//

import UIKit
import AVFoundation

extension FileManager {
    func createSubdirectoryOfSongPath(maned name:String) -> Bool {
        let url = FileManager.songPath().appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: url.absoluteString) {
            return true;
        } else {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
                return false
            }
            return true
        }
    }
    
    class func songPath() -> URL {
        do {
            var url = try FileManager.default.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true);
            url.appendPathComponent("music");
            if (!FileManager.default.fileExists(atPath: url.absoluteString)) {
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil);
                } catch {
                    print(error.localizedDescription);
                }
            }
            return url;
        } catch {
            return URL(string: "")!;
        }
    }
    
    func directoryExcist(atPath:String) -> Bool {
        var isDictionary:ObjCBool = false
        self.fileExists(atPath: atPath, isDirectory: &isDictionary)
        return isDictionary.boolValue
    }
    
    func contentsOfDirectory(at path:URL) throws -> Array<URL> {
        do {
            return try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles);
        } catch {
            throw error;
        }
    }
}

extension AVPlayer {
    static let sharedPlayer = AVPlayer();
    open func stop() {
        self.pause();
        self.seek(to: CMTime(value: 0, timescale: AVPlayer.sharedPlayer.currentTime().timescale));
    }
    open func addObserver(_ observer:UISlider?, forTimePeriod seconds:Float) {
        self.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1000000000), queue: DispatchQueue.main) { (time) in
            let value = Float((self.currentItem?.asset.duration.seconds)!);
            observer?.maximumValue = value;
            observer?.setValue(Float(time.seconds), animated: true);
        }
    }
}

let _sharedPlayer:AVAudioPlayer = AVAudioPlayer();

extension AVAudioPlayer {
    class func sharedAudioPlayer() -> AVAudioPlayer {
        return _sharedPlayer;
    }
}

class AVPlayerDelegate : NSObject {
    private static let share:AVPlayerDelegate = AVPlayerDelegate();
    class func sharedInstance() -> AVPlayerDelegate {
        return share;
    }
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: Selector(("playerNotifListen")), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    private func playerNotifListen(_ note:Notification) {
        print(note.userInfo ?? "");
        let _ = note.object;
    }
}
