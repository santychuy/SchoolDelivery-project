//
//  RegisEntregadorVC.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 15/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import UIKit
import Firebase
import TextFieldEffects
import SVProgressHUD
import AVFoundation

class RegisEntregadorVC: UIViewController {

    @IBOutlet weak var imageUsuario: UIImageView!
    @IBOutlet weak var imageINE: UIImageView!
    
    @IBOutlet weak var textFieldMatriculaEscuela: IsaoTextField!
    @IBOutlet weak var textFieldSemestre: IsaoTextField!
    @IBOutlet weak var textFieldCarrera: IsaoTextField!
    
    var selectedImage:UIImage!
    var imagePicker:UIImagePickerController!
    
    let userID = Auth.auth().currentUser?.uid
    
    var imageUsuarioUrl:String!
    
    @IBOutlet weak var labelUni: UILabel!
    
    let DatabaseRef = DBProvider()
    
    var video = AVCaptureVideoPreviewLayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        Database.database().reference().child("users").child(userID!).child("userImg").observeSingleEvent(of: .value) { (snapshot) in
            
            if let dic = snapshot.value as? [String:AnyObject] {
                
                self.imageUsuarioUrl = dic[Constants.userImg] as! String
                
                let httpsReferenceFotoUsuario = Storage.storage().reference(forURL: self.imageUsuarioUrl)
                
                httpsReferenceFotoUsuario.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if error != nil {
                        // Uh-oh, an error occurred!
                        print(error?.localizedDescription ?? "")
                        /*self.imagePerfilUsuario.image = #imageLiteral(resourceName: "Usuario")  //Checar aqui
                         self.imagePerfilUsuario.layer.cornerRadius = self.imagePerfilUsuario.frame.size.width / 2
                         self.imagePerfilUsuario.clipsToBounds = true*/
                        
                    } else {
                        // Data for "images/island.jpg" is returned
                        let image = UIImage(data: data!)
                        self.imageUsuario.image = image
                        self.imageUsuario.layer.cornerRadius = self.imageUsuario.frame.size.width / 2
                        self.imageUsuario.clipsToBounds = true
                    }
                }
                
            }
            
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnCambiarFoto(_ sender: Any)
    {
        //present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    @IBAction func btnAgregarINE(_ sender: Any)
    {
        let actionSheet = UIAlertController(title: "Subir fotos", message: "Seleccionar o tomar foto de la parte delantera de tu INE", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camara", style: .default, handler: { (action) in
            
            self.tomarFoto(tomarFoto: true)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Fotos", style: .default, handler: { (action) in
            
            self.fotosINE(fotosINE: true)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
        
        
        
        
        //Aqui tiene que ser diferente porque se agregar dos fotos, ver como hacerlo
    }
    
    
    
    
    func tomarFoto(tomarFoto:Bool) {
        
       performSegue(withIdentifier: "segueRegisRepartidor-CameraVC", sender: nil)
        
    }
    
    
    func fotosINE(fotosINE:Bool){
        
        //Hacer seleccionar una foto adecuada de la INE
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    
    
    @IBAction func btnCompletarRegistro(_ sender: Any)
    {
        SVProgressHUD.show(withStatus: "Mandando información...")
        
        //Aquí tenemos que validar bien de si hay las dos imagenes de la INE y si la foto de perfil del usuario es valida, comprobando si es una persona
        
        if (textFieldMatriculaEscuela.text != nil) && (textFieldSemestre.text != nil) && (textFieldCarrera.text != nil) && (imageUsuario.image != nil) && (imageINE.image != nil)  {
            
            if let imageData = UIImageJPEGRepresentation(imageUsuario.image!, 0.4){
                
                let imgUid = NSUUID().uuidString
                let metaData = StorageMetadata()
                
                Storage.storage().reference().child(imgUid).putData(imageData, metadata: metaData) { (metadata, error) in
                    
                    //Guardar la foto de perfil
                    
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    
                    self.DatabaseRef.userImage.setValue(downloadURL)
                    
                    //--------------------------------------------------------
                    
                    //Guardar datos de repartidor
                    
                    let userDataRepartidor = ["matricula":self.textFieldMatriculaEscuela.text, "semestre":self.textFieldSemestre.text, "carrera":self.textFieldCarrera.text]
                    
                    self.DatabaseRef.userRepartidorInfo.setValue(userDataRepartidor)
                    
                    //------------------------------------------------------------------------------------------
                    
                    //Guardar el estado que sí es repartidor
                    
                    let userEsRepartidor: Dictionary<String, Any> = ["esRepartidor":true]
                   
                    self.DatabaseRef.userEsRepartidor.setValue(userEsRepartidor)
                    
                    //------------------------------------------------------------------------
                    
                    //Guardar el estado si estará activo el repartidor
                    
                    let userRepartidorActivo: Dictionary<String, Any> = ["repartidorActivo":false]
                    
                    self.DatabaseRef.userIDRef.child("repartidorActivo").setValue(userRepartidorActivo)
                    
                    //------------------------------------------------------------------------------------------
                    
                    //Guardar el estado si estará entregando el repartidor
                    
                    let repartidorEstaEntregando: Dictionary<String,Any> = ["repartidorEstaEntregando":false]
                    
                    self.DatabaseRef.userIDRef.child("repartidorEstaEntregando").setValue(repartidorEstaEntregando)
                    
                    //------------------------------------------------------------------------------------------
                    
                    
                }
                
            }
            
            
            //
            if let imageData = UIImageJPEGRepresentation(imageINE.image!, 0.4) {
                
                let imgUid = NSUUID().uuidString
                let metaData = StorageMetadata()
                
                Storage.storage().reference().child(imgUid).putData(imageData, metadata: metaData, completion: { (metadata, error) in
                    
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    
                    let imageIneURL = ["imageINE":downloadURL]
                    
                    self.DatabaseRef.userIDRef.child("imageINE").setValue(imageIneURL)
                    
                })
                
            }
            
            SVProgressHUD.dismiss(completion: {
                //Hacer unwindSegue para Mapas
                
                self.performSegue(withIdentifier: "unwindSegueRegisEntregador-MapaVC", sender: self)
                
                SVProgressHUD.showInfo(withStatus: "Revisaremos tu información, y te haremos saber por email tu solicitud de repartidor!")
                
            })
            
        }
        else{
            SVProgressHUD.showError(withStatus: "Faltaron de llenar campos necesarios, llenarlos todos!")
            self.textFieldMatriculaEscuela.text = ""
            self.textFieldCarrera.text = ""
            self.textFieldSemestre.text = ""
        }
        
        
    }
    
    
    
    
    
    @IBAction func unwindSegueRegisEntregador(_ sender: UIStoryboardSegue){
        
    }
    
    
    
}



extension RegisEntregadorVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            selectedImage = image
            imageINE.image = selectedImage
            imageINE.layer.cornerRadius = imageINE.frame.size.width / 2
            imageINE.clipsToBounds = true
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}
















