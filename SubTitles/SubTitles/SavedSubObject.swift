//
//  SavedSubObject.swift
//  SubTitles
//
//  Created by María Camila Angel on 27/10/16.
//  Copyright © 2016 M01. All rights reserved.
//

import Foundation

class SavedSubObject {
    
    var archivoTraduccion: String!
    var archivoOriginal: String!
    var nombre: String!
    var idioma: String!
    
    required init(nombre: String, idioma: String, archivoTraduccion: String, archivoOriginal: String) {
        self.nombre = nombre
        self.idioma = idioma
        self.archivoOriginal = archivoOriginal
        self.archivoTraduccion = archivoTraduccion
    }
}
