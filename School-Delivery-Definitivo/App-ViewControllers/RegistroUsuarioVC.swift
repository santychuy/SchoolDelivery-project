//
//  RegistroUsuarioVC.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 12/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import UIKit
import TextFieldEffects
import Firebase
import SVProgressHUD

class RegistroUsuarioVC: UIViewController {

    @IBOutlet weak var imageUsuario: UIImageView!
    
    @IBOutlet weak var textFieldNombres: IsaoTextField!
    @IBOutlet weak var textFieldApellidos: IsaoTextField!
    @IBOutlet weak var textFieldNumTelefono: IsaoTextField!
    @IBOutlet weak var textFieldFecha: IsaoTextField!
    @IBOutlet weak var textFieldSexo: IsaoTextField!
    @IBOutlet weak var textFieldCorreo: IsaoTextField!
    
    var selectedImage:UIImage!
    var imagePicker:UIImagePickerController!
    let userID = Auth.auth().currentUser?.uid
    
    let datePicker = UIDatePicker()
    let pickerView = UIPickerView()
    
    let sexo = ["Hombre", "Mujer"]
    var sexoSeleccionado:String!
    
    var universidadUsuario:String!
    
    let DatabaseRef = DBProvider()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        createDatePicker()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        createPickerView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Crear DatePicker para la fecha de nacimiento
    
