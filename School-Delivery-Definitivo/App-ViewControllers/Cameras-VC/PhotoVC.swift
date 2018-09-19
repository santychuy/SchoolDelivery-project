//
//  PhotoVC.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 16/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import UIKit

class PhotoVC: UIViewController {

    
    @IBOutlet weak var imagePreview: UIImageView!
    
    var imagen: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        imagePreview.image = self.imagen
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnDone(_ sender: Any)
    {
        //UIImageWriteToSavedPhotosAlbum(imagen, nil, nil, nil) es para guardar fotos en tu biblioteca
        
        //Hacer que se pase esa foto para guardarla
        
        performSegue(withIdentifier: "unwindSeguePhotoVC-RegisEntregadorVC", sender: self)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? RegisEntregadorVC {
            destination.imageINE.image = imagePreview.image
        }
        
    }
    
    
    @IBAction func btnCancel(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    

}
