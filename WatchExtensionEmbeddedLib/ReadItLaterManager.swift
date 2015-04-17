//
//  ReadItLaterManager.swift
//  watchtest
//
//  Created by Ukai Yu on 4/12/15.
//  Copyright (c) 2015 Ukai Yu. All rights reserved.
//

import Foundation
import SafariServices
import SwiftyJSON
import Alamofire
import KeychainAccess
//import PocketAPI

private let _RILManagerSharedInstance = ReadItLaterManager()

public class ReadItLaterManager{
    private let suiteName = "group.jp.ukai.watchtest"
    private let keychainGroup = "jp.ukay.Feetch"
    
    public static let pocketConsumerKey = "40025-e877b96ee7cfddacc58b8330"
    let instapaperAuthEndpoint = "https://www.instapaper.com/api/authenticate?"
    let instapaperAddEndpoint = "https://www.instapaper.com/api/add?"
    
    public class var sharedInstance: ReadItLaterManager {
        return _RILManagerSharedInstance
    }
    
    public enum KeyForKeychain:String{
        case InstapaperUsername = "InstapaperUserName"
        case InstapaperPassword = "InstapaperPassword"
    }
    
    public enum KeyForUserDefault:String{
        case SelectedReadItLaterService = "SelectedReadItLaterService"
    }
    
    public enum ReadItLaterServices: String{
        case Safari = "Safari"
        case Instapaper = "Instapaper"
        case Pocket = "Pocket"
        
        public static let allValues = [Safari, Instapaper, Pocket]
    }
    
    public func addEntryToReadItLater(entryId:String, target:String?){
        let service:String
        if let target = target {
            service = target
        }else{
            service = retrieveUserDefaultsWithKey(.SelectedReadItLaterService)!
        }
        
        switch service{
        case ReadItLaterServices.Safari.rawValue:
            addEntryToReadingList(entryId)
        case ReadItLaterServices.Instapaper.rawValue:
            addEntryToInstapaper(entryId, completion: nil)
        default:
            println("pocket")
        }
    }
    
    //This method must be called only after authentication
    public func addEntryToInstapaper(entryId:String, completion: ((isSuccess:Bool) -> Void)?){
        let username = retrieveKeychainWithKey(.InstapaperUsername)!
        let password = retrieveKeychainWithKey(.InstapaperPassword)!
        let predicate = NSPredicate(format: "id = %@", entryId)
        if let item = Item.objectsWithPredicate(predicate).firstObject() as! Item?{
            let instapaperRequest = postInstapaperRequestForAdd(item.url, username: username, password: password)
        
            Alamofire.request(instapaperRequest).responseJSON{ (request, response, JSONdata, error) in
                if let response = response {
                    switch (response.statusCode){
                    case 201:
                        completion?(isSuccess: true)
                    case 403:
                        completion?(isSuccess: false)
                    default:
                        completion?(isSuccess: false)
                    }
                }
            }
        }
    }
    
    public func authToInstapepr(username:String, password:String, completion: ((isSuccess:Bool) -> Void)?){
        let instapaperRequest = postInstapaperRequestForAuth(username, password: password)
        
        Alamofire.request(instapaperRequest).responseJSON{ (request, response, JSONdata, error) in
            if let response = response {
                switch (response.statusCode){
                case 200:
                    self.saveKeychainWithKey(.InstapaperUsername, value: username)
                    self.saveKeychainWithKey(.InstapaperPassword, value: password)
                    completion?(isSuccess: true)
                case 403:
                    completion?(isSuccess: false)
                default:
                    completion?(isSuccess: false)
                }
            }
        }
    }
    
    
    func postInstapaperRequestForAdd(url: String, username:String, password:String) -> NSMutableURLRequest {
        let requestUrl = NSURL(string: instapaperAddEndpoint +
                                "username=" + username +
                                "&password=" + password +
                                "&url=" + url)!
        let mutableURLRequest = NSMutableURLRequest(URL: requestUrl)
        mutableURLRequest.HTTPMethod = "POST"
        var JSONSerializationError: NSError? = nil
        return mutableURLRequest
    }
    
    func postInstapaperRequestForAuth(username:String, password:String) -> NSMutableURLRequest {
        let requestUrl = NSURL(string: instapaperAuthEndpoint +
            "username=" + username +
            "&password=" + password)!
        let mutableURLRequest = NSMutableURLRequest(URL: requestUrl)
        mutableURLRequest.HTTPMethod = "POST"
        var JSONSerializationError: NSError? = nil
        return mutableURLRequest
    }
    
    func addEntryToReadingList(entryId:String){
        let predicate = NSPredicate(format: "id = %@", entryId)
        if let item = Item.objectsWithPredicate(predicate).firstObject() as! Item? {
            var error : NSError?
            AlchemyManager.sharedInstance.getExtractedTextWithUrl(item.url , completion: { resultText in
                if (SSReadingList.defaultReadingList().addReadingListItemWithURL(NSURL(string:item.url), title: item.title, previewText: resultText, error: &error)){
                    println("\(item.title) is properly added")
                }else{
                    println("Fail to add")
                }
            })
        }
    }
    
    func saveKeychainWithKey(key: KeyForKeychain, value: String?){
        let keychain = Keychain(service: suiteName, accessGroup:keychainGroup)
        keychain[key.rawValue] = value
    }
    
    func retrieveKeychainWithKey(key: KeyForKeychain) -> String?{
        let keychain = Keychain(service: suiteName, accessGroup:keychainGroup)
        return keychain[key.rawValue]
    }
    
    public func removeToken(){
        saveKeychainWithKey(KeyForKeychain.InstapaperPassword, value: nil)
        saveKeychainWithKey(KeyForKeychain.InstapaperUsername, value: nil)
    }
    
    public func saveUserDefaultsWithKey(key:KeyForUserDefault, value:String){
        let defaults = NSUserDefaults(suiteName: suiteName)
        defaults?.setObject(value, forKey: key.rawValue)
        if(defaults?.synchronize() == true){
            println("The value \(value) is saved with the key \(key)")
        }else{
            println("The value \(value) is failed to save with the key \(key)")
        }
    }
    
    public func retrieveUserDefaultsWithKey(key:KeyForUserDefault) -> String? {
        let defaults = NSUserDefaults(suiteName: suiteName)
        let value = defaults?.objectForKey(key.rawValue) as! String?
        println("\(value) is retrieved")
        return value
    }
}