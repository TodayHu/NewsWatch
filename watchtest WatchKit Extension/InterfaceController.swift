//
//  InterfaceController.swift
//  watchtest WatchKit Extension
//
//  Created by Ukai Yu on 3/22/15.
//  Copyright (c) 2015 Ukai Yu. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var label: WKInterfaceLabel!
    
    override init() {
        
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        label.setText("test")
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func noButtonTapped(sender:UIButton) {
        let dic = ["keyword":"No"]
        let initialPhrases = ["Let's do a lunch", "Can we meet tomorrow"]
        presentTextInputControllerWithSuggestions(initialPhrases, allowedInputMode: WKTextInputMode.Plain) { (result) -> Void in
            if( result?.count > 0 ){
                println(result[0] as String)
            }
        }
        /*
        WKInterfaceController.openParentApplication(dic, reply: { (replyInfo, error) -> Void in
            //println(replyInfo["return"])
            self.label.setText(replyInfo["return"] as? String)
        })
        */
        /*label.setText("tapped")
        var timer = NSTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateByTimer"), userInfo: nil, repeats: false)*/
        
    }
    
    func updateByTimer() {
        label.setText("text")
    }
}
