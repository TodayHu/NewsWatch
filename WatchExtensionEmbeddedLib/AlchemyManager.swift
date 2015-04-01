//
//  AlchemyManager.swift
//  watchtest
//
//  Created by Ukai Yu on 4/1/15.
//  Copyright (c) 2015 Ukai Yu. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Realm

private let _AlchemyManagerSharedInstance = AlchemyManager()

public class AlchemyManager{
    let apiurl = "http://access.alchemyapi.com/calls/url/URLGetText?"
    let apikey = "apikey=0ab2b6ea280a3c61a247a23f2363d3c89cd95f0d"
    let useMetadata = "&useMetadata=0"
    let extractLinks = "&extractLinks=0"
    let outputMode = "&outputMode=json"
    let sourceText = "&sourceText=cleaned"
    let urlText = "&url="
    
    public class var sharedInstance: AlchemyManager {
        return _AlchemyManagerSharedInstance
    }
    
    
    public func getAlchemyRequestWithParams(targetUrl: String) -> NSMutableURLRequest{
        let URL = NSURL(string: apiurl + apikey + useMetadata + extractLinks + outputMode + sourceText + urlText + targetUrl)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = "GET"
        return mutableURLRequest
    }
    
    public func getExtractedTextWithUrl(targetUrl: String, completion:((String)->Void)?){
        var markRequest = getAlchemyRequestWithParams(targetUrl)
        
        Alamofire.request(markRequest).responseJSON{ (request, response, JSONdata, error) in
            let result = JSON(JSONdata!)
            completion!(result["text"].string!)
        }
    }
    
}