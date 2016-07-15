//
//  Registration.swift
//  ToDoApp
//
//  Created by Dennis Yaremenko on 7/12/16.
//  Copyright © 2016 Dennis Yaremenko. All rights reserved.
//

import Foundation


class Registration: User, ValidatableProtocol {
    
    //MARK: - Properties
    
    let confirmPassword: String
    var errorString = ""
    
    //MARK: - Init
    
    init(firstName: String, lastName: String, login: String, email: String, password: String, confirmPassword: String) {
        self.confirmPassword = confirmPassword
        super.init(firstName: firstName, lastName: lastName, login: login, email: email, password: password)
    }
    
     //MARK: - ValidatableProtocol

    func validate() -> Bool {
        
        if firstName == "" {
            errorString += "Empty name \n"
        }
        if lastName == "" {
            errorString += "Empty lastName \n"
        }
        if login == "" {
            errorString += "Empty login \n"
        }
        
        if email == "" {
            errorString += "Empty email \n"
        }
        
        if password == "" {
            errorString += "Empty password \n"
        }
        
        if confirmPassword == "" {
            errorString += "Empty confirmPassword \n"
        }
        
        return errorString.characters.count == 0
    }
}

extension Registration: ToParamsProtocol {
    
    func toParams() -> [String: AnyObject] {
        return ["email" : email,
                "login" : login,
                "firstName" : firstName,
                "lastName" : lastName,
                "password" : password,
                "confPass" : confirmPassword]
    }
    
}
