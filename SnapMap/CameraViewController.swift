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
import MapKit

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationsViewControllerDelegate, MKMapViewDelegate  {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    var captureImage: UIImage?
    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    

    var pickedImage:UIImage!

    let user = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // One degree of latitude is approximately 111 kilometers (69 miles) at all times.
        // San Francisco Lat, Long = latitude: 37.783333, longitude: -122.416667
        let mapCenter = CLLocationCoordinate2D(latitude: 37.783333, longitude: -122.416667)
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: mapCenter, span: mapSpan)
        // Set animated property to true to animate the transition to the region
        mapView.setRegion(region, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        
//        session = AVCaptureSession()
//        session!.sessionPreset =  AVCaptureSessionPresetPhoto
//        
//        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
//        
//        var error: Error?
//        var input: AVCaptureInput!
//        do {
//            input = try AVCaptureDeviceInput(device: backCamera)
//        } catch let error1 as Error {
//            error = error1
//            input = nil
//            print(error!.localizedDescription)
//        }
//        
//        if error == nil && session!.canAddInput(input) {
//            session!.addInput(input)
//        }
//        
//        stillImageOutput = AVCaptureStillImageOutput()
//        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
//        
//        if session!.canAddOutput(stillImageOutput) {
//            session!.addOutput(stillImageOutput)
//        }
//        
//        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
//        videoPreviewLayer!.videoGravity = AVLayerVideoGravityResize
//        videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//        previewView.layer.addSublayer(videoPreviewLayer!)
//        session!.startRunning()
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//        videoPreviewLayer!.frame =  previewView.bounds
//    }
//    
//    @IBAction func takePhotoButton(_ sender: UIButton) {
//        if let videoConnetion = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
//            stillImageOutput?.captureStillImageAsynchronously(from: videoConnetion, completionHandler: { (sampleBuffer: CMSampleBuffer?, error: Error?) in
//                
//                if sampleBuffer != nil {
//                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
//                    let dataProvider = CGDataProvider(data: imageData as! CFData)
//                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
//                    let captureImage = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
//                    
//                    self.captureImageView.image = captureImage
//                    
//                    let imageName = NSUUID().uuidString
//                    
//                    
//                    guard let uid = self.user?.uid else {
//                        return
//                    }
//                    
//                    // Create a reference to the file you want to upload
//                    var storageRef = FIRStorage.storage().reference().child("\(imageName).png")
//                    
//                    if let uploadData = UIImagePNGRepresentation(captureImage) {
//                        //let uid = self.user?.uid
//                            storageRef.put(uploadData, metadata: nil) { metadata, error in
//                            if let error = error {
//                                // Uh-oh, an error occurred!
//                                print(error.localizedDescription)
//                                print("?????????")
//                            } else {
//                                // Metadata contains file metadata such as size, content-type, and download URL.
//                                print("upload seccessfully!")
//                                let postImageURL = metadata!.downloadURL()
//                                if let postImageURL = metadata!.downloadURL()?.absoluteString {
//                                    let value = ["postImageURL": postImageURL]
//                                    
//                                   self.registerUserIntoDataBaseWithUID(uid: uid, values: value as [String : AnyObject])
//                                }
//                            }
//                        }
//                    }
//                    
//                    
//                
//                }
//            })
//        }
//        
//
//    }//func takePhotoButton
//    
//    private func registerUserIntoDataBaseWithUID(uid:String, values:[String:AnyObject]) {
//        let ref = FIRDatabase.database().reference(fromURL: "https://snapmap-e45c3.firebaseio.com/")
//        let userRef = ref.child("user").child(uid)
//        userRef.updateChildValues(values,withCompletionBlock: {
//            (err,ref) in
//            if err != nil {
//                print(err?.localizedDescription)
//                return
//            }
//            
////            self.dismiss(animated: true, completion: nil)
//        })
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        // vc.sourceType = UIImagePickerControllerSourceType.camera
        self.present(vc, animated: true, completion: nil)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            vc.sourceType = .camera
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            vc.sourceType = .photoLibrary
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        pickedImage = originalImage
        
        // Do something with the images (based on your use case)
        
        print(" --- imagePickerController --- dismiss & segue")
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "tagSegue", sender: self)
        let imageName = NSUUID().uuidString
        
        
                            guard let uid = self.user?.uid else {
                                return
                            }
        
                            // Create a reference to the file you want to upload
                            let storageRef = FIRStorage.storage().reference().child("\(imageName).png")
        
                            if let uploadData = UIImagePNGRepresentation(pickedImage) {
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

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let locationsViewController = segue.destination as! LocationsViewController
        locationsViewController.delegate = self
    }
    
    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
        
        let annotation = MKPointAnnotation()
        let locationCoordinate = CLLocationCoordinate2D(latitude: latitude as CLLocationDegrees, longitude: longitude as CLLocationDegrees)
        annotation.coordinate = locationCoordinate
        annotation.title = String(describing: latitude)
        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if (annotationView == nil) {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
        }
        
        let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
        // Add the image you stored from the image picker
        imageView.image = pickedImage
        
        return annotationView
    }

}
