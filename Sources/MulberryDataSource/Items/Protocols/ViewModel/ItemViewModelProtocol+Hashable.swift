//
//  File.swift
//  
//
//  Created by Livsy on 01.12.2023.
//

import Foundation

public extension ItemViewModelProtocol {
    var hashable: HashableItem {
        .init(self)
    }
}
