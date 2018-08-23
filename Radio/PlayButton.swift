//
//  PlayButton.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 8/23/18.
//  Copyright © 2018 Hovhannes Stepanyan. All rights reserved.
//

import UIKit

class PlayButton: UIButton {

    var isPlaying: Bool {
        get {
            return image(for: .normal) == #imageLiteral(resourceName: "pause_circle")
        }
        set {
            if newValue {
                setImage(#imageLiteral(resourceName: "pause_circle"), for: .normal)
            } else {
                setImage(#imageLiteral(resourceName: "play_circle"), for: .normal)
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        isPlaying = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isPlaying = false
    }
    
}
