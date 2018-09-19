//
//  DBProvider.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 16/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class DBProvider {
    
    private static let _instance = DBProvider()
    
    static var Instance: DBProvider {
        return _instance
    }
    
    
    var dbRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var usersRef: DatabaseReference {
        return Database.database().reference().child("users")
    }
    
    var userIDRef: DatabaseReference {
        return usersRef.child(Constants.userID!)
    }
    
    var userImage: DatabaseReference {
        return userIDRef.child("userImg").child(Constants.userImg)
    }
    
    var ciudadRef: DatabaseReference {
        return dbRef.child("ciudad")
    }
    
    var unisRef: DatabaseReference {
        return ciudadRef.child("hermosillo").child("universidad")
    }
    
    var solicitudPedidoRef: DatabaseReference {
        return dbRef.child(Constants.solicitudEntrega)
    }
    
    var userRepartidorInfo: DatabaseReference {
        return userIDRef.child("repartidorInfo")
    }
    
    var userEsRepartidor: DatabaseReference {
        return userIDRef.child(Constants.esRepartidor)
    }
    
    var pedidoAceptado: DatabaseReference {
        return dbRef.child("schoolDelivery_pedidosActivos")
    }
    
    
    
    
    func saveUser(nombres: String, apellidos: String, userImgURL: String, numTelefono: String, fechaNacimiento: String, sexo: String, email: String, universidad: String){
        
        let data: Dictionary<String, Any> = [Constants.nombres: nombres, Constants.apellidos: apellidos, Constants.userImg: userImgURL, Constants.numTelefono: numTelefono, Constants.fechaNacimiento: fechaNacimiento, Constants.sexo: sexo, Constants.correoElectronico: email, Constants.universidad: universidad, Constants.esRepartidor: false]
        
        
        userIDRef.setValue(data)
        
        
    }
    
    
    
    func verificarUni( unis:[String]){
        
        var unis = unis
        unisRef.observe(.childAdded) { (snapshot) in
            
            let uniAgregar = snapshot.value as? String
            
            if let uniActual = uniAgregar {
                
                unis.append(uniActual)
                
            }
            
            
        }
        
    }
    
    
    
    
}








