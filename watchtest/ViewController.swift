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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        RLMRealm.setSchemaVersion(4, forRealmAtPath: RLMRealm.defaultRealmPath(),
            withMigrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion < 4 {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
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
            FeedlyManager.sharedInstance.saveUserDefaultsWithKey(FeedlyManager.UserDefaultsKeys.access_token, value: credential.oauth_token)
                self.getProfile()
                }, failure: { error in
                    println("error")
            })
    }

    @IBAction func syncTapped(sender: AnyObject) {
        FeedlyManager.sharedInstance.getNewItems()
        /*
        if let userId = FeedlyManager.sharedInstance.retrieveUserDefaultsWithKey(FeedlyManager.UserDefaultsKeys.userId){
            
            var requestUrl = "/streams/contents?streamId=user/" + userId + "/category/global.all&unreadOnly=true"
            if let items = Item.allObjects() {
                if(items.count>0){
                    let latestItem = items.sortedResultsUsingProperty("publishedAt", ascending: false)[0] as? Item
                    let newerThan = "&newerThan=" + String(latestItem!.publishedAt + 1)
                    requestUrl += newerThan
                }
            }
            println("requesturl: \(requestUrl)")
            var streamRequest = FeedlyManager.sharedInstance.getFeedlyRequest(requestUrl)
            
            // Get the default Realm
            let realm = RLMRealm.defaultRealm()
            
            Alamofire.request(streamRequest).responseJSON{ (request, response, JSONdata, error) in
                var result:JSON = JSON(JSONdata!)
                let numOfItem = result["items"].count
                println("retrieved \(numOfItem) items")
                var numOfSaved = 0
                for var i = 0 ; i < result["items"].count; i++ {
                    let item = Item()
                    item.id = result["items"][i]["id"].string!
                    
                    //Check if the item has been saved
                    let predicate = NSPredicate(format: "id = %@", item.id)
                    if(Item.objectsWithPredicate(predicate).count != 0){
                        break
                    }
                    
                    item.title = result["items"][i]["title"].string!
                    item.publisherName = result["items"][i]["origin"]["title"].string!
                    item.isUnread = true
                    item.publishedAt = result["items"][i]["published"].int!
                    if let content = result["items"][i]["content"]["content"].string {
                        item.content = content
                    }
                    // Add to the Realm inside a transaction
                    realm.beginWriteTransaction()
                    realm.addObject(item)
                    realm.commitWriteTransaction()
                    numOfSaved++
                }
                println("saved \(numOfSaved) items")
            }
        }else{
            
        }*/
    }
    
    func getProfile(){
        let request = FeedlyManager.sharedInstance.getFeedlyRequest("/profile")
        
        Alamofire.request(request).responseJSON{
            (request, response, JSONdata, error) in
            var result = JSON(JSONdata!)
            FeedlyManager.sharedInstance.saveUserDefaultsWithKey(FeedlyManager.UserDefaultsKeys.userId, value: result["id"].string!)
        }
    }

}

