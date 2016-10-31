//
//  SavedSubTableViewCell.swift
//  SubTitles
//
//  Created by María Camila Angel on 27/10/16.
//  Copyright © 2016 M01. All rights reserved.
//

import UIKit

class SavedSubTableViewCell: UITableViewCell {

    @IBOutlet weak var obra: UILabel!
    @IBOutlet weak var idioma: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
