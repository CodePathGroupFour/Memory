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

class HomeViewController: UIViewController {
    
    @IBOutlet weak var profileimg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        // Do any additional setup after loading the view.
        
        if FIRAuth.auth()?.currentUser != nil {
            // User is signed in.
            let user = FIRAuth.auth()?.currentUser
            let name = user?.displayName
          //  let email = user?.email
          //  let uid = user?.uid
            let photoURL = user?.photoURL
            
            self.nameLabel.text = name
            
            let img = NSData(contentsOf: photoURL!)
            self.profileimg.image = UIImage(data: img! as Data)
            
            
            //stores it into db
            
            var storage = FIRStorage.storage()
            
            // Get a non-default Storage bucket
          //  let storageRef = storage.reference(forURL: "gs://snapmap-e45c3.appspot.com/")
            
          //  let request = FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id,name,taggable_friends{name,picture.type(large)}"], httpMethod: "GET")
          //  request?.start(completionHandler: {(connection, result, error) -> Void in
         //   })
            
            
            
        } else {
            // No user is signed in.
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func loadData(){
        let request = FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id,name,taggable_friends{name,picture.type(large)}"], httpMethod: "GET")
        request?.start(completionHandler: {(connection, result, error) -> Void in
            // Insert your code here
            print(result)
            print("!!!!!!!!!")
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
