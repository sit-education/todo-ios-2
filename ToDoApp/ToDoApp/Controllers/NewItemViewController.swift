//
//  NewItemViewController.swift
//  ToDoApp
//
//  Created by Dennis Yaremenko on 7/14/16.
//  Copyright © 2016 Dennis Yaremenko. All rights reserved.
//

import UIKit
import Alamofire

final class NewItemViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var itemNumberLabel: UILabel!
    @IBOutlet private weak var titleItemTextField: UITextField!
    @IBOutlet private weak var descriptionTextView: UITextView!
    
    //MARK: - Properties
    
    var currentItemId: String?
    var currentItem: Item?
    var addedNewItem: Bool?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let item = currentItem else {
            if let item = currentItemId {
                itemNumberLabel.text = "# \(item)"
            }
            return
        }
        
        itemNumberLabel.text = "# \(item.itemId)"
        titleItemTextField.text = item.title
        descriptionTextView.text = item.description
        currentItemId = String(item.itemId)
    }
    
    //MARK: - IBActions
    
    @IBAction private func backAction(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction private func logoutAction(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.activityIndicator = ActivityIndicator()
        appDelegate.activityIndicator?.createActivityIndicator(view)
        appDelegate.activityIndicator?.startAnimating()
        
        let alertController = UIAlertController(title: AlertMessage.Defaults.logoutTitleString, message: AlertMessage.Defaults.logoutDescriptionString, preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { [weak self] (_) in
            
            
            Alamofire.request(Router.Logout()).responseJSON { response in
                guard response.result.isSuccess else {
                    AlertMessage.showMessageWithHanlder(self!, title: AlertMessage.Defaults.errorString, message: response.result.error?.description, handler: nil)
                    return
                }
                
                if let status = response.result.value, statusString = status["status"] as? Int {
                    switch statusString {
                    case 0:
                        guard let responseJSON = response.result.value as? [String: AnyObject],
                            results = responseJSON["errors"] as? [[String: AnyObject]],
                            firstResult = results.first else {
                                return
                        }
                        AlertMessage.showMessageWithHanlder(self!, title: AlertMessage.Defaults.errorString, message: firstResult["error_message"] as? String, handler: nil)
                    case 1:
                        Router.authenticationToken = nil
                        
                        appDelegate.activityIndicator?.stopAnimating()
                        self?.navigationController?.popViewControllerAnimated(true)
                        
                        appDelegate.switchToController(LoginViewController.Defaults.loginViewController)
                        
                    default: break
                    }
                }
            }
        }
        
        let noAction = UIAlertAction(title: "No", style: .Default) {(_) in
            appDelegate.activityIndicator?.stopAnimating()
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        alertController.view.tintColor = UIColor.blackColor()
    }
    
    
    @IBAction private func saveAction(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.activityIndicator?.startAnimating()
        
        if let title = titleItemTextField.text?.trimmingString(), description = descriptionTextView.text?.trimmingString(), itemId = currentItemId {
            let item = Item(title: title, description: description, itemId: Int(itemId)!)
            
            guard item.validate() else {
                AlertMessage.showMessageWithHanlder(self, title: AlertMessage.Defaults.warningString, message: item.errorString, handler: {(_) in
                    appDelegate.activityIndicator?.stopAnimating()
                })
                return
            }
            if let added = addedNewItem {
                added ? updateItemUsingRoute(Router.AddNew(item)) : updateItemUsingRoute(Router.EditItem(item))
            }
        }
    }
    
    //Private
    
    private func updateItemUsingRoute(router: URLRequestConvertible) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        Alamofire.request(router).responseJSON { response in
            guard response.result.isSuccess else {
                AlertMessage.showMessageWithHanlder(self, title: AlertMessage.Defaults.errorString, message: response.result.error?.description, handler: nil)
                return
            }
            
            if let status = response.result.value, statusString = status["status"] as? Int {
                switch statusString {
                case 0:
                    guard let responseJSON = response.result.value as? [String: AnyObject],
                        results = responseJSON["errors"] as? [[String: AnyObject]],
                        firstResult = results.first else {
                            return
                    }
                    AlertMessage.showMessageWithHanlder(self, title: AlertMessage.Defaults.errorString, message: firstResult["error_message"] as? String, handler: {(_) in
                        appDelegate.activityIndicator?.stopAnimating()
                    })
                    
                case 1:
                    appDelegate.activityIndicator?.stopAnimating()
                    self.navigationController?.popViewControllerAnimated(true)
                default: break
                }
            }
        }
    }
    
}
