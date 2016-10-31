//
//  ObraObject.swift
//  SubTitles
//
//  Created by María Camila Angel on 24/10/16.
//  Copyright © 2016 M01. All rights reserved.
//

import Foundation
import SwiftyJSON

class ObraObject {
    
    var id: String!
    var nombre: String!
    var info: String!
    var tipo: String!
    var url: String!
    var fecha: String!
    var calificacion: String!
    var idioma_original: String!
    
    required init(json: JSON) {
        id = json["id"].stringValue
        nombre = json["nombre"].stringValue
        info = json["info"].stringValue
        tipo = json["tipo"].stringValue
        url = json["url"].stringValue
        fecha = json["fecha"].stringValue
        calificacion = json["calificacion"].stringValue
        idioma_original = json["idioma_original"].stringValue
    }
}
