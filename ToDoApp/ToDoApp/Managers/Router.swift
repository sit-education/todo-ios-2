//
//  Router.swift
//  ToDoApp
//
//  Created by Dennis Yaremenko on 7/12/16.
//  Copyright © 2016 Dennis Yaremenko. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    
    enum Defaults {
        static let accessTokenUserDefaultsKey = "accessTokenUserDefaultsKey"
        static let baseURLPath = "https://sit-todo-test.appspot.com/api/v1"
    }

    static var authenticationToken: String? {
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: Router.Defaults.accessTokenUserDefaultsKey)
        }
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(Router.Defaults.accessTokenUserDefaultsKey)
        }
    }

    static var isAuthorized: Bool {
        return authenticationToken != nil
    }

    case Login(UserLogin)
    case SignUp(Registration)
    case Recover(ForgotPassword)
    case Logout()
    case ItemsList()
    case AddNew(Item)
    case EditItem(Item)
    case DeleteItem(Item)

    var URLRequest: NSMutableURLRequest {
        let requestData: (path: String, method: Alamofire.Method, parameters: [String: AnyObject]?) = {
            switch self {
            case .Login (let userLogin):
                return ("/login", .POST, userLogin.toParams())
 
            case .SignUp (let userRegistration):
                return ("/signup", .POST, userRegistration.toParams())
                
            case .Recover(let forgotPassword):
                return ("/restorePassword", .POST, forgotPassword.toParams())
  
            case .Logout():
                return("/logout", .POST, nil)
                
            case .ItemsList():
                return("/items", .GET, nil)
                
            case .AddNew(let newItem):
                return("/item", .POST, newItem.toParams())
                
            case .EditItem(let item):
                return("/item/\(item.itemId)", .PUT, item.toParams())
                
            case .DeleteItem(let item):
                return("/item/\(item.itemId)", .DELETE, nil)
 
            }
        }()

        let URL = NSURL(string: Router.Defaults.baseURLPath)!
        let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(requestData.path))
        URLRequest.HTTPMethod = requestData.method.rawValue

        if let token = Router.authenticationToken {
            URLRequest.setValue(token, forHTTPHeaderField: "Token-Key")
        }

        let encoding = Alamofire.ParameterEncoding.JSON
        return encoding.encode(URLRequest, parameters: requestData.parameters).0
    }
    
}
