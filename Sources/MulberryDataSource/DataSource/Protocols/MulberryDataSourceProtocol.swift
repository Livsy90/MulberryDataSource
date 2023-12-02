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
    func insertItems(_ items: [HashableItem], _ position: MulberryDataSource.Position, _ indexPath: IndexPath, _ completion: (() -> Void)?)
    func insertItems(_ items: [HashableItem], _ position: MulberryDataSource.Position, _ item: HashableItem, _ completion: (() -> Void)?)
    func removeAll(_ completion: (() -> Void)?)
    func move(itemAt firstIndexPath: IndexPath, _ position: MulberryDataSource.Position, itemAt secondIndexPath: IndexPath, _ completion: (() -> Void)?)
    func move(sectionWith firstIndex: Int, _ position: MulberryDataSource.Position, sectionWith secondIndex: Int,_ completion: (() -> Void)?)
    func reloadSections(at indexes: [Int], _ completion: (() -> Void)?)
    func reloadItems(at indexPaths: [IndexPath], _ completion: (() -> Void)?)
}
