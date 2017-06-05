//
//  ChatListVC.swift
//  FirebaseDemoDemo
//
//  Created by Vikash Kumar on 29/05/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChatListVC: UIViewController {

    @IBOutlet var tblView: UITableView!
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var btnLogout: UIButton!
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tblView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tblView.tableFooterView = UIView()
        
        self.setUI()
        
        //registring 3D Touch Preview
        if self.traitCollection.forceTouchCapability == .available {
            self.registerForPreviewing(with: self, sourceView: self.tblView)
        }
        self.setProfile()
        self.getFirebaseUsers()
    }


    func setUI()  {
        btnLogout.layer.borderColor = UIColor.white.cgColor
        btnLogout.layer.borderWidth = 1.0
        btnLogout.layer.cornerRadius = 2.0

    }

    //
    func setProfile() {
        if !loggedUser.photo.isEmpty {
            if let url =  URL(string: loggedUser.photo) {
                self.userPhoto.setImage(url: url)
            }
        }
    }
    
    //Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "conversationSegue" {
            let dest = segue.destination as! ChatConversationsVC
            dest.friend = sender as! User
        }
    }
    
}

//MARK:- IBAction
extension ChatListVC {
    @IBAction func profileBtn_clicked(sender: UIButton) {
        
    }
    
    @IBAction func backButton_clicked(sender: UIButton) {
        do {
            try FIRAuth.auth()?.signOut()
            self.navigationController?.popViewController(animated: true)
        } catch {
            
        }
    }
}

//MARK:- UITableView Delegate, DataSource
extension ChatListVC: UITableViewDataSource, UITableViewDelegate  {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        let user = users[indexPath.row]
        cell.lblTitle.text = user.name
        cell.imgView.setImage(url: URL(string: user.photo)!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tblView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "conversationSegue", sender: users[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
}

//MARK:- UIViewControllerPreviewingDelegate
extension ChatListVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tblView.indexPathForRow(at: location), let cell = tblView.cellForRow(at: indexPath) {
            let chatConversationVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatConversationsVC") as! ChatConversationsVC
            chatConversationVC.friend = users[indexPath.row]
            previewingContext.sourceRect = cell.frame
            return chatConversationVC
        }
        return nil
        
    }
    
}

//MARK:- Firebase database
extension ChatListVC {
    
    func getFirebaseUsers() {
        //create a firebase database reference
        let dbRef = FIRDatabase.database().reference()
        
        //define the path of Users list in firebase database.
        let usersPath =  dbRef.child("Users")
        
        usersPath.observe(.value, with: { (snapshot) in
            print(snapshot.value!)
            self.users.removeAll()
            for children in snapshot.children {
                let snap = children as! FIRDataSnapshot
                let fUser = snap.value as! [String : String]
                let user = User(fUser)
                if user.firAuthID != loggedUser.firAuthID {
                    self.users.append(user)
                }
            }
            self.tblView.reloadData()
        })
    }
    
}



