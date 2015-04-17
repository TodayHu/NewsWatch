//
//  tableViewController.swift
//  Feetch
//
//  Created by Ukai Yu on 4/12/15.
//  Copyright (c) 2015 Ukai Yu. All rights reserved.
//

import Foundation
import UIKit
import WatchExtensionEmbeddedLib

class tableViewController:UITableViewController{
    let TableViewCellIdentifier:String = "CELL"
    let listOfReadItLater = ["Reading list","Instapaper"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Feetch"
        //tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: TableViewCellIdentifier)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return ReadItLaterManager.ReadItLaterServices.allValues.count
        case 1:
            return 3
        default:
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return "Read it Later"
        case 1:
            return "test"
        default:
            return "test"
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifier , forIndexPath: indexPath) as? readItLaterTableViewCell
        
        switch indexPath.section{
        case 0:
            cell?.label?.text = ReadItLaterManager.ReadItLaterServices.allValues[indexPath.row].rawValue
            if let selectedService = ReadItLaterManager.sharedInstance.retrieveUserDefaultsWithKey(.SelectedReadItLaterService){
                if cell?.label?.text == selectedService {
                    cell?.accessoryType = .Checkmark
                }else{
                    cell?.accessoryType = .None
                }
            }else{
                if indexPath.row == 0 {
                    cell?.accessoryType = .Checkmark
                    ReadItLaterManager.sharedInstance.saveUserDefaultsWithKey(.SelectedReadItLaterService, value: ReadItLaterManager.ReadItLaterServices.allValues[indexPath.row].rawValue)
                }
            }
        case 1:
            cell?.label?.text = "test"
        default:
            cell?.label?.text = "test"
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            ReadItLaterManager.sharedInstance.saveUserDefaultsWithKey(.SelectedReadItLaterService, value: ReadItLaterManager.ReadItLaterServices.allValues[indexPath.row].rawValue)
            tableView.reloadData()
        }
    }
    /*
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
        }
    }*/
    
}
