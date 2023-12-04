//
//  ItemViewModelProtocol.swift
//
//
//  Created by Livsy on 29.11.2023.
//

import UIKit

public protocol ItemViewModelProtocol: AnyObject {
    var cellClass: UITableViewCell.Type? { get }
    var reuseIdentifier: String { get }
    var itemHeight: CGFloat { get }
}
