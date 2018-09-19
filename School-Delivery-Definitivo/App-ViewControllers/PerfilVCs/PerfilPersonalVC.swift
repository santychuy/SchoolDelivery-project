//
//  PerfilPersonalVC.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 17/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import UIKit
import TextFieldEffects
import Firebase
import SVProgressHUD

class PerfilPersonalVC: UITableViewController {

    
    @IBOutlet weak var textFieldNombres: IsaoTextField!
    @IBOutlet weak var textFieldApellidos: IsaoTextField!
    @IBOutlet weak var textFieldTelefono: IsaoTextField!
    @IBOutlet weak var textFieldCorreoE: IsaoTextField!
    
    let DataRef = DBProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        navigationItem.largeTitleDisplayMode = .never
        
        DataRef.userIDRef.child("datosUserModificables").observeSingleEvent(of: .value) { (snapshot) in
            
            if let dic = snapshot.value as? [String:Any] {
                
                self.textFieldNombres.text = dic["nombres"] as? String
                self.textFieldApellidos.text = dic["apellidos"] as? String
                self.textFieldTelefono.text = dic["numTelefono"] as? String
                self.textFieldCorreoE.text = dic["correoElectronico"] as? String
                
            }
            
        }
        
        //Agregar botón de guardar datos
        
        let btnCorregir = UIButton(type: .custom)
        btnCorregir.setImage(#imageLiteral(resourceName: "Corregir"), for: .normal)
        btnCorregir.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        btnCorregir.addTarget(self, action: #selector(btnGuardarInfo), for: .touchUpInside)
        
        let itemCorregir = UIBarButtonItem(customView: btnCorregir)
        
        self.navigationItem.setRightBarButton(itemCorregir, animated: true)
        
        
    }
    
    
    //Funcion del botón de guardar la info.
    @objc func btnGuardarInfo(){
        
        
        if (textFieldNombres.text != nil) && (textFieldApellidos.text != nil) && (textFieldTelefono.text != nil) && (textFieldCorreoE.text != nil) {
            
            
            let infoCorregir: Dictionary<String, Any> = ["nombres":self.textFieldNombres.text!,
                                                         "apellidos":self.textFieldApellidos.text!,
                                                         "correoElectronico":self.textFieldCorreoE.text!,
                                                         "numTelefono":self.textFieldTelefono.text!]
            
            self.DataRef.userIDRef.child("datosUserModificables").setValue(infoCorregir)
            
            SVProgressHUD.showSuccess(withStatus: "Se corrigió tu información correctamente!")
            
            self.performSegue(withIdentifier: "unwindSeguePerfilPersonal-PerfilVC", sender: self)
        }
        
    }

    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
