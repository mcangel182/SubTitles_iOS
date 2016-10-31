//
//  SubtitlesObject.swift
//  SubTitles
//
//  Created by María Camila Angel on 25/10/16.
//  Copyright © 2016 M01. All rights reserved.
//

import Foundation
import SwiftyJSON

class SubtitlesObject {
    
    var id: String!
    var idioma: String!
    var url: String!
    var obra_id: String!
    
    required init(json: JSON) {
        id = json["id"].stringValue
        idioma = json["idioma"].stringValue
        url = json["url"].stringValue
        obra_id = json["obra"].stringValue
    }
}
