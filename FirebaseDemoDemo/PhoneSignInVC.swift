//
//  PhoneSignInVC.swift
//  FirebaseDemoDemo
//
//  Created by Vikash Kumar on 22/05/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import Firebase


class PhoneSignInVC: UIViewController {
    @IBOutlet var btnContainerView: UIView!
    @IBOutlet var txtPhone: UITextField!

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

    
    //MARK: Firebase Phone Login
    func firebasePhoneLogin() {
        let phoneNumber = txtPhone.text!
        if !phoneNumber.isEmpty {
            
        }
    }
}

extension PhoneSignInVC {
    @IBAction func backButton_clicked(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func loginWithEmail(sender: UIButton) {
    }
    
    @IBAction func signupButton_clicked(sender: UIButton) {
    }
    

}
