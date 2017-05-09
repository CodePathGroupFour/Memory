//
//  ProfileViewController.swift
//  SnapMap
//
//  Created by Jason Wong on 3/24/17.
//  Copyright © 2017 Jason Wong. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageVIew: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var newUsername: UITextField!
    
    var dbref = FIRDatabase.database().reference(fromURL: "https://snapmap-e45c3.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if FIRAuth.auth()?.currentUser != nil {
            // User is signed in.
            let user = FIRAuth.auth()?.currentUser
            let name = user?.displayName
            let photoURL = user?.photoURL
            print(name)
            self.usernameLabel.text = name
            
            let img = NSData(contentsOf: photoURL!)
            self.profileImageVIew.image = UIImage(data: img! as Data)
        
        
            
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateProfile(_ sender: UIBarButtonItem) {
        if newUsername.text != nil {
            let user = FIRAuth.auth()?.currentUser
            let ref = dbref.child("Users")
            let newName = ["name" : "\(String(describing: newUsername.text))"]
            ref.child("userid: \(String(describing: user!.uid))").updateChildValues(newName)
            self.usernameLabel.text = newUsername.text
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabVc = storyboard.instantiateViewController(withIdentifier: "tabbarcontroller") as! UITabBarController
        tabVc.selectedIndex = 0
        self.present(tabVc, animated: false, completion: nil)
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
