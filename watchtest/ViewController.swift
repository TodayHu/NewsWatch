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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //println(LibFeedlyManager.sharedInstance.getItem().title)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func feedlyTapped(sender: AnyObject) {
    
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
                self.getProfile()
                }, failure: { error in
                    println("error")
            })
    }

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
}

