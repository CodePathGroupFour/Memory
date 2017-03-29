//
//  CameraViewController.swift
//  SnapMap
//
//  Created by Lum Situ on 3/26/17.
//  Copyright © 2017 Jason Wong. All rights reserved.
//

import UIKit
import AVFoundation
import FBSDKCoreKit
import FirebaseAuth
import FirebaseStorage
import Firebase

class CameraViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureImageView: UIImageView!
    
    var captureImage: UIImage?
    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    let user = FIRAuth.auth()?.currentUser
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        session = AVCaptureSession()
        session!.sessionPreset =  AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        var error: Error?
        var input: AVCaptureInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as Error {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
        }
        
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        if session!.canAddOutput(stillImageOutput) {
            session!.addOutput(stillImageOutput)
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer!.videoGravity = AVLayerVideoGravityResize
        videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        previewView.layer.addSublayer(videoPreviewLayer!)
        session!.startRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        videoPreviewLayer!.frame =  previewView.bounds
    }
    
    @IBAction func takePhotoButton(_ sender: UIButton) {
        if let videoConnetion = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnetion, completionHandler: { (sampleBuffer: CMSampleBuffer?, error: Error?) in
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProvider(data: imageData as! CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                    let captureImage = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    
                    self.captureImageView.image = captureImage
                    
                    let imageName = NSUUID().uuidString
                    
                    
                    guard let uid = self.user?.uid else {
                        return
                    }
                    
                    // Create a reference to the file you want to upload
                    var storageRef = FIRStorage.storage().reference().child("\(imageName).png")
                    
                    if let uploadData = UIImagePNGRepresentation(captureImage) {
                        //let uid = self.user?.uid
                            storageRef.put(uploadData, metadata: nil) { metadata, error in
                            if let error = error {
                                // Uh-oh, an error occurred!
                                print(error.localizedDescription)
                                print("?????????")
                            } else {
                                // Metadata contains file metadata such as size, content-type, and download URL.
                                print("upload seccessfully!")
                                let postImageURL = metadata!.downloadURL()
                                if let postImageURL = metadata!.downloadURL()?.absoluteString {
                                    let value = ["postImageURL": postImageURL]
                                    
                                   self.registerUserIntoDataBaseWithUID(uid: uid, values: value as [String : AnyObject])
                                }
                            }
                        }
                    }
                    
                    
                
                }
            })
        }
        
    }
    
    private func registerUserIntoDataBaseWithUID(uid:String, values:[String:AnyObject]) {
        let ref = FIRDatabase.database().reference(fromURL: "https://snapmap-e45c3.firebaseio.com/")
        let userRef = ref.child("user").child(uid)
        userRef.updateChildValues(values,withCompletionBlock: {
            (err,ref) in
            if err != nil {
                print(err?.localizedDescription)
                return
            }
            
//            self.dismiss(animated: true, completion: nil)
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
