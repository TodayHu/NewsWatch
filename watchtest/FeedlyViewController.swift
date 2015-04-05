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
    let heightOfNavigationBar:CGFloat = 44
    
    var authUrl:NSURL?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        webView.loadRequest(NSURLRequest(URL: authUrl!))
        webView.delegate = self
        println("viewDidLoad()")
        
        let heightOfStatusBar = UIApplication.sharedApplication().statusBarFrame.size.height
        var navigationBar = UINavigationBar(frame: CGRect(origin: CGPointZero, size: CGSize(width: self.view.frame.size.width,height: heightOfNavigationBar + heightOfStatusBar)))
        let closeBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("closeTapped:"))
        var navigationItem = UINavigationItem(title: "Sign in with feedly")
        navigationItem.rightBarButtonItem = closeBarButton
        navigationBar.items = [navigationItem]
        view.addSubview(navigationBar)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let heightOfStatusBar = UIApplication.sharedApplication().statusBarFrame.size.height
        var frame = webView.frame
        frame.origin.y += heightOfNavigationBar + heightOfStatusBar
        frame.size.height -= heightOfNavigationBar + heightOfStatusBar
        webView.frame = frame
    }
    
    func closeTapped(sender:UIBarButtonItem){
        dismissViewControllerAnimated(true, completion: nil)
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
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
