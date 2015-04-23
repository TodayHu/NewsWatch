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
    
    @IBOutlet weak var wpmLabel: WKInterfaceLabel!
    @IBOutlet weak var actionButton: WKInterfaceButton!
    
    
    var arrayOfText:Array<String> = []
    var current = 0
    var entryId:String = ""
    var timer: NSTimer?
    var timerDuration: NSTimeInterval = 0.2
    
    
    override init() {
        
    }
    
    //EntryId is given as String from InterfaceController
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        setWPM()
        
        label.setText("")
        
        if let id = context as! String? {
            let dic = ["action":"getContent","entryId":id]
            WKInterfaceController.openParentApplication(dic, reply: { (replyInfo, error) -> Void in
                let result = JSON (replyInfo)
                println(result)
                self.arrayOfText =  result["data"].rawValue as! Array<String>
                self.label.setText(self.arrayOfText[self.current])
            })
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
    @IBAction func saveTapped() {
        ReadItLaterManager.sharedInstance.addEntryToReadItLater(entryId, target: "Safari")
        if let _timer = timer {
            _timer.invalidate()
            timer = nil
            actionButton.setTitle("Play")
        }
    }
    
    func timerCalled(){
        current++
        if(current >= arrayOfText.count){
            if let _timer = timer {
                _timer.invalidate()
                timer = nil
            }
            actionButton.setTitle("Play")
        }else{
            label.setText(self.arrayOfText[current])
            println("timerCalled \(current)")
        }
    }
    
    func configureItems(){

    }
    
    func setWPM(){
        let value = 60.0/timerDuration
        wpmLabel.setText("\(value)WPM")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func settingTapped() {
        self.presentControllerWithName("SettingController", context: nil)
    }
}
