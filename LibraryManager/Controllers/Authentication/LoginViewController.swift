//
//  ViewController.swift
//  LibraryManager
//
//  Created by Diogo Oliveira on 12/03/2021.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var eyeClick = true
    
    let loginManager = LoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordField.isSecureTextEntry = eyeClick
        // Do any additional setup after loading the view.
        
        loginManager.delegate = self
        
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
        //performSegue(withIdentifier: "LoginToMain", sender: self)
        if let email = emailField.text, let password = passwordField.text {
            loginManager.login(email: email, password: password)
        }
        
        
    }
}

extension LoginViewController : LoginManagerDelegate {
    func didFailLogin(_ loginManager: LoginManager, statusCode: Int, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Invalid Credentials", message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    func didPerformLogin(_ loginManager: LoginManager, statusCode: Int, loginData: LoginModel) {
        DispatchQueue.main.async {
                LoginInfo.loginInstance.isLogeegdIn = true
                LoginInfo.loginInstance.userId = loginData.Id
                LoginInfo.loginInstance.userName = loginData.Name
                LoginInfo.loginInstance.userToken = loginData.Token
                LoginInfo.loginInstance.userRole = loginData.Role
                
                self.performSegue(withIdentifier: "LoginToMain", sender: self)
        }
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
}

