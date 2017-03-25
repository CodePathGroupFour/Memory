//
//  LoginViewController.swift
//  SnapMap
//
//  Created by Jason Wong on 3/21/17.
//  Copyright © 2017 Jason Wong. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var FBLoginButton: FBSDKLoginButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        FBLoginButton.delegate = self
        self.FBLoginButton.isHidden = true
        FIRAuth.auth()?.addStateDidChangeListener
        { auth, user in
            if let user = user
            {
                //user is signed in
                //self.performSegue(withIdentifier: "LoginSegue", sender: nil)
                let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                let homeViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "tabbarcontroller")
                self.present(homeViewController, animated: true, completion: nil)
               
            }else{
                self.FBLoginButton.isHidden = false
            }
        }
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButton(_ sender: Any) {
        FBLoginButton.readPermissions = ["email", "public_profile", "user_friends", "read_custom_friendlists"]
    }
    
 
 
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!)
    {
        if error != nil
        {
            print(error.localizedDescription)
        }else if result.isCancelled {
            
        }
        else
        {
            //loginSuccess = true
            self.FBLoginButton.isHidden = true
            print("login succeed")
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            FIRAuth.auth()?.signIn(with: credential)
            { (user, error) in
                print(error?.localizedDescription ?? "user logged in with Firebase!")
            }
        }
    }
    
    //logout
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!){}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
