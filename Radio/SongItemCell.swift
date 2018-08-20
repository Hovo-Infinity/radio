//
//  SongItemCell.swift
//  Radio
//
//  Created by Hovhannes Stepanyan on 8/20/18.
//  Copyright © 2018 Hovhannes Stepanyan. All rights reserved.
//

import UIKit

class SongItemCell: UICollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var playButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(song: SongItem) {
        titleLabel.text = song.name
    }

}
