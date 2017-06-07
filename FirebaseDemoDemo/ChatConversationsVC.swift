//
//  ChatConversationsVC.swift
//  FirebaseDemoDemo
//
//  Created by Vikash Kumar on 30/05/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChatConversationsVC: UIViewController {

    @IBOutlet var imgFriend: UIImageView!
    @IBOutlet var tblChat: UITableView!
    @IBOutlet var chatView: UIView!
    @IBOutlet var txtMessage: UITextView!
    @IBOutlet var lblFriendName: UILabel!
    @IBOutlet var chatBoxBottomConstraint: NSLayoutConstraint!
    @IBOutlet var txtMessageLeadingSpace: NSLayoutConstraint!
    
    var friend: User!
    var messages = [Message]()
    let msgLblFont = UIFont(name: "HelveticaNeue", size: 15)
    var orientation = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        self.setFriendInfo()
        self.keyboardNotificationObserve()
        self.configureDatabase()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setUI() {
        txtMessage.layer.cornerRadius = 5.0
        txtMessage.clipsToBounds = true
        txtMessage.layer.borderColor = UIColor.darkGray.cgColor
        txtMessage.layer.borderWidth = 1.0

    }
    
    func setFriendInfo() {
        lblFriendName.text = friend.name
        imgFriend.setImage(url: URL(string: friend.photo)!)
    }
    
    lazy var previewActions: [UIPreviewActionItem] = {
        func previewActionForTitle(_ title: String, style: UIPreviewActionStyle = .default) -> UIPreviewAction {
            return UIPreviewAction(title: title, style: style) { previewAction, viewController in
            }
        }
        
        let action1 = previewActionForTitle("Default Action")
        let action2 = previewActionForTitle("Destructive Action", style: .destructive)
        
        let subAction1 = previewActionForTitle("Sub Action 1")
        let subAction2 = previewActionForTitle("Sub Action 2")
        let groupedActions = UIPreviewActionGroup(title: "Sub Actions…", style: .default, actions: [subAction1, subAction2] )
        
        return [action1, action2, groupedActions]
    }()

    
    override var previewActionItems: [UIPreviewActionItem] {
        return previewActions
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Confirgure database
    func configureDatabase() {
        let firDb = FIRDatabase.database().reference()
        let groupId = [friend.firAuthID, loggedUser.firAuthID].sorted().joined(separator: "_")
        let groupPath = firDb.child("Chat/\(groupId)")
       
        groupPath.observe(.childAdded, with: { (snap) in
            let message = Message(snap)
            self.messages.append(message)
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tblChat.insertRows(at: [indexPath], with: .automatic)
            self.scrollToBottomMessage()
            
        })
    }

    //MARK: Send Message
    func sendMessage()  {
        let messageText = txtMessage.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if !messageText.isEmpty {
            let message = Message()
            message.text = messageText
            message.fromUserID = loggedUser.firAuthID
            message.toUserID = friend.firAuthID
            message.fromUserName = loggedUser.name
            message.toUserName = friend.name
            message.timeStamp = Date().timeIntervalSinceNow
            

            let firDb = FIRDatabase.database().reference()
            let groupId = [friend.firAuthID, loggedUser.firAuthID].sorted().joined(separator: "_")
            let groupPath = firDb.child("Chat/\(groupId)")
            groupPath.childByAutoId().setValue(message.json)
            
            txtMessage.text = ""
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if size.width < size.height {
            orientation = 0
        } else {
            orientation = 1
        }
        tblChat.reloadData()
    }
}

extension ChatConversationsVC {
    @IBAction func backButton_clicked(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendMessage_clicked(sender: UIButton) {
        self.sendMessage()
    }

    @IBAction func cameraBtn_clicked(sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: [.curveEaseInOut], animations: {
            self.txtMessageLeadingSpace.constant = self.txtMessageLeadingSpace.constant == 100 ? 8 : 100
            self.chatView.layoutIfNeeded()
        }) { (isFinish) in
            
        }
    }
}

//MARK: Tableview DataSource and Delegate
extension ChatConversationsVC: UITableViewDataSource, UITableViewDelegate  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        var cellId = "myMessageCell"
        if message.fromUserID == friend.firAuthID {
            cellId = "cell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! TableViewCell
        cell.lblTitle.text = messages[indexPath.row].text
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let msgText = self.messages[indexPath.row].text
       
        //Create a label just for calculate size of message.
        let msgLbl = UILabel()
        msgLbl.frame = CGRect(x: 0, y: 0, width: orientation == 0 ? 220 : 300, height: 0)
        msgLbl.font = msgLblFont!
        msgLbl.text = msgText
        msgLbl.numberOfLines = 0
        msgLbl.sizeToFit()
        
        let lblSize = msgLbl.frame
        
        return lblSize.height + 28
        
    }
    
    func scrollToBottomMessage(animated: Bool = true) {
        if messages.count == 0 { return }
        let bottomMessageIndex = IndexPath(row: tblChat.numberOfRows(inSection: 0) - 1, section: 0)
        tblChat.scrollToRow(at: bottomMessageIndex, at: .bottom, animated: animated)
    }
}

extension ChatConversationsVC {
    func keyboardNotificationObserve() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyboard(nf:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideKeyboard(nf:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
       // NotificationCenter.default.addObserver(self, selector: #selector(self.hideKeyboard(nf:)), name: Notification.Name.UIKeyboardWillHide, object: nil)

    }
    
    func showKeyboard(nf: Notification) {
        let userinfo = nf.userInfo!
        if let keyboarFrame = (userinfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.chatBoxBottomConstraint.constant = keyboarFrame.height
            self.view.layoutIfNeeded()
            self.scrollToBottomMessage()
        }
        
    }
    
    func hideKeyboard(nf: Notification) {
        self.chatBoxBottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
}

//MARK:- Message
class Message {
    var id = ""
    var text = ""
    var type: Int = 1 //1. text, 2. Image, 3. Video
    var fromUserID = ""
    var fromUserName = ""
    var fromUserPhoto = ""
    var toUserID = ""
    var toUserName = ""
    var toUserPhoto = ""
    var timeStamp = 0.0
    
    convenience init(_ snapShot: FIRDataSnapshot) {
        self.init()
        if let json = snapShot.value as? [String : Any] {
            text = (json["Text"] as? String) ?? ""
            
            fromUserID = (json["FromUserID"] as? String) ?? ""
            fromUserName = (json["FromUserName"] as? String) ?? ""
            fromUserPhoto = (json[""] as? String) ?? ""

            toUserID = (json["ToUserID"] as? String) ?? ""
            toUserName = (json["ToUserName"] as? String) ?? ""
            toUserPhoto = (json[""] as? String) ?? ""
            timeStamp =   (json["TimeStamp"] as? Double) ?? 0.0
        }
    }
    
    var json: [String: Any] {
        let json = ["FromUserID" : fromUserID,
                    "FromUserName" : fromUserName,
                    "ToUserID" : toUserID,
                    "ToUserName" : toUserName,
                    "Text" : text,
                    "TimeStamp" : timeStamp] as [String : Any]
        return json
    }
}
