//
//  NoteTableViewCell.swift
//  ToDoApp
//
//  Created by Dennis Yaremenko on 7/13/16.
//  Copyright © 2016 Dennis Yaremenko. All rights reserved.
//

import UIKit

protocol NoteTableViewCellDelegate: class {
    func editItem(sender: NoteTableViewCell)
    func deleteItem(sender: NoteTableViewCell)
}

final class NoteTableViewCell: UITableViewCell {
    
    enum Defaults {
        static let cellIdentifier = "noteTableViewCellIdentifier"
    }

    //MARK: - IBOutlets

    @IBOutlet private weak var numberItemLabel: UILabel!
    @IBOutlet private weak var titleItemLabel: UILabel!
    @IBOutlet private weak var descriptionItemLabel: UILabel!
    @IBOutlet private weak var contentItemLabel: UITextView!
    
    //MARK: - Properties
    
    weak var delegate: NoteTableViewCellDelegate?
    var item: Item?

    //MARK: - IBActions
    
    @IBAction private func deleteItemAction(sender: AnyObject) {
        delegate?.deleteItem(self)
    }
    
    @IBAction private func editItemAction(sender: AnyObject) {
        delegate?.editItem(self)
    }
    
    //MARK: - Public
    
    func fillData(item: Item) {
        self.item = item
        numberItemLabel.text = "# \(String(item.itemId))"
        titleItemLabel.text = item.title
        descriptionItemLabel.text = item.description
    }
    
    
}
