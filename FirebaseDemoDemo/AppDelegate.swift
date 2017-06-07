//
//  AppDelegate.swift
//  FirebaseDemoDemo
//
//  Created by Vikash Kumar on 19/05/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FacebookLogin
import TwitterKit
import  UserNotifications
import FirebaseDatabase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Configure Firebase App.
        FIRApp.configure()
        self.googleSignInSetup()
        self.registerForRemoteNotification()
        
        //Facebook sdk setup
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //Twitter sdk setup
        Twitter.sharedInstance().start(withConsumerKey: "0970knm91QVWZgTAubpok8NfV",
                                       consumerSecret: "PysdaBsET2j0BmaWAQIaTAYSTdnv7rXYoZnFibAAPxluwg02IT")
        self.checkLoginUser()
        return true
    }
    
    
    //Register for Remote Notifications.
    func registerForRemoteNotification() {

        let options : UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (isGranted, error) in
            if isGranted {
                
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var tokenString = ""
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [deviceToken[i] as CVarArg])
        }
        print(tokenString)
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
        FIRInstanceID.instanceID().token()
        if loggedUser != nil {
            let dbRef = FIRDatabase.database().reference()
            
            //define the path of Users list in firebase database.
            let usersPath =  dbRef.child("Users")
           let firToken = FIRInstanceID.instanceID().token()!

            let userId = loggedUser.firAuthID
            usersPath.child(userId).child("DeviceToken").setValue(firToken)
        }

        
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(userInfo)
    }
    ///
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
       
        let fbUrlHandle = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        let googleHandle =  GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: [:])
        let twitterHandle = Twitter.sharedInstance().application(app, open: url, options: options )
        return  googleHandle || fbUrlHandle || twitterHandle
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

//MARK: firebase
extension AppDelegate  {
    func checkLoginUser() {
        
        if let currentUser = FIRAuth.auth()?.currentUser {
            currentUser.getTokenWithCompletion({ (token, error) in
                if let err = error {
                    print(err.localizedDescription)
                }
                print("refresh Token : \(token ?? "no token found.")")
            })
           
            if let userinfo = UserDefaults.standard.value(forKey: loggedInUserInfoKey) as? [String : String] {
                loggedUser = User(userinfo)
                let nav = window?.rootViewController as! UINavigationController
                let loginVC = nav.storyboard?.instantiateViewController(withIdentifier: "loginVC")
                let chatListVC = nav.storyboard?.instantiateViewController(withIdentifier: "chatListVC")
                nav.viewControllers = [loginVC!, chatListVC!]

            }
        }
    }
    
}

//MARK: Google setup
extension AppDelegate  {
    func googleSignInSetup() {
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
    }
    
}



//Constatns
let loggedInUserInfoKey = "LoggedInUserInfo"

