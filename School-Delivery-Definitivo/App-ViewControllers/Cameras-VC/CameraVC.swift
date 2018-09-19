//
//  CameraVC.swift
//  School-Delivery-Definitivo
//
//  Created by Jesus Santiago Carrasco Campa on 16/01/18.
//  Copyright © 2018 Techson. All rights reserved.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController {

    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var imagen: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setupCaptureSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            }else if device.position == AVCaptureDevice.Position.front{
                frontCamera = device
            }
        }
        
        currentCamera = backCamera
        
        
        
    }
    
    
    
    func setupInputOutput(){
        
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        }catch{
            print(error.localizedDescription)
        }
        
    }
    
    
    
    func setupPreviewLayer(){
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
        
        
    }
    
    func startRunningCaptureSession(){
    
        captureSession.startRunning()
        
    }
    
    
    @IBAction func btnCamera(_ sender: Any)
    {
        let setting = AVCapturePhotoSettings()
        
        photoOutput?.capturePhoto(with: setting, delegate: self )
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueCameraVC-PhotoVC" {
            let photoVC = segue.destination as! PhotoVC
            photoVC.imagen = self.imagen  //Error
        }
        
    }
    
    
    @IBAction func btnCancel(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    
    

}


extension CameraVC: AVCapturePhotoCaptureDelegate {
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let imageData = photo.fileDataRepresentation() {
            
            print(imageData)
            imagen = UIImage(data: imageData)
            
            performSegue(withIdentifier: "segueCameraVC-PhotoVC", sender: self)
            
        }
        
    }
    
    
    
}










