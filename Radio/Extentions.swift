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
}

let _sharedPlayer:AVAudioPlayer = AVAudioPlayer();

extension AVAudioPlayer {
    class func sharedAudioPlayer() -> AVAudioPlayer {
        return _sharedPlayer;
    }
}
