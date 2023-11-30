//
//  ItemViewModelTappable.swift
//
//
//  Created by Livsy on 29.11.2023.
//

import Foundation

protocol ItemViewModelTappable: ItemViewModelProtocol {
    var onTap: (() -> Void)? { get set }
}
