//
//  HashableItem.swift
//
//
//  Created by Livsy on 29.11.2023.
//

import Foundation

public struct HashableItem: Hashable {
    public var viewModel: ItemViewModelProtocol
    private let id = UUID()
    
    public init(_ viewModel: ItemViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    public static func == (lhs: HashableItem, rhs: HashableItem) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
