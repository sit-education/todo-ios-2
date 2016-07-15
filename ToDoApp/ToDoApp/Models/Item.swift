//
//  Item.swift
//  ToDoApp
//
//  Created by Dennis Yaremenko on 7/14/16.
//  Copyright © 2016 Dennis Yaremenko. All rights reserved.
//

import Foundation

final class Item: ToParamsProtocol, ValidatableProtocol {
    
    let itemId: Int
    let title: String
    let description: String
    
    
    
    init(title: String, description: String, itemId: Int) {
        self.itemId = itemId
        self.title = title
        self.description = description
    }
    
    //MARK: - ToParamsProtocol
    
    func toParams() -> [String : AnyObject] {
        return ["title" : title, "description" : description, "id" : itemId]
    }

    //MARK: - ValidatableProtocol
    
    var errorString = ""
    
    func validate() -> Bool {
        if title == "" {
            errorString += "Title is empty \n"
        }
        if description == "" {
            errorString += "Description is empty \n"
        }
        
        return errorString.characters.count == 0
    }
   
}
