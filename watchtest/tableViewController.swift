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
import Mixpanel

class tableViewController:UITableViewController{
    let TableViewCellIdentifier:String = "CELL"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Feetch"
        
        //LibFeedlyManager.sharedInstance.removeToken()
        //ReadItLaterManager.sharedInstance.removeToken()
        Mixpanel.sharedInstance().track("Launch")
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
            if ReadItLaterManager.ReadItLaterServices.allValues[indexPath.row].rawValue == ReadItLaterManager.ReadItLaterServices.Instapaper.rawValue {
                if ReadItLaterManager.sharedInstance.isSignedInInstapaper(){
                    ReadItLaterManager.sharedInstance.saveUserDefaultsWithKey(.SelectedReadItLaterService, value: ReadItLaterManager.ReadItLaterServices.allValues[indexPath.row].rawValue)
                    //tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
                }else{
                    presentInstapaperSignInDialog({
                        ReadItLaterManager.sharedInstance.saveUserDefaultsWithKey(.SelectedReadItLaterService, value: ReadItLaterManager.ReadItLaterServices.allValues[indexPath.row].rawValue)
                        //tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
                    }, failureHandler: {
                    
                    })
                }
            }else if ReadItLaterManager.ReadItLaterServices.allValues[indexPath.row].rawValue == ReadItLaterManager.ReadItLaterServices.Pocket.rawValue {
                //Pocket
            }else{
                ReadItLaterManager.sharedInstance.saveUserDefaultsWithKey(.SelectedReadItLaterService, value: ReadItLaterManager.ReadItLaterServices.allValues[indexPath.row].rawValue)
            }
            tableView.reloadData()
        }
    }
    
    func presentInstapaperSignInDialog(successHandler: (() -> Void)?, failureHandler: (() -> Void)?){
        var alertController = UIAlertController(title: "Instapaper", message: "Please enter your Instapaper user name and password.", preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "User Name"
            textField.keyboardType = .EmailAddress
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }
        alertController.addAction(cancelAction)
        
        let signinAction = UIAlertAction(title: "Sign-in", style: .Default){ (action) in
            
            let username = (alertController.textFields![0] as! UITextField).text
            let password = (alertController.textFields![1] as! UITextField).text
            
            ReadItLaterManager.sharedInstance.authToInstapepr(username, password: password, completion: { isSuccess in
                let alertTitle:String
                let buttonTitle:String
                
                if(isSuccess){
                    alertTitle = "Successfully sign-in"
                    buttonTitle = "OK"
                }else{
                    alertTitle = "Sign-in failed"
                    buttonTitle = "OK"
                }
                
                var dialogController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .Alert)
                
                let actionButton = UIAlertAction(title: buttonTitle, style: .Default) {
                    action in
                    if(isSuccess){
                        successHandler?()
                    }else{
                        failureHandler?()
                        /*self.presentViewController(self.createInstapaperSignInDialog(), animated: true) { () -> Void in
                            
                        }*/
                    }
                }
                
                dialogController.addAction(actionButton)
                
                self.presentViewController(dialogController, animated: true, completion: nil)
                
            })
        }
        
        alertController.addAction(signinAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
