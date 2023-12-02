//
//  File.swift
//  
//
//  Created by Livsy on 29.11.2023.
//

import Foundation

public struct HashableSection: Hashable {
    public var items: [HashableItem]
    public var header: HashableItem?
    
    private let id = UUID()
    
    public init(
        items: [HashableItem],
        header: HashableItem? = nil
    ) {
        
        self.items = items
        self.header = header
    }
    
    public static func == (lhs: HashableSection, rhs: HashableSection) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
