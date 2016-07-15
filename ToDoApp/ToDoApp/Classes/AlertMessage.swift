//
//  AlertMessage.swift
//  ToDoApp
//
//  Created by Dennis Yaremenko on 7/12/16.
//  Copyright © 2016 Dennis Yaremenko. All rights reserved.
//

import UIKit

final class AlertMessage {
    
    enum Defaults {
        static let errorString = "Error"
        static let warningString = "Warning"
        
        static let successTitleString = "Success"
        static let successDescriptionString = "Note was successfully deleted"
        static let successRegistrationString = "Registration success. Check your email for verifiying"
        
        static let logoutTitleString = "Logout"
        static let logoutDescriptionString = "Do you really want to logout?"
        
        static let deleteTitleString = "Delete"
        static let deleteDescriptionString = "Do you really want to delete this item?"
        
    }
    
    class func showMessageWithHanlder(viewController: UIViewController, title: String?, message: String?, handler: (UIAlertAction -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: .Default, handler: handler)
        alertController.addAction(alertAction)
        viewController.presentViewController(alertController, animated: true, completion: nil)
        alertController.view.tintColor = UIColor.blackColor()
    }
    
    
}