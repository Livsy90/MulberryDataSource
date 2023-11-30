//
//  ItemViewModelDeletable.swift
//
//
//  Created by Livsy on 29.11.2023.
//

import Foundation

protocol ItemViewModelDeletable: ItemViewModelProtocol {
    var onDelete: (() -> Void)? { get set }
}
