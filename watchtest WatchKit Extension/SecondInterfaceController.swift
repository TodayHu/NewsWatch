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

class SecondInterfaceController: WKInterfaceController {
 
    @IBOutlet weak var myTable: WKInterfaceTable!

    var array:JSON = nil
    
    override init() {
        super.init()
        
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        let dic = ["user":"ukkaripon"]
        WKInterfaceController.openParentApplication(dic, reply: { (replyInfo, error) -> Void in
            let result = JSON (replyInfo)
            self.array = result
        })
        
    }
    
    func configureItems(){
        for var i = 0; i < array["data"].count; i++ {
            let row = myTable.rowControllerAtIndex(i) as MainRowType
            row.rowDescription.setText(array["data"][i]["english"].string)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        myTable.setNumberOfRows(array["data"].count, withRowType: "rowIndentifier")
        
        configureItems()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        println("tapped")
        self.presentControllerWithName("DetailController", context: array["data"][rowIndex]["english"].string)
    }
    
}
