//
//  ItemViewModelMutable.swift
//  
//
//  Created by Livsy on 29.11.2023.
//

import Foundation

public protocol ItemViewModelMutable: ItemViewModelProtocol {
    var onChange: (() -> Void)? { get set }
}
