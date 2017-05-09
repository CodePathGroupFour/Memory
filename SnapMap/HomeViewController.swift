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
import MapKit
import MBProgressHUD

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var snapUsers = [User]()
    var snapPosts = [Post]()
    var newPosts = [Post]()
    
    var photoUrl = [URL]()
    
    
    
//    var dbref = FIRDatabase.database().reference(fromURL: "https://snapmap-e45c3.firebaseio.com/")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //mapView.alpha = 0
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 500
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        retrieveUsers()
        retrievePosts()
        
        MBProgressHUD.hide(for: self.view, animated: true)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipe(_ :)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
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
                
                //print(snapshot.value)
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
                            print("postDictionary: \(postDictionary)")
                        }
                        
                        if let latitude = postDictionary["latitude"] {
                            post.latitude = latitude as! Double
                        }
                        
                        if let longitude = postDictionary["longitude"] {
                            post.longitude = longitude as! Double
                        }
                        
                        if let id = postDictionary["postId"] {
                            post.postId = id as! String
                        }
                        
                        if let text = postDictionary["text"] {
                            post.text = text as! String
                        }
                        
                        if let name = postDictionary["name"] {
                            post.name = name as! String
                        }
                        
                        self.snapPosts.append(post)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
        })
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        retrievePosts()
        self.tableView.reloadData()
        
        // Tell the refreshControl to stop spinning
        refreshControl.endRefreshing()
    }
    
    func leftSwipe(_ sender: UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabVc = storyboard.instantiateViewController(withIdentifier: "tabbarcontroller") as! UITabBarController
            tabVc.selectedIndex = 1
            self.present(tabVc, animated: false, completion: nil)
            print("Can swipe")
        }
        
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
        tableView.alpha = 0
        mapView.alpha = 1
        print("switch to mapview")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapView" {
            _ = segue.destination as! MapViewController
        }
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapPosts.count
        
    }
    
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeViewCell", for: indexPath) as! HomeViewCell
        newPosts = snapPosts.reversed()
        let post = newPosts[indexPath.row]

        cell.post = post
        cell.nameLabel.text = post.name
        cell.captionLabel.text = post.text
        
        // Retrieve User Profile Image
        for user in snapUsers {
            if user.name == post.name {
                let profileURL = user.profileURL
                cell.profileImg.setImageWith(URL(string: profileURL!)!)
            }
        }
        
        return cell
    }

}
