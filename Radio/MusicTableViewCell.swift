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
    private let player = AVQueuePlayer.sharedPlayer;
    private var anItem : AVPlayerItem? = nil;
    private var url:String? = "";
    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var playButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("CountryCode = %@",LocationManagerHandler.sharedManager().countryCode);
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func play(_ sender: Any) {
        if (self.player.currentItem != self.anItem) {
            self.player.stop();
            self.player.replaceCurrentItem(with: self.anItem);
            self.player.play();
        } else {
            if (self.player.status == AVPlayerStatus.readyToPlay) {
                if #available(iOS 10.0, *) {
                    if (self.player.timeControlStatus == AVPlayerTimeControlStatus.waitingToPlayAtSpecifiedRate ||
                        self.player.timeControlStatus == AVPlayerTimeControlStatus.paused) {
                        self.player.play();
                    } else {
                        self.player.pause();
                    }
                } else {
                    // Fallback on earlier versions
                    if (self.player.rate == 0.0) {
                        self.player.play();
                    } else {
                        player.pause();
                    }
                }
            } else {
                let alert = UIAlertController(title:
                    self.player.error?.localizedDescription, message: nil, preferredStyle: UIAlertControllerStyle.alert);
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil);
                alert.addAction(ok);
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil);
            }
        }
    }
    
    func setURL(url:URL) {
        let asset = AVAsset(url: url);
        self.anItem = AVPlayerItem(asset: asset);
        for metaData:AVMetadataItem in asset.commonMetadata {
            if metaData.commonKey?.caseInsensitiveCompare("artist") == ComparisonResult.orderedSame {
                self.labels.last?.text = metaData.commonKey! + " " + (metaData.value as! String);
            } else if metaData.commonKey?.caseInsensitiveCompare("title") == ComparisonResult.orderedSame {
                self.labels.first?.text = metaData.commonKey! + " " + (metaData.value as! String);
            } else {
                self.labels.first?.text = "I smile :)"
            }
        }
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        print("CurrentTime = (player.currentTime) /n");
    }
}
