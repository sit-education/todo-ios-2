//
//  ActivityIndicator.swift
//  ToDoApp
//
//  Created by Dennis Yaremenko on 7/13/16.
//  Copyright © 2016 Dennis Yaremenko. All rights reserved.
//

import Foundation
import UIKit

class ActivityIndicator {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var background = UIView()
    
    func createActivityIndicator(mainView: UIView) -> UIActivityIndicatorView {
        
        background.frame = CGRectMake(0, 0, 60, 60)
        background.center = mainView.center
        background.backgroundColor = UIColor.lightGrayColor()
        background.clipsToBounds = true
        background.layer.cornerRadius = 10
        background.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleTopMargin]
        
        activityIndicator.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.center = CGPointMake(background.frame.size.width / 2, background.frame.size.height / 2)
        activityIndicator.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleTopMargin]
        
        background.addSubview(activityIndicator)
        mainView.addSubview(background)
        return activityIndicator
    }
    
    
    func startAnimating() {
        activityIndicator.startAnimating()
        background.hidden = false
    }
    
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
        background.hidden = true
    }
  
}
