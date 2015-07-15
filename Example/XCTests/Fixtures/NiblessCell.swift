//
//  NiblessCell.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 15.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage

class BaseTestCell : UITableViewCell, ModelTransfer, ModelRetrievable
{
    var model : Any!
    var awakedFromNib = false
    var inittedWithStyle = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.inittedWithStyle = true
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.awakedFromNib = true
    }
    
    func updateWithModel(model: Int) {
        self.model = model
    }
}

class NiblessCell: BaseTestCell {


}
