//
//  AppDelegate.swift
//  watchtest
//
//  Created by Ukai Yu on 3/22/15.
//  Copyright (c) 2015 Ukai Yu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import OAuthSwift
import WatchExtensionEmbeddedLib
import Realm

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        // Override point for customization after application launch.
        if (url.host == "oauth-callback") {
            if ( url.path!.hasPrefix("/feedly" )){
                OAuth2Swift.handleOpenURL(url)
            }
        }
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication!, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]!, reply: (([NSObject : AnyObject]!) -> Void)!) {
        // Called when WatchKit application invokes
        // Check if the user has already had valid access token
        if(!LibFeedlyManager.sharedInstance.isUserHasValidToken()){
            returnErrorMessage(reply)
        }
        
        let action = userInfo["action"] as String
        if(action == "update"){
            LibFeedlyManager.sharedInstance.getNewItems({ message in
                var returnResult = ["response" : "success"]
                reply(returnResult)
            })
            
            // Check if the userId has been logged in UserDefaults
            /*if let userId = FeedlyManager.sharedInstance.retrieveUserDefaultsWithKey(FeedlyManager.UserDefaultsKeys.userId){
                var streamRequest = FeedlyManager.sharedInstance.getFeedlyRequest("/streams/contents?streamId=user/" + userId + "/category/global.all&unreadOnly=true")
                Alamofire.request(streamRequest).responseJSON{ (request, response, JSONdata, error) in
                    var result:JSON = JSON(JSONdata!)
                    println(result)
                    var returnResult : [String:AnyObject] = ["response":"success","data":result.rawValue]
                    reply(returnResult)
                }
            }else{
                returnErrorMessage(reply)
            }*/
        }else if(action == "markAsRead"){
            let entry = userInfo["entryId"] as String
            var entries:Array = [entry]
            var param = ["type":"entries","action":"markAsRead","entryIds":entries]
            var markRequest = LibFeedlyManager.sharedInstance.postFeedlyRequest("/markers" , params: param)
            
            Alamofire.request(markRequest).responseJSON{ (request, response, JSONdata, error) in
                var returnResult = ["response" : response?.statusCode as Int!]
                if(response?.statusCode == 200){
                    
                    let predicate = NSPredicate(format: "id = %@", entry)
                    if(Item.objectsWithPredicate(predicate).count != 0){
                        let item = Item.objectsWithPredicate(predicate).firstObject() as Item!
                        let realm = RLMRealm.defaultRealm()
                        realm.beginWriteTransaction()
                        item.isUnread = false
                        realm.commitWriteTransaction()
                    }
                }
                
                reply(returnResult)
            }
        }
    }
    
    func returnErrorMessage(reply:(([NSObject : AnyObject]!) -> Void)){
        var returnResult : [String:AnyObject] = ["response":"error"]
        reply(returnResult)
    }
}

