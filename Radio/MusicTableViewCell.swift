//
//  MusicTableViewCell.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 7/28/17.
//  Copyright © 2017 Hovhannes Stepanyan. All rights reserved.
//

import UIKit
import AVFoundation

class MusicTableViewCell: UITableViewCell, AVAudioPlayerDelegate {
    private let player = AVQueuePlayer.sharedPlayer
    public var anItem : AVPlayerItem? = nil
    public var url:URL? = nil
    var playButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("CountryCode = %@",LocationManagerHandler.sharedManager().countryCode)
        initPlayButton()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        initPlayButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playButton.frame = CGRect(x: self.bounds.width - 36 - 16, y: 14, width: 36, height: 36)
    }
    
    private func initPlayButton() {
        playButton = UIButton()
        playButton.setBackgroundImage(UIImage(named: "play"), for: .normal)
        playButton.addTarget(self, action: #selector(play(_:)), for: .touchUpInside)
        addSubview(playButton)
    }

    @objc func play(_ sender: Any) {
        if (self.player.currentItem != self.anItem) {
            self.player.stop()
            self.player.replaceCurrentItem(with: self.anItem)
            self.player.play()
        } else {
            if (self.player.status == AVPlayerStatus.readyToPlay) {
                if #available(iOS 10.0, *) {
                    if (self.player.timeControlStatus == AVPlayerTimeControlStatus.waitingToPlayAtSpecifiedRate ||
                        self.player.timeControlStatus == AVPlayerTimeControlStatus.paused) {
                        self.player.play()
                    } else {
                        self.player.pause()
                    }
                } else {
                    // Fallback on earlier versions
                    if (self.player.rate == 0.0) {
                        self.player.play()
                    } else {
                        player.pause()
                    }
                }
            } else {
                let alert = UIAlertController(title:
                    self.player.error?.localizedDescription, message: nil, preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil);
                alert.addAction(ok)
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func setURL(_url:URL) {
        url = _url;
        let asset = AVAsset(url: url!)
        self.anItem = AVPlayerItem(asset: asset)
        for metaData:AVMetadataItem in asset.commonMetadata {
            if metaData.commonKey?.rawValue.caseInsensitiveCompare("artist") == ComparisonResult.orderedSame {
                self.textLabel?.text = (metaData.value as! String)
            } else if metaData.commonKey?.rawValue.caseInsensitiveCompare("title") == ComparisonResult.orderedSame {
                self.detailTextLabel?.text = (metaData.value as! String)
            } else {
                self.textLabel?.text = "Unknown"
                self.detailTextLabel?.text = "Unknown"
            }
        }
        let keys : [String] = ["commonMetadata"]
        asset.loadValuesAsynchronously(forKeys: keys) {
            let artWorks = AVMetadataItem.metadataItems(from: asset.commonMetadata, withKey: AVMetadataKey.commonKeyArtwork, keySpace: AVMetadataKeySpace.common)
            for item : AVMetadataItem in artWorks {
                if item.keySpace == AVMetadataKeySpace.id3 {
                    let data = item.dataValue
//                    self.imageView?.image = UIImage.init(data: (data)!)
                } else if item.keySpace == AVMetadataKeySpace.iTunes {
//                    self.imageView?.image = UIImage.init(data: item.value?.copy(with: nil) as! Data)
                }
            }
        }
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        print("CurrentTime = \(player.currentTime) /n")
    }
}