    func createDatePicker() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        toolBar.barTintColor = UIColor.gray
        toolBar.tintColor = .white
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButton))
        toolBar.setItems([done], animated: false)
        
        textFieldFecha.inputAccessoryView = toolBar
        textFieldFecha.inputView = datePicker
        
        datePicker.datePickerMode = .date
        
        
        
    }
    
    @objc func doneButton(){
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateString = formatter.string(from: datePicker.date)
        
        textFieldFecha.text = "\(dateString)"
        self.view.endEditing(true)
        
    }
    
    //-------------------------------------------------------------------------------------------
    
    
    //Crear Picker View para elegir el sexo
    
    func createPickerView(){
        
        
        textFieldSexo.inputView = pickerView
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        toolBar.barTintColor = UIColor.gray
        toolBar.tintColor = .white
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPickerView))
        toolBar.setItems([done], animated: false)
        
        textFieldSexo.inputAccessoryView = toolBar
        
        
    }
    
    @objc func doneButtonPickerView(){
        
        
        self.view.endEditing(true)
        
        
    }
    
    
    //----------------------------------------------------------------------------------------------
    
    
   
    
    @IBAction func btnFotoPerfil(_ sender: Any)
    {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func btnGuardarInfo(_ sender: Any)
    {
        guardarDatosCompletos()
    }
    
    
    
    
    
    func guardarDatosCompletos(){
        
        
        SVProgressHUD.show(withStatus: "Espere un momento...")
        
        if (textFieldNombres.text != nil) && (textFieldApellidos.text != nil) && (textFieldNumTelefono.text != nil) && (textFieldFecha.text != nil) && (textFieldSexo.text != nil) && (textFieldCorreo.text != nil){
            
            if selectedImage != nil {
                
                if let imageData = UIImageJPEGRepresentation(selectedImage, 0.4){
                    
                    let imgUid = NSUUID().uuidString
                    let metaData = StorageMetadata()
                    
                    Storage.storage().reference().child(imgUid).putData(imageData, metadata: metaData) { (metadata, error) in
                        
                        let downloadURL = metadata?.downloadURL()?.absoluteString
                        
                        /*let userData: Dictionary<String, Any> = ["nombres": self.textFieldNombres.text!, /*"userImg":downloadURL as Any,*/ "apellidos":self.textFieldApellidos.text!, "numTelefono": self.textFieldNumTelefono.text!, "fechaNacimiento":self.textFieldFecha.text!, "sexo":self.textFieldSexo.text!,"correoElectronico":self.textFieldCorreo.text!, /*"esRepartidor":false,*/ "universidad":self.universidadUsuario as Any]*/
                        
                        let userDataModificable: Dictionary<String, Any> = ["nombres": self.textFieldNombres.text!,
                                                                            "apellidos": self.textFieldApellidos.text!,
                                                                            "numTelefono": self.textFieldNumTelefono.text!,
                                                                            "correoElectronico": self.textFieldCorreo.text!] //Luego pasar universidad 
                        
                        let userDataNoModificable: Dictionary<String, Any> = ["fechaNacimiento": self.textFieldFecha.text!,
                                                                              "sexo": self.textFieldSexo.text!]
                        
                        Database.database().reference().child("users").child(self.userID!).child("datosUserModificables").setValue(userDataModificable)
                        Database.database().reference().child("users").child(self.userID!).child("datosUserNoModificables").setValue(userDataNoModificable)
                        
                        
                        self.DatabaseRef.userImage.setValue(downloadURL) //Guardar la url de la foto en un child especifico
                        
                        let userEsRepartidor: Dictionary<String, Any> = ["esRepartidor":false]
                        
                        self.DatabaseRef.userEsRepartidor.setValue(userEsRepartidor)
                        
                        
                        //Mandar el correo de verifiacion de correo
                        SVProgressHUD.dismiss(completion: {
                            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                                
                                if error != nil{
                                    
                                    //self.funciones.createAlert(title: "Hubo un error", message: (error?.localizedDescription)!)
                                    SVProgressHUD.showError(withStatus: "No se pudo enviar el correo de verificación, checar y volver a intentar más tarde")
                                    //self.performSegue(withIdentifier: "SegueRegistroInfoUsuario-App", sender: nil) //Cambiar nombre Segue
                                    print("Hubo un error al enviar el correo de verificacion \(String(describing: error?.localizedDescription))")
                                    
                                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                                    let BienvenidaVC = storyBoard.instantiateViewController(withIdentifier: "AppVC")
                                    self.present(BienvenidaVC, animated: true, completion: nil)
                                    
                                }
                                else{
                                    //self.funciones.createAlert(title: "Se mandó correo de verificación", message: "Se envió un correo de verificacion para verificar tu dirección de correo electrónico")
                                    SVProgressHUD.showSuccess(withStatus: "Se mandó correo de verificación, checarlo y confirmarlo!")
                                    print("Se envió un correo para verificar tu dirección de correo electrónico a \(String(describing: Auth.auth().currentUser?.email))")
                                    //self.performSegue(withIdentifier: "SegueRegistroInfoUsuario-App", sender: nil) //Cambiar nombre Segue
                                    
                                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                                    let BienvenidaVC = storyBoard.instantiateViewController(withIdentifier: "AppVC")
                                    self.present(BienvenidaVC, animated: true, completion: nil)
                                }
                                
                            })
                        })
                        //--------------------------------------------------------------------------------------------
                        
                    }
                    
                }
                
            }else{
                selectedImage = #imageLiteral(resourceName: "User")
                
                if let imageData = UIImageJPEGRepresentation(selectedImage, 0.4){
                    
                    let imgUid = NSUUID().uuidString
                    let metaData = StorageMetadata()
                    
                    Storage.storage().reference().child(imgUid).putData(imageData, metadata: metaData) { (metadata, error) in
                        
                        let downloadURL = metadata?.downloadURL()?.absoluteString
                        
                        let userData: Dictionary<String, Any> = ["nombres": self.textFieldNombres.text!, /*"userImg":downloadURL as Any,*/ "apellidos":self.textFieldApellidos.text!, "numTelefono": self.textFieldNumTelefono.text!, "fechaNacimiento":self.textFieldFecha.text!, "sexo":self.textFieldSexo.text!,"correoElectronico":self.textFieldCorreo.text!, /*"esRepartidor":false,*/ "universidad":self.universidadUsuario as Any]
                        
                        Database.database().reference().child("users").child(self.userID!).setValue(userData)
                        
                        self.DatabaseRef.userImage.setValue(downloadURL) //Guardar la url de la foto en un child especifico
                        
                        let userEsRepartidor: Dictionary<String, Any> = ["esRepartidor":false]
                        
                        self.DatabaseRef.userEsRepartidor.setValue(userEsRepartidor)
                        
                        
                        //Mandar el correo de verifiacion de correo
                        SVProgressHUD.dismiss(completion: {
                            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                                
                                if error != nil{
                                    
                                    //self.funciones.createAlert(title: "Hubo un error", message: (error?.localizedDescription)!)
                                    SVProgressHUD.showError(withStatus: "No se pudo enviar el correo de verificación, checar y volver a intentar más tarde")
                                    self.performSegue(withIdentifier: "SegueRegistroInfoUsuario-App", sender: nil)
                                    print("Hubo un error al enviar el correo de verificacion \(String(describing: error?.localizedDescription))")
                                    //self.performSegue(withIdentifier: "SegueRegistroInfoUsuario-App", sender: nil) //Cambiar nombre Segue
                                    
                                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                                    let BienvenidaVC = storyBoard.instantiateViewController(withIdentifier: "AppVC")
                                    self.present(BienvenidaVC, animated: true, completion: nil)
                                    
                                }
                                else{
                                    //self.funciones.createAlert(title: "Se mandó correo de verificación", message: "Se envió un correo de verificacion para verificar tu dirección de correo electrónico")
                                    SVProgressHUD.showSuccess(withStatus: "Se mandó correo de verificación, checarlo y confirmarlo!")
                                    print("Se envió un correo para verificar tu dirección de correo electrónico a \(String(describing: Auth.auth().currentUser?.email))")
                                   // self.performSegue(withIdentifier: "SegueRegistroInfoUsuario-App", sender: nil) //Cambiar nombre Segue
                                    
                                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                                    let BienvenidaVC = storyBoard.instantiateViewController(withIdentifier: "AppVC")
                                    self.present(BienvenidaVC, animated: true, completion: nil)
                                }
                                
                            })
                        })
                        //--------------------------------------------------------------------------------------------
                        
                    }
                    
                }
            }
            
            
        }else {
            SVProgressHUD.showError(withStatus: "Completar todos los campos requeridos")
            textFieldNombres.text = ""
            textFieldApellidos.text = ""
            textFieldNumTelefono.text = ""
            textFieldSexo.text = ""
            textFieldFecha.text = ""
            textFieldCorreo.text = ""
            
            return
        }
        
        
    }
    
    

}





extension RegistroUsuarioVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            selectedImage = image
            imageUsuario.image = selectedImage
            imageUsuario.layer.cornerRadius = imageUsuario.frame.size.width / 2
            imageUsuario.clipsToBounds = true
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}


extension RegistroUsuarioVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sexo.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sexo[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        sexoSeleccionado = sexo[row]
        
        textFieldSexo.text = sexoSeleccionado
        
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
        
        label.text = sexo[row]
        
        return label
    }
    
}






