//
//  ViewController.swift
//  watchtest
//
//  Created by Ukai Yu on 3/22/15.
//  Copyright (c) 2015 Ukai Yu. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire
import SwiftyJSON
import Realm
import WatchExtensionEmbeddedLib

class ViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!

    @IBOutlet weak var signInView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //LibFeedlyManager.sharedInstance.removeToken()
        //ReadItLaterManager.sharedInstance.removeToken()
        // Do any additional setup after loading the view, typically from a nib.
        if LibFeedlyManager.sharedInstance.isUserHasValidToken(){
            signInView.hidden = true
            logoImageView.hidden = true
        }else{
            signInView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("signInTapped:")))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func feedlyTapped() {
        let mystoryboard = UIStoryboard(name: "Main", bundle: nil)
        var webController = mystoryboard.instantiateViewControllerWithIdentifier("webView")
        
        let oauthswift = OAuth2Swift(
            consumerKey:    "sandbox",
            consumerSecret: "4205DQXBAP99S8SUHXI3",
            authorizeUrl:   "http://sandbox.feedly.com/v3/auth/auth",
            accessTokenUrl: "http://sandbox.feedly.com/v3/auth/token",
            responseType:   "code"
        )
        oauthswift.webViewController = webController! as! FeedlyViewController
        oauthswift.authorizeWithCallbackURL( NSURL(string: "http://localhost")!, scope: "https://cloud.feedly.com/subscriptions", state: "Feedly", success: {
                credential, response in
            //Save the given token to KeyChain
            LibFeedlyManager.sharedInstance.saveKeychainWithKey(LibFeedlyManager.KeychainKeys.access_token, value: credential.oauth_token)
                LibFeedlyManager.sharedInstance.getProfile()
                }, failure: { error in
                    println("error")
            })
    }
    
    @IBAction func signInTapped(recognizer:UITapGestureRecognizer){
        feedlyTapped()
    }
    
    func doAfterSignedIn(){
        signInView.hidden = true
        logoImageView.hidden = true
    }
    @IBAction func instapaperTapped(sender: AnyObject) {
        self.presentViewController(createInstapaperSignInDialog(), animated: true) { () -> Void in
            
        }
    }
    
    func createInstapaperSignInDialog() -> UIAlertController{
        var alertController = UIAlertController(title: "Instapaper", message: "Please enter your Instapaper user name and password.", preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "User Name"
            textField.keyboardType = .EmailAddress
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }
        alertController.addAction(cancelAction)
        
        let signinAction = UIAlertAction(title: "Sign-in", style: .Default){ (action) in
            
            let username = (alertController.textFields![0] as! UITextField).text
            let password = (alertController.textFields![1] as! UITextField).text
            
            ReadItLaterManager.sharedInstance.authToInstapepr(username, password: password, completion: { isSuccess in
                let alertTitle:String
                let buttonTitle:String
                if(isSuccess){
                    alertTitle = "Successfully sign-in"
                    buttonTitle = "OK"
                }else{
                    alertTitle = "Sign-in failed"
                    buttonTitle = "Retry"
                }
                
                var dialogController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .Alert)
                
                let actionButton = UIAlertAction(title: buttonTitle, style: .Default) {
                    action in
                    if(!isSuccess){
                        self.presentViewController(self.createInstapaperSignInDialog(), animated: true) { () -> Void in
                            
                        }
                    }
                }
                
                // addActionした順に左から右にボタンが配置されます
                dialogController.addAction(actionButton)
                
                self.presentViewController(dialogController, animated: true, completion: nil)
                
            })
        }
        
        alertController.addAction(signinAction)
        
        return alertController
    }
    
    /*
    @IBAction func syncTapped(sender: AnyObject) {
        LibFeedlyManager.sharedInstance.getNewItems({ _error in
            println(_error)
        })
    }
    
    

    @IBAction func alchemyTapped(sender: AnyObject) {
        AlchemyManager.sharedInstance.getExtractedTextWithUrl("",nil)
    }
*/
}

