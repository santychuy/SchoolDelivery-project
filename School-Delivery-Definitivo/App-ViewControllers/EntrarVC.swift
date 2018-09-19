//
//  EntrarVC.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 04/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import UIKit
import TextFieldEffects
import Firebase
import FBSDKLoginKit
import SVProgressHUD

class EntrarVC: UIViewController {

    @IBOutlet weak var btnAtras: UIBarButtonItem!
    @IBOutlet weak var textFieldCorreo: IsaoTextField!
    @IBOutlet weak var textFieldContra: IsaoTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        UIApplication.shared.statusBarStyle = .lightContent
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    //MARK: - Requerimientos para inicio de sesión por FACEBOOK
    
    @IBAction func btnFacebookEntrar(_ sender: Any)
    {
        //OJO, ES PARA INICIAR SESION, QUEREMOS PARA CREAR UN USUARIO
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            if error != nil
            {
                print("No se inició sesíon con FB: ", error ?? "")
                self.createAlert(title: "No se inició sesión con Facebook", message: (error?.localizedDescription)!)
            }
            
            self.showEmailAddress()
        }
    }
    
    
    func showEmailAddress()
    {
        let accessToken = FBSDKAccessToken.current()
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: (accessToken?.tokenString)!)
        
        Auth.auth().signIn(with: credentials) { (user, error) in
            if error != nil
            {
                //Poner alerta
                self.createAlert(title: "No se pudo iniciar sesión", message: "Algo salió mal al iniciar sesión")
                print("Algo salió mal con el usuario de FB: ", error ?? "")
                return
            }
            //Poner Segue para ir a la app
            self.performSegue(withIdentifier: "segueEntrar-App", sender: self)  
            
            print("Se inició sesión correctamente: ", user ?? "")
        }
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
            if error != nil
            {
                print("Falló al pedir la info: ",error ?? "")
            }
            
            print(result ?? "")
        }
    }
    
    //-----------------------------------------------------------------------------------------------------
    
    
    
    
    //MARK: - Requerimientos para iniciar sesión con CORREO ELECTRÓNICO
    
    @IBAction func btnEntrarCorreo(_ sender: Any)
    {
        SVProgressHUD.show(withStatus: "Iniciando sesión...")
        
        if textFieldCorreo.text != "" && textFieldContra.text != ""
        {
            Auth.auth().signIn(withEmail: textFieldCorreo.text!, password: textFieldContra.text!, completion: { (user, error) in
                if user != nil
                {
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "segueEntrar-App", sender: self)
                }
                else
                {
                    if let myError = error?.localizedDescription
                    {
                        print(myError)
                        self.textFieldCorreo.text = ""
                        self.textFieldContra.text = ""
                        SVProgressHUD.showError(withStatus: "Poner correo correctamente, \(myError)")
                    }
                    else
                    {
                        SVProgressHUD.showError(withStatus: "Error")
                    }
                }
            })
        }
        else{
            textFieldCorreo.text = ""
            textFieldContra.text = ""
            SVProgressHUD.showError(withStatus: "Llenar información en ambos campos correctamente")
        }
    }
    
    
    //------------------------------------------------------------------------------------------------------
    
    
    
    @IBAction func btnAtras(_ sender: Any)
    {
        performSegue(withIdentifier: "unwindSegueEntrar-Bienvenida", sender: self)
    }
    
    @IBAction func prepareForUnwindSegueEntrarVC (segue:UIStoryboardSegue){
        
    }
    
    
    func createAlert(title:String, message:String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    

}
