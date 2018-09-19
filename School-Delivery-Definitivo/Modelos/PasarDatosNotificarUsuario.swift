//
//  PasarDatosNotificarUsuario.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 20/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import Foundation

class PasarDatosNotificarUsuario {
    
    private static let _instance = PasarDatosNotificarUsuario()
    
    static var Instance: PasarDatosNotificarUsuario {
        return _instance
    }
    
    var nombreDelRepartidorEncargado = ""
    var keyReparto = ""
    
    
}
