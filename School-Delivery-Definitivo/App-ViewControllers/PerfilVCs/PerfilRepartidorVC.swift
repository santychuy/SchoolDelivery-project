//
//  PerfilRepartidorVC.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 17/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import UIKit
import TextFieldEffects
import Firebase
import SVProgressHUD

class PerfilRepartidorVC: UITableViewController {

    
    @IBOutlet weak var textFieldCarrera: IsaoTextField!
    @IBOutlet weak var textFieldSemestre: IsaoTextField!
    @IBOutlet weak var textFieldMatricula: IsaoTextField!
    
    let DataRef = DBProvider()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
         navigationItem.largeTitleDisplayMode = .never
        
        
        DataRef.userIDRef.child("repartidorInfo").observeSingleEvent(of: .value) { (snapshot) in
            
            if let dic = snapshot.value as? [String:Any] {
                
                self.textFieldCarrera.text = dic["carrera"] as? String
                self.textFieldSemestre.text = dic["matricula"] as? String
                self.textFieldMatricula.text = dic["semestre"] as? String
                
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
        
        
        if (textFieldCarrera.text != nil) && (textFieldMatricula.text != nil) && (textFieldSemestre.text != nil)  {
            
            
            let infoCorregir: Dictionary<String, Any> = ["carrera":self.textFieldCarrera.text!,
                                                         "matricula":self.textFieldMatricula.text!,
                                                         "semestre":self.textFieldSemestre.text!]
            
            self.DataRef.userIDRef.child("repartidorInfo").setValue(infoCorregir)
            
            SVProgressHUD.showSuccess(withStatus: "Se corrigió tu información correctamente!")
            
            self.performSegue(withIdentifier: "unwindSeguePerfilRepartidor-PerfilVC", sender: self)
        }
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}






