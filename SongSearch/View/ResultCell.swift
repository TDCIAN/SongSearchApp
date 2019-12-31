//
//  ResultCell.swift
//  SongSearch
//
//  Created by joonwon lee on 02/04/2019.
//  Copyright © 2019 joonwon.lee. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(track: Track) {
        title.text = track.title
        artistName.text = track.artistName
    }
}
