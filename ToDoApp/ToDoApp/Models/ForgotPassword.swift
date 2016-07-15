//
//  ForgotPassword.swift
//  ToDoApp
//
//  Created by Dennis Yaremenko on 7/13/16.
//  Copyright © 2016 Dennis Yaremenko. All rights reserved.
//

import Foundation

final class ForgotPassword: ToParamsProtocol, ValidatableProtocol {
    
    let email: String
    
    init(email: String) {
        self.email = email
    }
    
    //MARK: - ToParamsProtocol
    
    func toParams() -> [String : AnyObject] {
        return ["email" : email]
    }
    
    //MARK: - ValidatableProtocol
    
    var errorString = ""
    
    func validate() -> Bool {
        if email == "" {
            errorString = "Email is empty"
        }
        return errorString.characters.count == 0
    }
   
}
