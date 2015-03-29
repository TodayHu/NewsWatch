//
//  FeedlyManager.swift
//  watchtest
//
//  Created by Ukai Yu on 3/28/15.
//  Copyright (c) 2015 Ukai Yu. All rights reserved.
//

import Foundation

private let _FeedlyManagerSharedInstance = FeedlyManager()
private let feedlyPrefix = "http://sandbox.feedly.com/v3"
private let suiteName = "group.jp.ukay.watchtest"

class FeedlyManager {
    
    class var sharedInstance: FeedlyManager {
        return _FeedlyManagerSharedInstance
    }
    
    internal struct UserDefaultsKeys {
        static let access_token = "access_token"
        static let userId = "userId"
    }

    func getFeedlyRequest(url: String) -> NSMutableURLRequest {
        let access_token = retrieveUserDefaultsWithKey(UserDefaultsKeys.access_token)
        
        let URL = NSURL(string: feedlyPrefix + url)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "GET"
        var JSONSerializationError: NSError? = nil
        mutableURLRequest.setValue(access_token, forHTTPHeaderField: "Authorization")
        return mutableURLRequest
    }
    
    func postFeedlyRequest(url: String, params:NSDictionary) -> NSMutableURLRequest {
        let access_token = retrieveUserDefaultsWithKey(UserDefaultsKeys.access_token)
        
        let URL = NSURL(string: feedlyPrefix + url)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
    
        mutableURLRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        var JSONSerializationError: NSError? = nil
        mutableURLRequest.setValue(access_token, forHTTPHeaderField: "Authorization")
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return mutableURLRequest
    }
    
    func retrieveUserDefaultsWithKey(key:String) -> String {
        let defaults = NSUserDefaults(suiteName: suiteName)
        let value = defaults?.objectForKey(key) as String
        println("\(value) is retrieved")
        return value
    }
    
    func saveUserDefaultsWithKey(key:String, value:String){
        let defaults = NSUserDefaults(suiteName: suiteName)
        defaults?.setObject(value, forKey: key)
        if(defaults?.synchronize() == true){
            println("The value \(value) is saved with the key \(key)")
        }else{
            println("The value \(value) is failed to save with the key \(key)")
        }
    }
}