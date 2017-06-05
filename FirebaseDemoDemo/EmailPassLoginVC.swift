//
//  EmailPassLoginVC.swift
//  FirebaseDemoDemo
//
//  Created by Vikash Kumar on 20/05/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import Firebase

class EmailPassLoginVC: UIViewController {

    @IBOutlet var btnContainerView: UIView!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var btnSignup: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBtnContainerView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBtnContainerView() {
        btnContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnContainerView.layer.shadowColor = UIColor.black.cgColor
        btnContainerView.layer.shadowRadius = 3
        btnContainerView.layer.shadowOpacity = 0.3
        btnContainerView.layer.masksToBounds = false
        
    }
    
    func restText()  {
        self.txtEmail.text = ""
        self.txtPassword.text = ""

    }

    //MARK: Firebase Email : Login and Signup
    func firebaseEmailLogin() {
        let emailText = txtEmail.text!
        let passwordText = txtPassword.text!
        btnLogin.isEnabled = false
        if !emailText.isEmpty && !passwordText.isEmpty {
            FIRAuth.auth()?.signIn(withEmail: emailText, password: passwordText, completion: { (user, error) in
               self.btnLogin.isEnabled = true
                if let err = error {
                    self.showAlert(message: err.localizedDescription)
                    return
                }
                
                if let user = user {
                    print(user)
                    self.showAlert(message: "Login success : \(user.email!)")
                    self.restText()
                    self.sendSignupVerificationEmail()

                }
            })
            
        } else {
            print("textfield is empty!")
        }
        
    }
    
    func firebaseEmailSignup() {
        let emailText = txtEmail.text!
        let passwordText = txtPassword.text!
        btnSignup.isEnabled = false
        if !emailText.isEmpty && !passwordText.isEmpty {
            FIRAuth.auth()?.createUser(withEmail: emailText, password: passwordText, completion: { (user, error) in
                self.btnSignup.isEnabled = true
                if let err = error {
                    print(err.localizedDescription)
                    self.showAlert(message: err.localizedDescription)
                    return
                }
                
                if let user = user {
                    self.showAlert(message: "Signup success : \(user.email!)")
                    self.restText()
                    self.sendSignupVerificationEmail()
                }
                
            })
            
        }
    }

    func sendSignupVerificationEmail() {
        FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (error) in
            if let err = error {
                print(err.localizedDescription)
            }
        })
    }
}

extension EmailPassLoginVC {
    @IBAction func backButton_clicked(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginWithEmail(sender: UIButton) {
        self.firebaseEmailLogin()
    }
    
    @IBAction func signupButton_clicked(sender: UIButton) {
        self.firebaseEmailSignup()
    }
    
}

//Alert for controller
extension UIViewController {
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Firebase Test", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
}
