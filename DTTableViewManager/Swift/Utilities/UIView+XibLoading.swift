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
    class func dt_loadFromXibNamed(xibName : String, bundle : NSBundle) -> UIView?
    {
        let topLevelObjects = bundle.loadNibNamed(xibName, owner: nil, options: nil)
        
        for object in topLevelObjects {
            if object.isKindOfClass(self) {
                return object as? UIView
            }
        }
        return nil
    }
    
    class func dt_loadFromXibInBundle(bundle: NSBundle) -> UIView?
    {
        return self.dt_loadFromXibNamed(RuntimeHelper.classNameFromReflection(_reflect(self)), bundle : bundle)
    }
}