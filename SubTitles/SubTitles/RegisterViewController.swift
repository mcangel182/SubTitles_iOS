//
//  RegisterViewController.swift
//  SubTitles
//
//  Created by Maria Camila Angel on 31/10/16.
//  Copyright © 2016 M01. All rights reserved.
//

import UIKit
import SwiftyJSON

class RegisterViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordConfirmation: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerBtn.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissRegister(_ sender: Any) {
        self.dismiss(animated: true, completion: {()->Void in
            self.presentingViewController?.dismiss(animated: true, completion: nil);
        });
    }
    
    @IBAction func register(_ sender: Any) {
        let username = self.username.text
        let password = self.password.text
        let passwordConfirmation = self.passwordConfirmation.text
        
        if(passwordConfirmation != password){
            DispatchQueue.main.async(execute: {
                let alertController = UIAlertController(title: "SubTitles", message:"The passwords don't match", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            })
        } else {
            RestApiManager.sharedInstance.register(username: username!, password: password!, onCompletion: {(json: JSON) in
                print("JSON: \(json)")
                if (json.dictionary?["registro"]?.bool)! {
                    print("se registro")
                    DispatchQueue.main.async {
                        let id = (json.dictionary?["usuario"]?.dictionary?["id"]?.int)!
                        let preferences = UserDefaults.standard
                        preferences.set(id, forKey: "userId")
                        preferences.synchronize()
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
                        self.present(viewController, animated: true, completion: nil)
                    }
                    
                } else {
                    print("credenciales pichas")
                    DispatchQueue.main.async(execute: {
                        let alertController = UIAlertController(title: "SubTitles", message:"Username already exists", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    })
                }
            })
        }
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
