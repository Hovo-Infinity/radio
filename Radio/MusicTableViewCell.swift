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
    var playButton: PlayButton!
    
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
        playButton = PlayButton()
        addSubview(playButton)
    }
}
