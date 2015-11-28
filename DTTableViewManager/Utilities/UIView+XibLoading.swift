//
//  UIView+XibLoading.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 18.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit
import DTModelStorage

extension UIView
{
    /// Load view from xib in specific bundle.
    /// - Parameter xibName: Name of xib file
    /// - Parameter bundle: NSBundle to search xib in
    /// - Returns: Loaded xib
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
    
    /// Load view in specific bundle.
    /// - Note: Xib name used is identical to class name, without module part, for example. Foo.View class -> "View".xib
    /// - Parameter bundle: NSBundle to search xib in
    /// - Returns: Loaded xib
    class func dt_loadFromXibInBundle(bundle: NSBundle) -> UIView?
    {
        return self.dt_loadFromXibNamed(String(self), bundle : bundle)
    }
}