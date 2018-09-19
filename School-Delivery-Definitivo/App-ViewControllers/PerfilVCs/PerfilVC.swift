//
//  PerfilVC.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 12/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class PerfilVC: UITableViewController {

    
    @IBOutlet weak var imageFondo: UIImageView!
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var labelNombre: UILabel!
    
    @IBOutlet weak var switchRepartidor: UISwitch!
    
    
    let DataProvider = DBProvider()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        DataProvider.userIDRef.child("userImg").observeSingleEvent(of: .value) { (snapshot) in
            
            if let dic = snapshot.value as? [String:Any] {
                
                let userImageURL = dic[Constants.userImg] as! String
                
                let httpsReferenceFotoUsuario = Storage.storage().reference(forURL: userImageURL)
                
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
                        self.imageUser.image = image
                        /*self.imageUser.layer.cornerRadius = self.imageUser.frame.size.width / 2
                        self.imageUser.clipsToBounds = true*/
                    }
                }
                
            }
            
        }
    
        
        
        DataProvider.userIDRef.child("repartidorActivo").observeSingleEvent(of: .value) { (snapshot) in
            
            if let dic = snapshot.value as? [String:Any] {
                
                let estadoRepartidorActivo = dic["repartidorActivo"] as! Bool
                
                self.switchRepartidor.setOn(estadoRepartidorActivo, animated: true)
                
            }
            
        }
        
        
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        DataProvider.userIDRef.child("datosUserModificables").observeSingleEvent(of: .value) { (snapshot) in
            
            if let dic = snapshot.value as? [String:Any] {
                
                let nombres = dic[Constants.nombres] as! String
                let apellidos = dic[Constants.apellidos] as! String
                
                self.labelNombre.text = "\(nombres) \(apellidos)"
                
            }
            
        }
        
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func switchRepartidor(_ sender: UISwitch)
    {
        if switchRepartidor.isOn == true
        {
            
            let dic: Dictionary<String, Any> = ["repartidorActivo":true]
            
            self.DataProvider.userIDRef.child("repartidorActivo").setValue(dic)
            
        }
        else
        {
            
            let dic: Dictionary<String, Any> = ["repartidorActivo":false]
            
            self.DataProvider.userIDRef.child("repartidorActivo").setValue(dic)
            
        }
    }
    
    
    
    
    @IBAction func btnLogOut(_ sender: Any)
    {
        do{
            try Auth.auth().signOut()
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let BienvenidaVC = storyBoard.instantiateViewController(withIdentifier: "BienvenidaVC")
            self.present(BienvenidaVC, animated: true, completion: nil)
            
        }catch let logoutError{
            SVProgressHUD.showError(withStatus: logoutError as? String)
        }
    }
    
    
    @IBAction func prepareForUnwindSeguePerfilVC (segue:UIStoryboardSegue){
        
    }
    
    
    
    

}
