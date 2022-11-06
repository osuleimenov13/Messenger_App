//
//  AppDelegate.swift
//  Messenger
//
//  Created by Olzhas Suleimenov on 25.10.2022.
//

import Firebase
import UIKit
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // configure the FirebaseApp object
        FirebaseApp.configure() // will crash without GoogleService info.plist
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
              // Show the app's signed-out state.
            } else {
              // Show the app's signed-in state.
            }
          }
          return true
        
//        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
//        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        var handled: Bool

        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        
        // Handle other custom URL types.
        
        // If not handled by this app, return false.
        return false
    }
    
    // this function gets called when the user successfully signs in and passes user object GIDGoogleUser
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        guard error == nil else {
            if let error = error {
                print("Fail to sign in with Google: \(error)")
            }
            return
        }
        
        guard let user = user else { return }
        print("Did sign in with Google: \(user)")
        
        guard let email = user.profile?.email,
              let firstName = user.profile?.givenName,
              let lastName = user.profile?.familyName else { return }
        
        DatabaseManager.shared.doesUserExists(with: email) { exists in
            if !exists {
                // insert user to Firebase database
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                    lastName: lastName,
                                                                    emailAddress: email))
            }
            // if exists we are not doing anything because we are not registering we continue with Google account
        }
        // trade access token from Google to Firebase credentials
        let authentification = user.authentication
        guard let idToken = authentification.idToken else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: authentification.accessToken)
        FirebaseAuth.Auth.auth().signIn(with: credential) { authDataResult, error in
            guard authDataResult != nil, error == nil else {
                print("Failed to log in with Google credential.")
                return
            }
            
            print("Successfully signed in with Google credential.")
            NotificationCenter.default.post(name: .didLogInNotification, object: nil)
        }
    }
    
}

