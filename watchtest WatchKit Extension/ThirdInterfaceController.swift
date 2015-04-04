//
//  InterfaceController.swift
//  watchtest WatchKit Extension
//
//  Created by Ukai Yu on 3/22/15.
//  Copyright (c) 2015 Ukai Yu. All rights reserved.
//

import WatchKit
import Foundation
import SwiftyJSON
import Realm
import WatchExtensionEmbeddedLib

class ThirdInterfaceController: WKInterfaceController {
    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var publisherLabel: WKInterfaceLabel!
    @IBOutlet weak var actionButton: WKInterfaceButton!
    
    
    var arrayOfText:Array<String> = []
    var current = 0
    var timer: NSTimer?
    let timerDuration: NSTimeInterval = 0.2
    
    override init() {
        
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        label.setText("")
        
        if let id = context as String? {
            let realm = RLMRealm.defaultRealm()
            let predicate = NSPredicate(format: "id = %@", id)
            if let item = Item.objectsWithPredicate(predicate).firstObject() as Item? {
                AlchemyManager.sharedInstance.getExtractedTextWithUrl(item.url, completion: { resultText in
                    self.arrayOfText = split(resultText) {$0 == " "}
                    self.label.setText(self.arrayOfText[self.current])
                    
                    
                })
            }
        }
    }
    
    @IBAction func actionTapped() {
        if let _timer = timer {
            _timer.invalidate()
            timer = nil
            actionButton.setTitle("Play")
        }else{
            timer = NSTimer.scheduledTimerWithTimeInterval(self.timerDuration, target: self, selector: Selector("timerCalled"), userInfo: nil, repeats: true)
            actionButton.setTitle("Stop")
        }
    }
    
    func timerCalled(){
        current++
        label.setText(self.arrayOfText[current])
        println("timerCalled \(current)")
    }
    
    func configureItems(){

    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
