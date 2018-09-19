//
//  Constants.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 15/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import Foundation
import Firebase

class Constants {
    
    static let userID = Auth.auth().currentUser?.uid
    
    static let nombres = "nombres"
    static let apellidos = "apellidos"
    static let userImg = "userImgURL"
    static let numTelefono = "numTelefono"
    static let fechaNacimiento = "fechaNacimiento"
    static let sexo = "sexo"
    static let correoElectronico = "correoElectronico"
    static let esRepartidor = "esRepartidor"
    static let universidad = "universidad"
    static let solicitudEntrega = "solicitud_Entrega"
    static let entregaAceptada = "entregaAceptada"
    
    static let latitude = "latitude"
    static let longitude = "longitude"
    
}
