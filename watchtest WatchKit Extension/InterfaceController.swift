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

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var yesButton: WKInterfaceButton!
    @IBOutlet weak var noButton: WKInterfaceButton!
    @IBOutlet weak var publisherLabel: WKInterfaceLabel!
    @IBOutlet weak var mainTable: WKInterfaceTable!
    var array:JSON = nil
    var current = -1
    
    override init() {
        
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        mainTable.setNumberOfRows(1, withRowType: "rowIdentifier")
        let dic = ["action":"update"]
        WKInterfaceController.openParentApplication(dic, reply: { (replyInfo, error) -> Void in
            let result = JSON (replyInfo)
            self.array = result
            self.setNextTitle()
            println(self.array)
        })
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func setNextTitle() {
        //Mark the entry as read if it's not first article
        if(current >= 0){
            markAsRead(self.array["data"]["items"][current]["id"].string!)
        }
        
        current++
        
        let row = mainTable.rowControllerAtIndex(0) as MainRowType
        row.mainLabel.setText(self.array["data"]["items"][current]["title"].string)
        self.publisherLabel.setText(self.array["data"]["items"][current]["origin"]["title"].string)
        
        
    }
    
    func markAsRead(entryId:String){
        let dic = ["action":"markAsRead","entryId":entryId]
        WKInterfaceController.openParentApplication(dic, reply: { (replyInfo, error) -> Void in
            let result = JSON (replyInfo)
            println(result)
        })
    }
    
    @IBAction func nextTapped() {
        setNextTitle()
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        println("tapped")
        self.pushControllerWithName("DetailController", context: self.array["data"]["items"][current].rawValue)
    }

}
