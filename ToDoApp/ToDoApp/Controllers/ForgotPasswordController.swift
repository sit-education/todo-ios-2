//
//  ForgotPasswordController.swift
//  ToDoApp
//
//  Created by Dennis Yaremenko on 7/13/16.
//  Copyright © 2016 Dennis Yaremenko. All rights reserved.
//

import UIKit
import Alamofire

final class ForgotPasswordController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.becomeFirstResponder()
    }
    
    //MARK: - IBActions
    
    @IBAction private func signUpAction(sender: AnyObject) {
        emailTextField.resignFirstResponder()

        if let email = emailTextField.text?.trimmingString() {
            let forgotPassword = ForgotPassword(email: email)
            
            guard forgotPassword.validate() else {
                AlertMessage.showMessageWithHanlder(self, title: AlertMessage.Defaults.errorString, message: forgotPassword.errorString, handler: { [weak self] (_) in
                    self?.emailTextField.becomeFirstResponder()
                    })
                return
            }
            
            Alamofire.request(Router.Recover(forgotPassword)).responseJSON { response in
                if let status = response.result.value, statusString = status["status"] as? Int {
                    
                    guard response.result.isSuccess else {
                        AlertMessage.showMessageWithHanlder(self, title: "Error", message: response.result.error?.description, handler: nil)
                        return
                    }
                    
                    switch statusString {
                    case 0:
                        guard let responseJSON = response.result.value as? [String: AnyObject],
                            results = responseJSON["errors"] as? [[String: AnyObject]],
                            firstResult = results.first else {
                                return
                        }
                        
                        AlertMessage.showMessageWithHanlder(self, title: "Error", message: firstResult["error_message"] as? String, handler: { [weak self] (_) in
                            self?.emailTextField.becomeFirstResponder()
                            })
                        
                    case 1:
                        AlertMessage.showMessageWithHanlder(self, title: "Success", message: "Message sent succesfully. Please check your email", handler: { [weak self] (_) in
                            self?.navigationController?.popViewControllerAnimated(true)
                            })
                        
                    default: break
                        
                    }
                }
            }
        }
    }
}

extension ForgotPasswordController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        signUpAction(signUpButton)
        textField.resignFirstResponder()
        return false
    }
    
}

