//
//  ViewController.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 12/03/2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var eyeClick = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordField.isSecureTextEntry = eyeClick
        // Do any additional setup after loading the view.
        
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func eyeButton(_ sender: Any) {
        if eyeClick {
            passwordField.isSecureTextEntry = false
        } else {
            passwordField.isSecureTextEntry = true
        }
        
        eyeClick = !eyeClick
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if eyeClick {
            performSegue(withIdentifier: "LoginToMain", sender: self)
        } else {
            print("nope")
        }
    }
}

