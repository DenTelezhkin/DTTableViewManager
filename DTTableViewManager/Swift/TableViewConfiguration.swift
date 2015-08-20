//
//  TableViewConfiguration.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 20.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit

public enum SupplementarySectionStyle
{
    case Title
    case View
}

public struct TableViewConfiguration
{
    public var sectionHeaderStyle = SupplementarySectionStyle.Title
    public var sectionFooterStyle = SupplementarySectionStyle.Title
    
    public var displayHeaderOnEmptySection = true
    public var displayFooterOnEmptySection = true
    
    public var insertSectionAnimation = UITableViewRowAnimation.None
    public var deleteSectionAnimation = UITableViewRowAnimation.Automatic
    public var reloadSectionAnimation = UITableViewRowAnimation.Automatic
    
    public var insertRowAnimation = UITableViewRowAnimation.Automatic
    public var deleteRowAnimation = UITableViewRowAnimation.Automatic
    public var reloadRowAnimation = UITableViewRowAnimation.Automatic
}