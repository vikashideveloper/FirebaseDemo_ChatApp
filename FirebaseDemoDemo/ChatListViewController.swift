//
//  ChatListViewController.swift
//  FirebaseDemoDemo
//
//  Created by Vikash Kumar on 20/05/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import Firebase

class ChatListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    var groups = [Group]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func createGroup(sender: UIButton) {
        let alert = UIAlertController(title: "Create New Group", message: "", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "Enter group name"
        }
        let createAction = UIAlertAction(title: "Create", style: .destructive) { (alertC) in
            let textfield = alert.textFields?.first!
            let text = textfield?.text
            if !text!.isEmpty {
                let groupName = text!.replacingOccurrences(of: " ", with: "_")
                FIRMessaging.messaging().subscribe(toTopic: groupName)
                
                print("GroupName : \(groupName)")
                
                let group = Group(name: text!)
                self.groups.append(group)
                self.tableView.reloadData()
            }
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
}


extension ChatListViewController: UITableViewDataSource, UITableViewDelegate  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        let group = groups[indexPath.row]
        cell.lblTitle.text = group.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}



class Group {
    var name = ""
    var id = ""
    var adminName = ""
    
    init(name : String) {
        self.name = name
    }
}

class  TableViewCell: UITableViewCell {
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var imgView: UIImageView!
}
