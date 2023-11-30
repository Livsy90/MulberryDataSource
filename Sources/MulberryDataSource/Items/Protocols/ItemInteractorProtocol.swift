//
//  ItemViewModelProtocol.swift
//
//
//  Created by Livsy on 29.11.2023.
//

import UIKit

public protocol ItemViewModelProtocol: NSObject {
    var cellClass: UITableViewCell.Type? { get }
    var reuseIdentifier: String { get }
    var itemHeight: CGFloat { get }
}

public extension ItemViewModelProtocol {
    var itemHeight: CGFloat {
        UITableView.automaticDimension
    }
}

public extension ItemViewModelProtocol {
    var connected: HashableItem {
        HashableItem(self)
    }
}
