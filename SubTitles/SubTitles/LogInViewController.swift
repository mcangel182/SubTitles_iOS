//
//  LogInViewController.swift
//  SubTitles
//
//  Created by Maria Camila Angel on 30/10/16.
//  Copyright © 2016 M01. All rights reserved.
//

import UIKit
import SwiftyJSON

class LogInViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    weak var activityIndicatorView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.layer.cornerRadius = 5
        registerBtn.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(_ sender: Any) {
        let username = self.username.text
        let password = self.password.text
        
        RestApiManager.sharedInstance.login(username: username!, password: password!, onCompletion: {(json: JSON) in
            if (json.dictionary?["login"]?.bool)! {
                print("se logego")
                DispatchQueue.main.async {
                    let id = (json.dictionary?["id"]?.int)!
                    let preferences = UserDefaults.standard
                    preferences.set(id, forKey: "userId")
                    preferences.synchronize()
                    self.dismiss(animated: false, completion: {()->Void in
                        self.presentingViewController?.dismiss(animated: true, completion: nil);
                    });
                }
                
            } else {
                print("credenciales pichas")
                DispatchQueue.main.async(execute: {
                    let alertController = UIAlertController(title: "SubTitles", message:"The username or password are incorrect", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                })
            }
        })
    }

    @IBAction func dismissLogin(_ sender: Any) {
        self.dismiss(animated: true, completion: {()->Void in
            self.presentingViewController?.dismiss(animated: true, completion: nil);
        });
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
