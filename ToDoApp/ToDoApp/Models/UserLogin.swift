//
//  UserLogin.swift
//  ToDoApp
//
//  Created by Dennis Yaremenko on 7/12/16.
//  Copyright © 2016 Dennis Yaremenko. All rights reserved.
//

import Foundation

final class UserLogin: ToParamsProtocol, ValidatableProtocol {

    let login: String
    let password: String
    
    init(login: String, password: String) {
        self.login = login
        self.password = password
    }
    
    //MARK: - ToParamsProtocol

    func toParams() -> [String : AnyObject] {
        return ["login" : login, "password" : password]
    }
    
    //MARK: - ToParamsProtocol
    
    var errorString = ""
    
    func validate() -> Bool {
        if login == "" {
            errorString += "Login is empty \n"
        }
        if password == "" {
            errorString += "Password is empty \n"
        }
        return errorString.characters.count == 0
    }
    
    
}