//
//  Array+Appending.swift
//
//
//  Created by Livsy on 29.11.2023.
//

import Foundation

public extension Array where Element: Equatable {
    func appendingSequence(_ sequence: [Element]) -> [Element] {
        self + sequence
    }
}
