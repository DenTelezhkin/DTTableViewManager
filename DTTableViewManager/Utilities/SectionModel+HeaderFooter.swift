//
//  SectionModel+HeaderFooter.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 06.09.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import DTModelStorage

/// Convenience getters and setters for table view header and footer models
public extension SectionModel
{
    /// UITableView header model for current section
    var tableHeaderModel : Any? {
        get {
            return self.supplementaryModelOfKind(DTTableViewElementSectionHeader)
        }
        set {
            self.setSupplementaryModel(newValue, forKind: DTTableViewElementSectionHeader)
        }
    }
    
    /// UITableView footer model for current section
    var tableFooterModel : Any? {
        get {
            return self.supplementaryModelOfKind(DTTableViewElementSectionFooter)
        }
        set {
            self.setSupplementaryModel(newValue, forKind: DTTableViewElementSectionFooter)
        }
    }
}