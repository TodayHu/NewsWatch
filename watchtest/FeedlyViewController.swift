//
//  FeedlyViewController.swift
//  watchtest
//
//  Created by Ukai Yu on 3/28/15.
//  Copyright (c) 2015 Ukai Yu. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire
import SwiftyJSON

class FeedlyViewController: OAuthWebViewController, UIWebViewDelegate{
    @IBOutlet weak var webView: UIWebView!
    var authUrl:NSURL?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        webView.loadRequest(NSURLRequest(URL: authUrl!))
        webView.delegate = self
        println("viewDidLoad()")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func setUrl(url: NSURL) {
        authUrl = url
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if((webView.request?.URL.absoluteString?.hasPrefix("http://localhost")) == true){
            println("webViewDidFinishLoad: \(webView.request!)")
            let nc = NSNotificationCenter.defaultCenter()
            var userInfo = ["OAuthSwiftCallbackNotificationOptionsURLKey" : webView.request!.URL]
            nc.postNotificationName("OAuthSwiftCallbackNotificationName", object: self, userInfo: userInfo)
        }
    }
    
}
