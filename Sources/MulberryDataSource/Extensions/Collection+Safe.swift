//
//  Collection+Safe.swift
//
//
//  Created by Livsy on 29.11.2023.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
