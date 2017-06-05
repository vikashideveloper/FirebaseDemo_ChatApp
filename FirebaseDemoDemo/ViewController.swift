//
//  ViewController.swift
//  FirebaseDemoDemo
//
//  Created by Vikash Kumar on 19/05/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import GoogleSignIn
import FacebookCore
import FacebookLogin
import FBSDKLoginKit
import TwitterKit

var loggedUser: User!

class ViewController: UIViewController {
    
    @IBOutlet var btnContainerView: UIView!
    @IBOutlet var btnGoogle: UIButton!
    @IBOutlet var btnFacebook: UIButton!
    @IBOutlet var btnTwitter: UIButton!
    @IBOutlet var activity: UIActivityIndicatorView!
    
    var socialUser: User?
    
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
        
        setGoogleInfo()
    }
}

//MARK:- IBActions
extension ViewController {
    @IBAction func googleLogin_clicked(sender: UIButton) {
        activity.center = sender.center
        activity.startAnimating()
        self.signInWithGoogle()
    }
    
    @IBAction func facebookLogin_clicked(sender: UIButton) {
        activity.center = sender.center
        activity.startAnimating()
        self.fbLogin()
        
    }
    
    @IBAction func twitterLgoin_clicked(sender: UIButton) {
        activity.center = sender.center
        activity.startAnimating()
        self.twitterLogin()
    }
}


//MARK:- firebaes Others
extension ViewController {
    
    func firebaseAuthentication(credential: FIRAuthCredential, completion: @escaping (Bool)->Void) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            self.activity.stopAnimating()
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            
            //Firebase authenticated user
            print("Firebase authenticated user : \(user!)")
            
            self.getFirebaseUserInfoFor(user: user!)
            completion(true)
        })
        
    }
    
}


//MARK:- Google SignIn
extension ViewController: GIDSignInUIDelegate, GIDSignInDelegate {
    
    func setGoogleInfo() {
        if let user =  GIDSignIn.sharedInstance().currentUser {
            let title = user.profile.name + " (SignOut)"
            btnGoogle.setTitle(title, for: .normal)
        }
    }
    
    func signInWithGoogle() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func logout_Google() {
        GIDSignIn.sharedInstance().signOut()
        btnGoogle.setTitle("Google", for: .normal)
        self.activity.stopAnimating()
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            self.activity.stopAnimating()
            print(error.localizedDescription)
            return
        }
        print("didSignInFor Google User : \(user)")
        
        //Google SignIn User Authenticate with firebase
        let googleAuthoProvider = FIRGoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
        self.firebaseAuthentication(credential: googleAuthoProvider) { isSuccess in
        }
            
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("didDisconnectWith Google User : \(user)")
    }
    
    
}

//MARK:- Facebook login
extension ViewController {
    func fbLogin() {
        let fbManager = LoginManager()
        fbManager.logIn([.publicProfile, .email], viewController: self) { (result) in
            self.activity.stopAnimating()
            switch result {
            case .failed(let err):
                self.showAlert(message: err.localizedDescription)
            case .cancelled:
                //self.showAlert(message: "Cancel Facebook login")
                print("Cancel")
            case .success( _, _, let token):
                self.getFbUsrProfile(fbId: token.userId!) {user in
                    if let user = user {
                        self.socialUser = user
                        //firebase authenticating.
                        let fbCredential = FIRFacebookAuthProvider.credential(withAccessToken: token.authenticationToken)
                        self.firebaseAuthentication(credential: fbCredential){ _ in  }
                    }

                }
                
            }
        }
    }
    
    //get facebook user's profile informations
    func getFbUsrProfile(fbId: String, block: @escaping (User?)-> Void) {
        UserProfile.fetch(userId: fbId) { (result) in
            print(result)
            
            switch result {
            case .success(let fbUser):
                    let socialUser = User(socialID: fbId,
                                                firAuthId: "",
                                                name: fbUser.fullName ?? "",
                                                loginType: "fb",
                                                email: fbUser.email ?? "",
                                                photo: fbUser.profilePhotoURL?.absoluteString ?? "")
                block(socialUser)
            case .failed(let error):
                print(error.localizedDescription)
                block(nil)
            }
        }
    }
}

