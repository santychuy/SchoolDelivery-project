//
//  ViewController.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 03/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class ViewController: UIViewController {

    
    @IBOutlet weak var imageLogo: UIImageView!
    
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageLogo.alpha = 0
        
        //Se configura el video que estará en el fondo de la pantalla de bienvenida
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: [.mixWithOthers])
            try audioSession.setActive(true)
        }catch{
            print(error.localizedDescription)
        }
        
        let videoURL = Bundle.main.url(forResource: "VideoIntro", withExtension: "mp4")
        
        player = AVPlayer.init(url: videoURL!)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.frame = view.layer.frame
        
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        
        player.play()
        
        view.layer.insertSublayer(playerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemReachEnd(notitication:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        //-------------------------------------------------------------------------------------------
        
        UIView.animate(withDuration: 1) {
            self.imageLogo.alpha = 1
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if Auth.auth().currentUser != nil {
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let BienvenidaVC = storyBoard.instantiateViewController(withIdentifier: "AppVC")
            self.present(BienvenidaVC, animated: true, completion: nil)

            
        }
        
    }
    
    
    
    
    //MARK: - Función para cuando lleve a 0 el video se ejecute la acción de volver a repetir en la parte de arriba
    @objc func playerItemReachEnd(notitication:NSNotification){
        
        player.seek(to: kCMTimeZero)
        
    }
    
    
    //MARK: - Ocultar la barra de estado
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    @IBAction func prepareForUnwindSegueBienvenidaVC (segue:UIStoryboardSegue){
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

