//
//  RestablecerContraVC.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 04/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import UIKit
import TextFieldEffects
import Firebase
import SVProgressHUD

class RestablecerContraVC: UIViewController {

    
    @IBOutlet weak var textFieldCorreo: IsaoTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnRecuperarContra(_ sender: Any)
    {
        SVProgressHUD.show(withStatus: "Mandando correo...")
        
        if textFieldCorreo.text == "" {
            Auth.auth().sendPasswordReset(withEmail: textFieldCorreo.text!, completion: { (error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: "No se pudo enviar el correo, \(String(describing: error?.localizedDescription))")
                    self.textFieldCorreo.text = ""
                }
                else {
                    SVProgressHUD.showInfo(withStatus: "Se envió correo de restablecimiento de contraseña al correo \(self.textFieldCorreo.text!) ")
                    self.performSegue(withIdentifier: "unwindSegueRestablecerContra-Bienvenida", sender: self)
                }
            })
        }
        else{
            SVProgressHUD.showError(withStatus: "Escribe algo...")
            
        }
    }
    
    
    

}
