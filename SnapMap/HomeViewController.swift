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

class HomeViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var snapUsers = [User]()
    var snapPosts = [Post]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        FIRDatabase.database().reference().child("Post").observe(.childAdded, with: { (snapshot) in
            if let Postdictionary = snapshot.value as? [String: Any]
            {
                let post = Post()
                for childSnap in  snapshot.children.allObjects
                {
                    let snap = childSnap as! FIRDataSnapshot
                    if let snapshotValue = snapshot.value as? NSDictionary, let snapVal = snapshotValue[snap.key] as? NSDictionary
                    {
//                        print(snapVal)
                        post.latitude = snapVal["latitude"] as! Double
                        post.longitude = snapVal["longitude"] as! Double
                        post.postId = snapVal["postId"] as! String
                        self.snapPosts.append(post)
//                        print(self.snapPosts[0].latitude)
//                        print(self.snapPosts[0].longitude)
//                        print(self.snapPosts[0].postId)
                    }
                }
            }
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
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapUsers.count
    }
    
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeViewCell") as! HomeViewCell
        
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
