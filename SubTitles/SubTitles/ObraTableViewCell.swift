//
//  ObraTableViewCell.swift
//  SubTitles
//
//  Created by María Camila Angel on 24/10/16.
//  Copyright © 2016 M01. All rights reserved.
//

import UIKit

class ObraTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var nombre: UILabel!
    @IBOutlet weak var idioma_original: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
