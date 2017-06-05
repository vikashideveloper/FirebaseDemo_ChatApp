//
//  ProfileViewController.swift
//  FirebaseDemoDemo
//
//  Created by Vikash Kumar on 31/05/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var btnAddPhoto: UIButton!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var btnSave: UIButton!
    @IBOutlet var infoContainer: UIView!
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var infoContainerHeight: NSLayoutConstraint!
    @IBOutlet var infoContainerLSHeight: NSLayoutConstraint!

    
    @IBOutlet var rowViews: [UIView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUI()
    }

    func setUI() {
        txtEmail.isUserInteractionEnabled = false
        txtName.isUserInteractionEnabled = false

        btnEdit.layer.borderColor = UIColor.white.cgColor
        btnEdit.layer.borderWidth = 1.0
        btnEdit.layer.cornerRadius = 2.0
       
        btnAddPhoto.layer.borderColor = UIColor.black.cgColor
        btnAddPhoto.setTitleColor(UIColor.black, for: .normal)
        btnAddPhoto.layer.borderWidth = 1.0
        btnAddPhoto.layer.cornerRadius = 2.0

        btnCancel.layer.borderColor = UIColor.black.cgColor
        btnCancel.setTitleColor(UIColor.black, for: .normal)
        btnCancel.layer.borderWidth = 1.0
        btnCancel.layer.cornerRadius = 3.0
        
        btnSave.layer.cornerRadius = 3.0
        
        infoContainer.layer.cornerRadius = 5.0
        infoContainer.clipsToBounds = true
        
        for v in rowViews {
            v.layer.cornerRadius = 4.0
            v.clipsToBounds = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


//MARK: IBActions
extension ProfileViewController {
    @IBAction func backButton_clicked(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editBtn_clicked(sender: UIButton) {
        txtEmail.isUserInteractionEnabled = true
        txtName.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3) {
            self.txtName.borderStyle = .roundedRect
            self.txtEmail.borderStyle = .roundedRect
            self.infoContainerHeight.constant = 160
            self.infoContainerLSHeight.constant = 160
            
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func cancel_clicked(sender: UIButton) {
        txtEmail.isUserInteractionEnabled = false
        txtName.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.3) {
            self.txtName.borderStyle = .none
            self.txtEmail.borderStyle = .none
            self.infoContainerHeight.constant = 112
            self.infoContainerLSHeight.constant = 112
            self.view.layoutIfNeeded()

        }
    }
}
