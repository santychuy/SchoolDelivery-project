//
//  VerificarCiudadDisponibleVC.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 04/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import UIKit
import MessageUI
import TextFieldEffects
import Firebase
import SVProgressHUD

class VerificarCiudadDisponibleVC: UIViewController, MFMailComposeViewControllerDelegate {

    
    @IBOutlet weak var textFieldUniversidad: IsaoTextField!
    
    var universidades = [String]()
    
    var uniSeleccionada:String!
    
    var dbProv = DBProvider()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        createUniPicker()
        createToolBar()
        
        
        //Aquí lo que hace esto es diferente a las anteriores bloques de codigo, lo que hará aqui es que observará en el "child" de universidad, por si se agrega un nuevo elemento, y se agregue al Array y se muestre para seleccionar en un futuro. De mi depende ir agregando las universidades disponibles en la base de datos.
        
        Database.database().reference().child("ciudad").child("hermosillo").child("universidad").observe(.childAdded) { (snapshot) in
            
            
            let uniAgregar = snapshot.value as? String
            
            if let uniActual = uniAgregar {
                
                self.universidades.append(uniActual)
                
            }
            
        }
        
        
        
        //-------------------------------------------------------------------------------------------------------------------
        
        
        
        
        
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? RegistroUsuarioVC {
            destination.universidadUsuario = textFieldUniversidad.text!
        }
        
    }
    

    
    
    
    
    //MARK: - Requisitos para el Picker View
    
    
    func createUniPicker(){
        
        let uniPicker = UIPickerView()
        uniPicker.delegate = self
        
        textFieldUniversidad.inputView = uniPicker
        
        uniPicker.backgroundColor = .black
        
    }
    
    func createToolBar(){
        
        let toolBar = UIToolbar()
        
        toolBar.sizeToFit()
        
        toolBar.barTintColor = UIColor.gray
        toolBar.tintColor = .white
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(VerificarCiudadDisponibleVC.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textFieldUniversidad.inputAccessoryView = toolBar
        
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    //--------------------------------------------------------------------------------------------------
    
    
    
    
    //MARK: - Requesitos para enviar correo electrónico al correo de Techson
    
    @IBAction func btnEnviarCorreoUni(_ sender: Any)
    {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["techson17@gmail.com"])
        mail.setSubject("Llegar a la universidad de : ")
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mail, animated: true, completion: nil)
        }
        else{
            print("Algo salió mal :(")
        }
        
        
    }
    
    //Por si se rechaza enviar el correo, se devuelve a la vista anterior
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //-------------------------------------------------------------------------------------------------
    
    
    
    @IBAction func btnLogOut(_ sender: Any)
    {
        SVProgressHUD.show(withStatus: "Saliendo...")
        
        do{
            try Auth.auth().signOut()
        }catch let logoutError{
            SVProgressHUD.showError(withStatus: logoutError as? String)
        }
        
        SVProgressHUD.dismiss()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let BienvenidaVC = storyBoard.instantiateViewController(withIdentifier: "BienvenidaVC")
        self.present(BienvenidaVC, animated: true, completion: nil)
    }
    
    
    @IBAction func btnContinuarConUni(_ sender: Any)
    {
        
        //Esto es una mala practica para verificar si en verdad estas en esa universidad, asi que luego tendremos que cambiarlo, por mientras dejarlo así para continuar trabajando, esto tiene que ser verificado con la localización, si coincide y es correcta.
        
        /*if universidades[0] == textFieldUniversidad.text {
            
            performSegue(withIdentifier: "segueVerificarCiudad-RegistroUsuario", sender: nil)
            
        }*/
        
        for uni in universidades {
            
            if uni == textFieldUniversidad.text {
                performSegue(withIdentifier: "segueVerificarCiudad-RegistroUsuario", sender: nil)
            }
            
        }
        
    }
    
    
    
    

}


extension VerificarCiudadDisponibleVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return universidades.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return universidades[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        uniSeleccionada = universidades[row]
        
        textFieldUniversidad.text = uniSeleccionada
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label:UILabel
        
        if let view = view as? UILabel {
            label = view
        }
        else{
            label = UILabel()
        }
        
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Futura", size: 18)
        
        label.text = universidades[row]
        
        return label
    }
    
    
}



