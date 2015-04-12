//
//  SettingInterfaceController.swift
//  watchtest
//
//  Created by Ukai Yu on 4/4/15.
//  Copyright (c) 2015 Ukai Yu. All rights reserved.
//

import Foundation
import WatchKit

class SettingInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var slider: WKInterfaceSlider!
    @IBOutlet weak var mainLabel: WKInterfaceLabel!
    @IBOutlet weak var wpmLabel: WKInterfaceLabel!
    @IBOutlet weak var actionButton: WKInterfaceButton!
    
    private let suiteName = "group.jp.ukai.watchtest"
    
    let defaultWpm = 200
    var current = 0
    var arrayOfText:Array<String> = []
    let dummyText = "Far far away, behind the word mountains, far from the countries Vokalia and Consonantia, there live the blind texts. Separated they live in Bookmarksgrove right at the coast of the Semantics, a large language ocean. A small river named Duden flows by their place and supplies it with the necessary regelialia. It is a paradisematic country, in which roasted parts of sentences fly into your mouth. Even the all-powerful Pointing has no control about the blind texts it is an almost unorthographic life One day however a small line of blind text by the name of Lorem Ipsum decided to leave for the far World of Grammar. The Big Oxmox advised her not to do so, because there were thousands of bad Commas, wild Question Marks and devious Semikoli, but the Little Blind Text didn’t listen. She packed her seven versalia, put her initial into the belt and made herself on the way. When she reached the first hills of the Italic Mountains, she had a last view back on the skyline of her hometown Bookmarksgrove, the headline of Alphabet Village and the subline of her own road, the Line Lane. Pityful a rethoric question ran over her cheek, then"
    var timer: NSTimer?
    var timerDuration: NSTimeInterval?
    
    override init() {
        
    }
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        arrayOfText = split(dummyText) {$0 == " "}
        mainLabel.setText(arrayOfText[current])
        
        let defaults = NSUserDefaults(suiteName: suiteName)
        var wpm = 0
        if let value = defaults?.objectForKey("wpm") as! Int? {
            wpm = value
        }else{
            defaults?.setObject(defaultWpm, forKey: "wpm")
            wpm = defaultWpm
            println("save \(defaultWpm) as default wpm")
        }
        
        slider.setValue(Float(wpm))
        wpmLabel.setText("\(wpm)WPM")
        timerDuration = 60.0/Double(wpm)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    @IBAction func sliderChanged(value: Float) {
        let defaults = NSUserDefaults(suiteName: suiteName)
        defaults?.setObject(Int(value), forKey: "wpm")
        wpmLabel.setText("\(Int(value))WPM")
        timerDuration = 60.0/Double(value)
    }
    @IBAction func actionButtonTapped() {
        if let _timer = timer {
            _timer.invalidate()
            timer = nil
            actionButton.setTitle("Play")
        }else{
            timer = NSTimer.scheduledTimerWithTimeInterval(timerDuration!, target: self, selector: Selector("timerCalled"), userInfo: nil, repeats: true)
            actionButton.setTitle("Stop")
        }
    }
    
    func timerCalled(){
        current++
        mainLabel.setText(self.arrayOfText[current])
        println("timerCalled \(current)")
    }
    
}