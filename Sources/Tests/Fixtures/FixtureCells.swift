//
//  NiblessCell.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 15.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager

class BaseTestCell : UITableViewCell, ModelTransfer, ModelRetrievable
{
    var model : Any! = nil
    var awakedFromNib = false
    var inittedWithStyle = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.inittedWithStyle = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.awakedFromNib = true
    }
    
    func update(with model: Int) {
        self.model = model
    }
}

class NiblessCell: BaseTestCell {}

class NibCell: BaseTestCell {
    @IBOutlet weak var customLabel: UILabel?
}

class StringCell : UITableViewCell, ModelTransfer
{
    func update(with model: String) {
        
    }
}

class WrongReuseIdentifierCell : BaseTestCell {}

import SwiftUI

@available(iOS 13, tvOS 13, *)
struct SwiftUICell: View {
    var text: String
    
    var body: some View {
        Text(text)
    }
}
