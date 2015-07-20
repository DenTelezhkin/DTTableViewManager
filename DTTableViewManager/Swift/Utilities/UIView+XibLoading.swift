//
//  UIView+XibLoading.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 18.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit
import ModelStorage

extension UIView
{
    class func dt_loadFromXibNamed(xibName : String) -> UIView?
    {
        let topLevelObjects = NSBundle(forClass: self).loadNibNamed(xibName, owner: nil, options: nil)
        
        for object in topLevelObjects {
            if object.isKindOfClass(self) {
                return object as? UIView
            }
        }
        return nil
    }
    
    class func dt_loadFromXib() -> UIView?
    {
        return self.dt_loadFromXibNamed(RuntimeHelper.classNameFromReflection(reflect(self)))
    }
}