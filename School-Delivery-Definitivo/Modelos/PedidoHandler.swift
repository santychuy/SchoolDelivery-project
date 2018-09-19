//
//  PedidoHandler.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 15/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import Foundation
import FirebaseDatabase

class PedidoHandler {
    
    private static let _instance = PedidoHandler()
    
    var repartidor = ""
    var alumno = ""
    var entregador_id = ""
    
    
    static var Instance:PedidoHandler {
        return _instance
    }
    
    func requestEntrega(latitude: Double, longitude: Double) {
        
        let data: Dictionary<String, Any> = [Constants.nombres: repartidor, Constants.latitude: latitude, Constants.longitude: longitude]
        
        DBProvider.Instance.solicitudPedidoRef.childByAutoId().setValue(data)
        
    }
    
}
