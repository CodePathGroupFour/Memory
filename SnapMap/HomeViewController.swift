//
//  HomeViewController.swift
//  SnapMap
//
//  Created by Jason Wong on 3/21/17.
//  Copyright © 2017 Jason Wong. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseAuth
import FirebaseStorage
import Firebase
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var snapUsers = [User]()
    var snapPosts = [Post]()
    
//    var dbref = FIRDatabase.database().reference(fromURL: "https://snapmap-e45c3.firebaseio.com/")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        retrieveUsers()
        retrievePosts()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                let post = Post()
                for childSnap in  snapshot.children.allObjects
                {
                    let snap = childSnap as! FIRDataSnapshot
                    if let snapshotValue = snapshot.value as? NSDictionary, let snapVal = snapshotValue[snap.key] as? NSDictionary
                    {
                        for postInfo in snapVal {
                            postDictionary = (postInfo.value as? NSDictionary)!
                        }
                        
                        print(snapVal)
                        print(self.snapPosts.count)
//                        if let latitude = snapVal["latitude"] {
//                            post.latitude = latitude as! Double
//                        }
                        post.latitude = postDictionary["latitude"] as! Double
//                        if let longitude = snapVal["longitude"] {
//                            post.longitude = longitude as! Double
//                        }
                        post.longitude = postDictionary["longitude"] as! Double
//                        if let id = snapVal["postId"] {
//                            post.postId = id as! String
//                        }
                        post.postId = postDictionary["postId"] as! String
                        self.snapPosts.append(post)
//                        print(self.snapPosts[0].latitude)
//                        print(self.snapPosts[0].longitude)
//                        print(self.snapPosts[0].postId)
                    }
                }
                self.tableView.reloadData()
        })
        
        
    }
    
    
    @IBAction func logoutBtnClicked(_ sender: Any) {
        
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        FBSDKAccessToken.setCurrent(nil)
        
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let loginviewcontroller: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "loginViewController")
        self.present(loginviewcontroller, animated: true, completion: nil)

        
    
    }
    
    @IBAction func toMapView(_ sender: UIBarButtonItem) {
        
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapPosts.count
    }
    
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeViewCell", for: indexPath) as! HomeViewCell
        print("runing tableView")
        let post = snapPosts[indexPath.row]
//        let imageRef = FIRStorage.storage().reference().child("\(post.postId!).png")
//        imageRef.downloadURL { (Url: URL?, error: Error?) in
//            if let error = error {
//                print("Getting imageUrl error:\(error.localizedDescription)")
//            } else {
//                cell.imageUrl = Url
//            }
//            
//        }

        cell.post = post
        
        return cell
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
