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
    
    override init() {
        
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let id = context as String? {
            let realm = RLMRealm.defaultRealm()
            let predicate = NSPredicate(format: "id = %@", id)
            if let item = Item.objectsWithPredicate(predicate).firstObject() as Item? {
                AlchemyManager.sharedInstance.getExtractedTextWithUrl(item.url, completion: { resultText in
                    println(resultText)
                })
            }
        }
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
