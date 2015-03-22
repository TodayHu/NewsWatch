//
//  InterfaceController.swift
//  watchtest WatchKit Extension
//
//  Created by Ukai Yu on 3/22/15.
//  Copyright (c) 2015 Ukai Yu. All rights reserved.
//

import WatchKit
import Foundation

class ThirdInterfaceController: WKInterfaceController {
    @IBOutlet weak var label: WKInterfaceLabel!
    
    override init() {
        
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        label.setText(context as? String)
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
    
    @IBAction func addButton() {
        label.setText("add")
    }
    @IBAction func playButton() {
        label.setText("play")
    }
}
