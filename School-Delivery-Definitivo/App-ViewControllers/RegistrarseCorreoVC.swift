//
//  RegistrarseCorreoVC.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 04/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import UIKit
import TextFieldEffects
import Firebase
import SVProgressHUD

class RegistrarseCorreoVC: UIViewController {

    @IBOutlet weak var textFieldCorreo: IsaoTextField!
    @IBOutlet weak var textFieldContraseña1: IsaoTextField!
    @IBOutlet weak var textFieldContraseña2: IsaoTextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: - Requerimientos para crear un usuario con CORREO ELECTRÓNICO
    
    @IBAction func btnRegistrarseCorreo(_ sender: Any)
    {
        SVProgressHUD.show(withStatus: "Creando Usuario...")
        
        if textFieldCorreo.text != "" && textFieldContraseña1.text != "" && textFieldContraseña2.text != ""
        {
            if textFieldContraseña1.text == textFieldContraseña2.text
            {
                
                Auth.auth().createUser(withEmail: textFieldCorreo.text!, password: textFieldContraseña1.text!, completion: { (user, error) in
                    
                    if error != nil
                    {
                        SVProgressHUD.showError(withStatus: "No se pudo crear el usuario, \(String(describing: error?.localizedDescription))")
                        print(error ?? "")
                        return
                    }
                    
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "segueRegistrarseCorreo-VerificarCiudad", sender: self) 
                    print("Se creó al usuario por correo correctamente ",user!)
                    
                })
            }
            else
            {
                SVProgressHUD.showError(withStatus: "Escribir bien las dos contraseñas")
                textFieldCorreo.text = ""
                textFieldContraseña1.text = ""
                textFieldContraseña2.text = ""
            }
        }
        else
        {
            SVProgressHUD.showError(withStatus: "Te faltó completar información, completar todos los campos requeridos correctamente")
            textFieldCorreo.text = ""
            textFieldContraseña1.text = ""
            textFieldContraseña2.text = ""
        }

    }
    
    //------------------------------------------------------------------------------------------------------------------------------------
    
    
    

}
