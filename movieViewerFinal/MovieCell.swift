//
//  MovieCell.swift
//  movieViewerFinal
//
//  Created by macbookair11 on 2/4/16.
//  Copyright © 2016 Broulaye. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var posterView: UIImageView!
    
    @IBOutlet weak var overviewLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
