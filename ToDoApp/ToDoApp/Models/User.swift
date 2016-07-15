//
//  User.swift
//  ToDoApp
//
//  Created by Dennis Yaremenko on 7/12/16.
//  Copyright © 2016 Dennis Yaremenko. All rights reserved.
//

import Foundation

protocol ToParamsProtocol {
    func toParams() -> [String: AnyObject]
}

protocol ValidatableProtocol {
    func validate() -> Bool
    var errorString: String { get set }
}

class User {
    
    let firstName: String
    let lastName: String
    let login: String
    let email: String
    let password: String
    
    init(firstName: String, lastName: String, login: String, email: String, password: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.login = login
        self.email = email
        self.password = password
    }

}
