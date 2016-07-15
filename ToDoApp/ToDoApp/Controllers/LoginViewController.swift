//
//  LoginViewController.swift
//  ToDoApp
//
//  Created by Dennis Yaremenko on 7/11/16.
//  Copyright © 2016 Dennis Yaremenko. All rights reserved.
//

import UIKit
import Alamofire

final class LoginViewController: UIViewController {
    
    enum Defaults {
        static let loginViewController = "LoginViewController"
    }

    //MARK: - IBOutlets
    
    @IBOutlet private weak var loginTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signInButton: UIButton!
    @IBOutlet private weak var singUpButton: UIButton!
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    
    //MARK: - Lifecycle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tap)
    }

    //MARK: - IBActions
    
    @IBAction private func signInAction(sender: AnyObject) {
        loginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let view = navigationController?.view {
            appDelegate.activityIndicator = ActivityIndicator()
            appDelegate.activityIndicator?.createActivityIndicator(view)
            appDelegate.activityIndicator?.startAnimating()
        }
        
        if let login = loginTextField.text?.trimmingString(), password = passwordTextField.text?.trimmingString() {
            let userLogin = UserLogin(login: login, password: password)
            guard userLogin.validate() else {
                AlertMessage.showMessageWithHanlder(self, title: AlertMessage.Defaults.warningString, message: userLogin.errorString, handler: {(_) in
                    appDelegate.activityIndicator?.stopAnimating()
                })
                return
            }
        
        
            Alamofire.request(Router.Login(userLogin)).responseJSON { response in
                appDelegate.activityIndicator?.stopAnimating()
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
                        guard let responseJSON = response.result.value as? [String: AnyObject],
                            results = responseJSON["data"] as? [String: AnyObject] else {
                                return
                        }
                        
                        Router.authenticationToken = results["tokenKey"] as? String

                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        if let itemListViewController = storyboard.instantiateViewControllerWithIdentifier(ItemListViewController.Defaults.ItemListViewController) as? ItemListViewController {
                            self.navigationController?.pushViewController(itemListViewController, animated: true)
                        }
                        
                    default: break
                        
                    }
                }
            }
        }
    }
    
    //MARK: - Public
    
    func handleTapGesture(sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
}

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.text = textField.text?.trimmingString()
        let nextTag = textField.tag + 1
        let nextResponder = textField.superview?.viewWithTag(nextTag)
        if let nextResponder = nextResponder {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            signInAction(signInButton)
        }
        return false
    }
    
}
