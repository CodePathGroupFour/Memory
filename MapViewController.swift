//
//  MapViewController.swift
//  SnapMap
//
//  Created by Lum Situ on 4/17/17.
//  Copyright © 2017 Jason Wong. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseDatabase
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var snapUsers = [User]()
    var snapPosts = [Post]()
    
    var image: UIImage!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveUsers()
        retrievePosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        self.mapView.delegate = self
        print("Have map view delegate")
        //        locationManager.delegate = self as CLLocationManagerDelegate
        //        DispatchQueue.main.async(execute: {
        //            self.locationManager.startUpdatingLocation()
        //        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.mapView.delegate = self
        for post in snapPosts {
            let imageRef = FIRStorage.storage().reference().child("\(post.postId!).png")
            imageRef.downloadURL { (Url: URL?, error: Error?) in
                if let error = error {
                    print("Getting imageUrl error:\(error.localizedDescription)")
                } else {
                    if let imageUrl = Url{
                        //                        print("2")
                        let data = NSData(contentsOf: imageUrl)! as Data
                        self.image = UIImage(data: data)
                        
                    }
                }
                
            }
            locationsPickedLocation(latitude: post.latitude, longitude: post.longitude)
        }
    }
    
    public func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        self.mapView.delegate = self
        for post in snapPosts {
            let imageRef = FIRStorage.storage().reference().child("\(post.postId!).png")
            imageRef.downloadURL { (Url: URL?, error: Error?) in
                if let error = error {
                    print("Getting imageUrl error:\(error.localizedDescription)")
                } else {
                    if let imageUrl = Url{
                        //                        print(imageUrl)
                        let data = NSData(contentsOf: imageUrl)! as Data
                        self.image = UIImage(data: data)
                        let annotation = PhotoAnnotation()
                        annotation.photo = UIImage(data: data)
                    }
                }
                
            }
            locationsPickedLocation(latitude: post.latitude, longitude: post.longitude)
            
        }
        
    }
    
    func getPhoto() {
        for post in snapPosts {
            let imageRef = FIRStorage.storage().reference().child("\(post.postId!).png")
            imageRef.downloadURL { (Url: URL?, error: Error?) in
                if let error = error {
                    print("Getting imageUrl error:\(error.localizedDescription)")
                } else {
                    if let imageUrl = Url{
                        //                        print(imageUrl)
                        let data = NSData(contentsOf: imageUrl)! as Data
                        self.image = UIImage(data: data)
                        let annotation = PhotoAnnotation()
                        annotation.photo = UIImage(data: data)
                    }
                }
                
            }
        }
    }
    
    func retrieveUsers()
    {
        FIRDatabase.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            if let userdictionary = snapshot.value as? [String: Any]
            {
                let user = User()
                
                //                print(snapshot.value)
                user.name = userdictionary["name"] as! String
                user.email = userdictionary["email"] as? String
                user.profileURL = userdictionary["profileURL"] as? String
                
                self.snapUsers.append(user)
                //print("user count is : \(self.snapUsers.count)")
            }
        })
    }
    
    func retrievePosts()
    {
        var postDictionary: NSDictionary = [:]
        
        FIRDatabase.database().reference().child("Post").observe(.childAdded, with: { (snapshot) in
            for childSnap in  snapshot.children.allObjects
            {
                let post = Post()
                
                let snap = childSnap as! FIRDataSnapshot
                if let snapshotValue = snapshot.value as? NSDictionary, let snapVal = snapshotValue[snap.key] as? NSDictionary
                {
                    for postInfo in snapVal {
                        postDictionary = (postInfo.value as? NSDictionary)!
                    }
                    
                    //                    print(postDictionary)
                    //                    print(self.snapPosts.count)
                    if let latitude = postDictionary["latitude"] {
                        post.latitude = latitude as! Double
                    }
                    //                    post.latitude = postDictionary["latitude"] as! Double
                    if let longitude = postDictionary["longitude"] {
                        post.longitude = longitude as! Double
                    }
                    //                    post.longitude = postDictionary["longitude"] as! Double
                    if let id = postDictionary["postId"] {
                        post.postId = id as! String
                    }
                    //                    post.postId = postDictionary["postId"] as! String
                    self.snapPosts.append(post)
                }
            }
        })
    }
    
    func locationsPickedLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let annotation = PhotoAnnotation()
        let locationCoordinate = CLLocationCoordinate2D(latitude: latitude as CLLocationDegrees, longitude: longitude as CLLocationDegrees)
        annotation.coordinate = locationCoordinate
        
        
        
        annotation.photo = self.image
        //        annotation.title = String(describing: latitude)
        self.mapView.addAnnotation(annotation)
        //        print("runing")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is PhotoAnnotation) {
            return nil
        }
        let annotation = annotation as! PhotoAnnotation
        
        let resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeRenderImageView.image = self.image
        if annotation.photo != nil {
            print("Has a photo")
        }
        //self.image
        //(annotation as? PhotoAnnotation)?.photo
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        var thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let reuseId = "Location"
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        anView!.image = thumbnail
        //        print("Get an annotation view")
        
        return anView
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

class PhotoAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var photo: UIImage!
    
    var title: String? {
        return "\(coordinate.latitude)"
    }
}


//        var img:UIImage!
//
//        let imageRef = FIRStorage.storage().reference().child("\(snapPosts[index].postId!).png")
//        imageRef.downloadURL { (Url: URL?, error: Error?) in
//            if let error = error {
//                print("Getting imageUrl error:\(error.localizedDescription)")
//            } else {
//                let imageUrl = Url
//                print("3")
//                let data = NSData(contentsOf: imageUrl!)! as Data
//                img = UIImage(data: data)
//
//
//            }
//
//        }
