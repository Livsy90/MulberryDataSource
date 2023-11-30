//
//  CellConfigurable.swift
//
//
//  Created by Livsy on 29.11.2023.
//

import UIKit

public protocol CellConfigurable: UITableViewCell {
    func configure(_ viewModel: ItemViewModelProtocol)
}