//MARK:- Twitter Login
extension ViewController {
    func twitterLogin() {
        
        Twitter.sharedInstance().logIn { (session, error) in
            if let err = error {
                self.showAlert(message: err.localizedDescription)
                self.activity.stopAnimating()
                return
            }
            
            if let session = session {
                print(session.userName)
                self.getTwitterUserProfileFor(session: session)
            }
        }
    }
    
    func getTwitterUserProfileFor(session: TWTRSession) {
        let userId = session.userID
     TWTRAPIClient(userID: userId).requestEmail { (email, error) in
        print("twtter email : \(email ?? error?.localizedDescription)")
        }
        TWTRAPIClient(userID: userId).loadUser(withID: userId, completion: { (user, error) in
            if let err = error {
                print(err.localizedDescription)
            }
            if let user = user {
                 self.socialUser = User(socialID: userId, firAuthId: "", name: user.name, loginType: "twtr", email: "", photo: user.profileImageLargeURL)
               //Firebase authenticating
                let twCredential = FIRTwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
                self.firebaseAuthentication(credential: twCredential){ isSuccess in}

            }
            print("TwitterUser : \(user!)")
        })
    }
}


//MARK:- Firebase database
extension ViewController {
   
    // func will create user in fireabse database if not exist. Otherwise only will fetch user's detail.
    func getFirebaseUserInfoFor(user: FIRUser) {
       self.activity.startAnimating()
        //create a firebase database reference
        let dbRef = FIRDatabase.database().reference()
        
        //define the path of Users list in firebase database.
        let usersPath =  dbRef.child("Users")
        
        let userId = user.uid
        self.socialUser?.firAuthID = user.uid
        
        //checkout user exist or not with the userid
        usersPath.child(userId).queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot, string) in
            if !snapshot.exists() {
                //create new user in database.
                var jsUser = self.socialUser!.jsonValues()
                jsUser["firebaseID"] = user.uid
                usersPath.child(userId).setValue(jsUser)
                
                loggedUser = User(jsUser)
                UserDefaults.standard.setValue(jsUser, forKey: loggedInUserInfoKey)
                
            } else {
                print("UserInfo : \(snapshot.value!)")
                if let fUser = snapshot.value as? [String : String] {
                    loggedUser = User(fUser)
                    UserDefaults.standard.setValue(fUser, forKey: loggedInUserInfoKey)
                }
            }
            
            self.activity.stopAnimating()
            self.performSegue(withIdentifier: "chatlistSegue", sender: nil)
        }
        
    }
    
}

//MARK:- User
class User {
    var socialId: String
    var firAuthID: String
    var name: String
    var email: String
    var photo: String
    var loginType: String
    
    init(_ info: [String : String]) {
        let id = info["firAuthID"]!
        let name = info["name"]!
        let email = info["email"]!
        let photo = info["photo"] ?? ""
        let socialId = info["socialID"] ?? ""
        
        self.name = name
        self.email = email
        self.firAuthID = id
        self.photo = photo
        self.socialId = socialId
        self.loginType = ""

    }
    
    init(socialID: String = "", firAuthId: String, name: String, loginType: String, email: String = "", photo: String = "") {
        self.socialId = socialID
        self.firAuthID = firAuthId
        self.name = name
        self.email = email
        self.photo = photo
        self.loginType = loginType
        
    }
    
    func jsonValues()->[String : String] {
        return ["socialID" : socialId,
                "firAuthID" : firAuthID,
                "name" : name,
                "email" : email,
                "photo" : photo,
                "loginType": loginType]
    }

}



extension UIImageView {
    func setImage(url: URL) {
        if let image = ImageCache.sharedCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            self.image = image
        } else {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if let err = error {
                    //print(err.localizedDescription)
                } else {
                    if let data = data {
                        let image = UIImage(data: data)
                        ImageCache.sharedCache.setObject(image!, forKey: url.absoluteString as AnyObject, cost: data.count)
                        DispatchQueue.main.async {
                            self.image = image
                        }
                    }
                }
            }).resume()
        }
    }
    
}

//ImageCache
class ImageCache {
    static let sharedCache: NSCache<AnyObject, AnyObject> = {
       let cache = NSCache<AnyObject, AnyObject>()
        cache.name = "ImageStorageCache"
        cache.countLimit = 100
        cache.totalCostLimit = 100*1024*1024
        return cache
    }()
    
}
