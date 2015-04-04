//
//  LibFeedlyManager.swift
//  watchtest
//
//  Created by Ukai Yu on 3/29/15.
//  Copyright (c) 2015 Ukai Yu. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Realm
import IJReachability

private let _FeedlyManagerSharedInstance = LibFeedlyManager()
private let feedlyPrefix = "http://sandbox.feedly.com/v3"
private let suiteName = "group.jp.ukai.watchtest"



public class LibFeedlyManager {
    
    public enum errorDomain:String{
        case NoNetwork = "jp.ukay.network"
        case NoToken = "jp.ukay.auth"
    }
    public enum networkError : Int{
        case NoNetwork
        case NoToken
    }
    
    init(){
        let container = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(suiteName)
        let realmUrl = container?.URLByAppendingPathComponent("default.realm")
        RLMRealm.setDefaultRealmPath(realmUrl?.path)
        migration()
    }
    
    func migration(){
        RLMRealm.setSchemaVersion(2, forRealmAtPath: RLMRealm.defaultRealmPath(),
            withMigrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion < 2 {
                    println("migrated")
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
    }
    
    public class var sharedInstance: LibFeedlyManager {
        return _FeedlyManagerSharedInstance
    }
    
    public struct UserDefaultsKeys {
        public static let access_token = "access_token"
        public static let userId = "userId"
    }
    
    public func getFeedlyRequest(url: String) -> NSMutableURLRequest {
        return getFeedlyRequestWithParams(url, params: nil)
    }
    
    public func getFeedlyRequestWithParams(url: String, params:NSDictionary?) -> NSMutableURLRequest{
        let access_token = retrieveUserDefaultsWithKey(UserDefaultsKeys.access_token)
        
        let URL = NSURL(string: feedlyPrefix + url)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "GET"
        if let paramDic = params{
            mutableURLRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(paramDic, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
            mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        var JSONSerializationError: NSError? = nil
        mutableURLRequest.setValue(access_token, forHTTPHeaderField: "Authorization")
        return mutableURLRequest
    }
    
    public func postFeedlyRequest(url: String, params:NSDictionary) -> NSMutableURLRequest {
        let access_token = retrieveUserDefaultsWithKey(UserDefaultsKeys.access_token)
        
        let URL = NSURL(string: feedlyPrefix + url)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        var JSONSerializationError: NSError? = nil
        mutableURLRequest.setValue(access_token, forHTTPHeaderField: "Authorization")
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return mutableURLRequest
    }
    
    public func retrieveUserDefaultsWithKey(key:String) -> String? {
        let defaults = NSUserDefaults(suiteName: suiteName)
        let value = defaults?.objectForKey(key) as String?
        println("\(value) is retrieved")
        return value
    }
    
    public func getNewItems(completion:((error:NSError?)->Void)?){
        
        if !IJReachability.isConnectedToNetwork(){
            let errorDic = [NSLocalizedDescriptionKey:"No Network Error by library"]
            var noNetworkError = NSError(domain: errorDomain.NoNetwork.rawValue, code: networkError.NoNetwork.rawValue, userInfo: errorDic)
            //let noNetworkErrorPtr = NSErrorPointer(
            completion?(error: noNetworkError)
        }
        
        if let userId = self.retrieveUserDefaultsWithKey(UserDefaultsKeys.userId){
            
            var requestUrl = "/streams/contents?streamId=user/" + userId + "/category/global.all&unreadOnly=true"
            if let items = Item.allObjects() {
                if(items.count>0){
                    let latestItem = items.sortedResultsUsingProperty("publishedAt", ascending: false)[0] as? Item
                    let newerThan = "&newerThan=" + String(latestItem!.publishedAt + 1)
                    requestUrl += newerThan
                }
            }
            println("requesturl: \(requestUrl)")
            var streamRequest = getFeedlyRequest(requestUrl)
            
            // Get the default Realm
            let realm = RLMRealm.defaultRealm()
            
            Alamofire.request(streamRequest).responseJSON{ (request, response, JSONdata, error) in
                //if we got error
                if let error = error{
                    completion?(error: error)
                    return
                }
                
                var result:JSON = JSON(JSONdata!)
                println(result)
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
                    item.url = result["items"][i]["originId"].string!
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
                completion?(error: nil)
            }
        }else{
            let errorDic = [NSLocalizedDescriptionKey:"please launch iOS app in advance to sign-in"]
            var noNetworkError = NSError(domain: errorDomain.NoToken.rawValue, code: networkError.NoToken.rawValue, userInfo: errorDic)
            //let noNetworkErrorPtr = NSErrorPointer(
            completion?(error: noNetworkError)
        }
    }
    
    public func getItems() -> RLMResults{
        let items = Item.allObjects().sortedResultsUsingProperty("publishedAt", ascending: false)
        return items
    }
    
    public func saveUserDefaultsWithKey(key:String, value:String){
        let defaults = NSUserDefaults(suiteName: suiteName)
        defaults?.setObject(value, forKey: key)
        if(defaults?.synchronize() == true){
            println("The value \(value) is saved with the key \(key)")
        }else{
            println("The value \(value) is failed to save with the key \(key)")
        }
    }
    
    public func isUserHasValidToken() -> Bool{
        if let token = retrieveUserDefaultsWithKey(UserDefaultsKeys.access_token) {
            return true
        }
        return false
    }
    
}
