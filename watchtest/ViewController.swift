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
        oauthswift.webViewController = webController! as FeedlyViewController
        oauthswift.authorizeWithCallbackURL( NSURL(string: "http://localhost")!, scope: "https://cloud.feedly.com/subscriptions", state: "Feedly", success: {
                credential, response in
            LibFeedlyManager.sharedInstance.saveUserDefaultsWithKey(LibFeedlyManager.UserDefaultsKeys.access_token, value: credential.oauth_token)
                //self.getProfile()
                }, failure: { error in
                    println("error")
            })
    }
    
    @IBAction func signInTapped(recognizer:UITapGestureRecognizer){
        feedlyTapped()
    }
    
    /*
    @IBAction func syncTapped(sender: AnyObject) {
        LibFeedlyManager.sharedInstance.getNewItems({ _error in
            println(_error)
        })
    }
    
    func getProfile(){
        let request = LibFeedlyManager.sharedInstance.getFeedlyRequest("/profile")
        
        Alamofire.request(request).responseJSON{
            (request, response, JSONdata, error) in
            var result = JSON(JSONdata!)
            LibFeedlyManager.sharedInstance.saveUserDefaultsWithKey(LibFeedlyManager.UserDefaultsKeys.userId, value: result["id"].string!)
        }
    }

    @IBAction func alchemyTapped(sender: AnyObject) {
        AlchemyManager.sharedInstance.getExtractedTextWithUrl("",nil)
    }
*/
}

