//
//  DragAndDropTextsViewController.swift
//  Example
//
//  Created by Denys Telezhkin on 20.08.17.
//  Copyright © 2017 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager

class DragAndDropTextsViewController: UIViewController, DTTableViewManageable {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.startManaging(withDelegate: self)
        manager.register(StringCell.self)
        manager.memoryStorage.setSectionHeaderModels(["Section 1", "Section 2"])
        manager.memoryStorage.addItems(["Foo", "Bar", "Amazing Daniel"], toSection: 0)
        manager.memoryStorage.addItems(["Test1, Test2"], toSection: 1)
        tableView.dragInteractionEnabled = true
    }


}

extension DragAndDropTextsViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
}
