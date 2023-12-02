//
//  MulberryDataSourceProtocol.swift
//
//
//  Created by Livsy on 29.11.2023.
//

import UIKit

public protocol MulberryDataSourceProtocol {
    var didReachTop: (() -> Void)? { get set }
    var didReachBottom: (() -> Void)? { get set }
    var sections: [HashableSection] { get set }
    
    func scrollToTop(animated: Bool)
    func scrollToBottom(at scrollPosition: UITableView.ScrollPosition, animated: Bool)
    func appendSections(_ sections: [HashableSection])
    func appendItems(_ items: [HashableItem], toSection: HashableSection?, _ completion: (() -> Void)?)
    func removeAt(_ indexPaths: [IndexPath], _ completion: (() -> Void)?)
    func removeItems(_ items: [HashableItem], _ completion: (() -> Void)?)
    func insertItems(_ items: [HashableItem], _ position: ItemPosotion, _ indexPath: IndexPath, _ completion: (() -> Void)?)
    func insertItems(_ items: [HashableItem], _ position: ItemPosotion, _ item: HashableItem, _ completion: (() -> Void)?)
    func removeAll(_ completion: (() -> Void)?)
    func move(itemAt indexPath: IndexPath, _ position: ItemPosotion, itemAt toIndexPath: IndexPath, _ completion: (() -> Void)?)
    func move(sectionWith index: Int, _ position: ItemPosotion, sectionWith toIndex: Int,_ completion: (() -> Void)?)
    func reloadItems(at indexPaths: [IndexPath], _ completion: (() -> Void)?)
    func reloadItems(_ items: [HashableItem], _ completion: (() -> Void)?)
    func reloadSections(at indexes: [Int], _ completion: (() -> Void)?)
    func reloadSections(_ sections: [HashableSection], _ completion: (() -> Void)?)
}
