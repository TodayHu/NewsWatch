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
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //LibFeedlyManager.sharedInstance.removeToken()
        //ReadItLaterManager.sharedInstance.removeToken()
        if LibFeedlyManager.sharedInstance.isUserHasValidToken(){
            let storyboard = self.window?.rootViewController?.storyboard
            let tableViewController = storyboard?.instantiateViewControllerWithIdentifier("navigationView") as! UINavigationController
            window?.rootViewController = tableViewController
            window?.makeKeyAndVisible()
        }
        
        initMixPanel()
        
        return true
    }
    
    func initMixPanel(){
        Mixpanel.sharedInstanceWithToken("aedd7436b52f12a6eb1f783305ba89ff")
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
        /*if(!LibFeedlyManager.sharedInstance.isUserHasValidToken()){
        
        }*/
        
        let action = userInfo["action"] as! String
        if(action == "update"){
            LibFeedlyManager.sharedInstance.getNewItems({ _error in
                if let error = _error {
                    if error.domain == LibFeedlyManager.errorDomain.NoNetwork.rawValue{
                        self.returnWarningMessage(reply, warningMessage: error.localizedDescription)
                        return
                    }else if error.domain == LibFeedlyManager.errorDomain.NoToken.rawValue{
                        self.returnErrorMessage(reply, errorMessage: error.localizedDescription)
                        return
                    }
                }
                
                var returnResult = ["response" : "success"]
                reply(returnResult)
            })
        }else if(action == "markAsRead"){
            let entryId = userInfo["entryId"] as! String
            LibFeedlyManager.sharedInstance.makeEntryAsRead(entryId, completion: { _error in
                if let error = _error {
                    if error.domain == LibFeedlyManager.errorDomain.NoNetwork.rawValue{
                        self.returnWarningMessage(reply, warningMessage: error.localizedDescription)
                        return
                    }else if error.domain == LibFeedlyManager.errorDomain.NoToken.rawValue{
                        self.returnErrorMessage(reply, errorMessage: error.localizedDescription)
                        return
                    }
                }
                
                var returnResult = ["response" : "success","message": "\(entryId) is marked as read"]
                reply(returnResult)

            })
            
        }else if(action == "getContent"){
            let entryId = userInfo["entryId"] as! String
            SpeedReadingManager.convertStringToArrayWithLocal(entryId, completion: { _error, _result in
                let resultArray = _result as Array<String>
                let resultDic = ["response" : "success","data":resultArray]
                println(resultDic)
                reply(resultDic as [NSObject : AnyObject])
            })
        }
    }
    
    func returnWarningMessage(reply:(([NSObject : AnyObject]!) -> Void), warningMessage : String){
        var returnResult : [String:AnyObject] = ["response":"warning","message":warningMessage]
        reply(returnResult)
    }
    
    func returnErrorMessage(reply:(([NSObject : AnyObject]!) -> Void), errorMessage : String){
        var returnResult : [String:AnyObject] = ["response":"error","message":errorMessage]
        reply(returnResult)
    }
}

