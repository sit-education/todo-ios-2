//
//  ItemListViewController.swift
//  ToDoApp
//
//  Created by Dennis Yaremenko on 7/13/16.
//  Copyright © 2016 Dennis Yaremenko. All rights reserved.
//

import UIKit
import Alamofire

final class ItemListViewController: UIViewController {
    
    enum Defaults {
        static let ItemListViewController = "ItemListViewController"
        static let NewItemViewController = "NewItemViewController"
    }
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: - Properties
    
    private var dataSource = [AnyObject]()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = true
        
        tableView.registerNib(UINib.init(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: NoteTableViewCell.Defaults.cellIdentifier)
        tableView.allowsSelection = false
        
        tableView.estimatedRowHeight = 95
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dataSource.removeAll()
        
        Alamofire.request(Router.ItemsList()).responseJSON { response in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                guard response.result.isSuccess else {
                    AlertMessage.showMessageWithHanlder(self, title: AlertMessage.Defaults.errorString, message: response.result.error?.description, handler: nil)
                    return
                }
                
                if let status = response.result.value, statusString = status["status"] as? Int {
                    switch statusString {
                    case 0:
                        Router.authenticationToken = nil
                        dispatch_async(dispatch_get_main_queue(), {
                            let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
                            appDelegate?.switchToController(LoginViewController.Defaults.loginViewController)
                        })

                    case 1:
                        guard let responseJSON = response.result.value as? [String: AnyObject],
                            results = responseJSON["data"] as? [String: AnyObject], innerValues = results["todoData"] as? [[String: AnyObject]] else {
                                AlertMessage.showMessageWithHanlder(self, title: AlertMessage.Defaults.warningString, message: "Invalid receiving", handler: nil)
                                return
                        }
                        for item in innerValues {
                            let newItem = Item.init(title: item["title"] as! String, description: item["description"] as! String, itemId: item["id"] as! Int)
                            self.dataSource.append(newItem)
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                    default: break
                    }
                }
            }
        }
    }
    
    //MARK: - IBActions
    
    @IBAction private func addNewItemAction(sender: AnyObject) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let newItemViewController = storyboard.instantiateViewControllerWithIdentifier(Defaults.NewItemViewController) as? NewItemViewController {
            newItemViewController.currentItemId = String(dataSource.count + 1)
            newItemViewController.addedNewItem = true
            navigationController?.pushViewController(newItemViewController, animated: true)
        }
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
    
}


extension ItemListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NoteTableViewCell.Defaults.cellIdentifier, forIndexPath: indexPath) as! NoteTableViewCell
        cell.delegate = self
        if let item = dataSource[indexPath.row] as? Item {
            cell.fillData(item)
        }
        return cell
    }
    
}

extension ItemListViewController: NoteTableViewCellDelegate {
    
    func editItem(sender: NoteTableViewCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let newItemViewController = storyboard.instantiateViewControllerWithIdentifier(Defaults.NewItemViewController) as? NewItemViewController {
            newItemViewController.currentItem = sender.item
            newItemViewController.addedNewItem = false
            navigationController?.pushViewController(newItemViewController, animated: true)
        }
    }
    
    func deleteItem(sender: NoteTableViewCell) {
        let alertController = UIAlertController(title: AlertMessage.Defaults.deleteTitleString, message: AlertMessage.Defaults.deleteDescriptionString, preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { [weak self] (_) in
            Alamofire.request(Router.DeleteItem(sender.item!)).responseJSON {response in
                
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
                        let array = self?.dataSource as? [Item]
                        self?.dataSource = array!.filter({$0.itemId != sender.item!.itemId})
                        self?.tableView.reloadData()
                        
                        AlertMessage.showMessageWithHanlder(self!, title: AlertMessage.Defaults.successTitleString, message: AlertMessage.Defaults.successDescriptionString, handler: nil)
                    default: break
                    }
                }
            }
        }
        
        let noAction = UIAlertAction(title: "No", style: .Default) { (_) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        presentViewController(alertController, animated: true, completion: nil)
        alertController.view.tintColor = UIColor.blackColor()
    }
    
}
