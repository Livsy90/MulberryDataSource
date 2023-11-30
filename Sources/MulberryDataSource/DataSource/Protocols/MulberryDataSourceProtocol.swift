//
//  MulberryDataSourceProtocol.swift
//
//
//  Created by Livsy on 29.11.2023.
//

import Foundation

public protocol MulberryDataSourceProtocol {
    var didReachTop: (() -> Void)? { get set }
    var didReachBottom: (() -> Void)? { get set }
    var sections: [HashableSection] { get set }
    
    func scrollToTop(animated: Bool)
    func scrollToBottom(animated: Bool)
    func appendSections(_ sections: [HashableSection])
    func appendItems(_ items: [HashableItem], toSection: HashableSection, _ completion: (() -> Void)?)
    func removeAt(_ indexPaths: [IndexPath], _ completion: (() -> Void)?)
    func removeItems(_ items: [HashableItem], _ completion: (() -> Void)?)
    func insertItems(_ items: [HashableItem], at indexPath: IndexPath, _ completion: (() -> Void)?)
    func insertAfterItem(_ item: HashableItem, items: [HashableItem], _ completion: (() -> Void)?)
    func insertBeforeItem(_ item: HashableItem, items: [HashableItem], _ completion: (() -> Void)?)
}
