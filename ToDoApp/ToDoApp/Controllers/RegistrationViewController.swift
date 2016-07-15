//
//  RegistrationViewController.swift
//  ToDoApp
//
//  Created by Dennis Yaremenko on 7/12/16.
//  Copyright © 2016 Dennis Yaremenko. All rights reserved.
//

import UIKit
import Alamofire

final class RegistrationViewController: UIViewController {
    
    enum Defaults {
        
        static let emptyEmail = "Email is empty \n"
        static let emptyLogin = "Login is empty \n"
        static let emptyFirstName = "FirstName is empty \n"
        static let emptyLastName = "LastName is empty \n"
        static let emptyPassword = "Password is empty \n"
        static let emptyConfirm = "Confirm password is empty \n"
        
    }
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var loginTextField: UITextField!
    @IBOutlet private weak var firstNameTextField: UITextField!
    @IBOutlet private weak var lastNameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    
    //MARK: - Lifecycle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tap)
    }
    
    //MARK: - IBACtions
    
    @IBAction private func signUpAction(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
 
        if let view = navigationController?.view {
            appDelegate.activityIndicator = ActivityIndicator()
            appDelegate.activityIndicator?.createActivityIndicator(view)
            appDelegate.activityIndicator?.startAnimating()
        }
        
        if let firstName = firstNameTextField.text?.trimmingString(), lastName = lastNameTextField.text?.trimmingString(), login = loginTextField.text?.trimmingString(), email = emailTextField.text?.trimmingString(), password = passwordTextField.text?.trimmingString(), confirmPassword = confirmPasswordTextField.text?.trimmingString() {
            
            let registerUser = Registration(firstName: firstName,
                                            lastName: lastName,
                                            login: login,
                                            email: email,
                                            password: password,
                                            confirmPassword: confirmPassword)
            
            guard registerUser.validate() else {
                AlertMessage.showMessageWithHanlder(self, title: AlertMessage.Defaults.warningString, message: registerUser.errorString, handler: {(_) in
                    appDelegate.activityIndicator?.stopAnimating()
                })
                return
            }
            
            Alamofire.request(Router.SignUp(registerUser)).responseJSON { response in
                
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
                        
                        AlertMessage.showMessageWithHanlder(self, title: "Error", message: firstResult["error_message"] as? String, handler: { (_) in
                            appDelegate.activityIndicator?.stopAnimating()
                        })
                        
                    case 1:
                        guard let responseJSON = response.result.value as? [String: AnyObject],
                            results = responseJSON["data"] as? [String: AnyObject],
                            firstResult = results["tokenKey"] else {
                                return
                        }
                        
                        Router.authenticationToken = firstResult as? String
                        
                        AlertMessage.showMessageWithHanlder(self, title: AlertMessage.Defaults.successTitleString, message: AlertMessage.Defaults.successRegistrationString, handler: { [weak self] (_) in
                            appDelegate.activityIndicator?.stopAnimating()
                            self?.navigationController?.popViewControllerAnimated(true)
                            })
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

extension RegistrationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.text = textField.text?.trimmingString()
        let nextTag = textField.tag + 1
        let nextResponder = textField.superview?.viewWithTag(nextTag)
        if let nextResponder = nextResponder {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            signUpAction(signUpButton)
        }
        return false
    }
    
}
