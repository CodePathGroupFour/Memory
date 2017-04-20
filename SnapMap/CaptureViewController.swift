//
//  CaptureViewController.swift
//  SnapMap
//
//  Created by Lum Situ on 4/19/17.
//  Copyright © 2017 Jason Wong. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase

class CaptureViewController: UIViewController {

    @IBOutlet weak var captureImage: UIImageView!
    @IBOutlet weak var captureText: UITextView!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let text = captureText.text
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(for segue: UIStoryboardSegue,_ sender: UIBarButtonItem) {
        
        _ = segue.destination as! HomeViewController
        
    }
    
    @IBAction func toLocationView(for segue: UIStoryboardSegue, _ sender: UIBarButtonItem) {
        //let segue: UIStoryboardSegue
        let locationsViewController = segue.destination as! LocationsViewController
        locationsViewController.delegate = self as! LocationsViewControllerDelegate
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: UIBarButtonItem?) {
//        let locationsViewController = segue.destination as! LocationsViewController
//        locationsViewController.delegate = self as! LocationsViewControllerDelegate
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
