//
//  MulberryDataSource.swift
//
//
//  Created by Livsy on 29.11.2023.
//

import Foundation
import UIKit

public final class MulberryDataSource: NSObject, MulberryDataSourceProtocol, UITableViewDelegate {
    
    // MARK: - Nested Entities
    
    private enum Constants {
        static let defaultOffset: CGFloat = 60
    }
    
    private final class ItemTapGesture: UITapGestureRecognizer {
        var viewModel: ItemViewModelTappable?
    }
    
    // MARK: - Public Properties
    
    /// Sections of the table view
    public var sections: [HashableSection] = [] {
        didSet {
            reload()
        }
    }
    
    /// Notifies when the top of the table view with a specified offset has been reached.
    public var didReachTop: (() -> Void)?
    
    /// Notifies when the bottom of the table view with a specified offset has been reached.
    public var didReachBottom: (() -> Void)?
    
    /// Defines the offset to the edge of the table view at which the completion should be triggered.
    public var edgeReachCompletionOffset: CGFloat = Constants.defaultOffset
    
    /// Defines the behavior of the table view cells after a tap.
    public var shouldDeselect: Bool = true
    
    /// The type of animation to use when inserting or deleting rows.
    public var rowAnimation: UITableView.RowAnimation = .automatic {
        didSet {
            dataSource.defaultRowAnimation = rowAnimation
        }
    }
    
    // MARK: - Private Properties
    
    private var registeredReuseIdentifiers: Set<String> = .init()
    private var tableView: UITableView {
        didSet {
            registeredReuseIdentifiers.removeAll()
        }
    }
    private lazy var dataSource = UITableViewDiffableDataSource<HashableSection, HashableItem>(
        tableView: tableView,
        cellProvider: { [weak self] _, _, item -> UITableViewCell? in
            guard let cell = self?.dequeueCell(item.viewModel.reuseIdentifier) else {
                return .init()
            }
            cell.configure(with: item.viewModel)
            
            return cell
        }
    )
    
    // MARK: - Init
    
    public init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        
        self.tableView.delegate = self
    }
    
    // MARK: - Public Methods
    
    /// Scrolls the table view content to the top.
    /// - Parameter animated: Turns animation on or off.
    public func scrollToTop(animated: Bool) {
        DispatchQueue.main.async {
            self.tableView.setContentOffset(.zero, animated: animated)
        }
    }
    
    /// Scrolls the table view content to the bottom.
    /// - Parameters:
    ///   - scrollPosition: The position in the table view (top, middle, bottom) to scroll a specified row to.
    ///   - animated: Turns animation on or off.
    public func scrollToBottom(at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        tableView.scrollToBottom(at: scrollPosition, animated: animated)
    }
    
    /// Adds the sections with the specified identifiers to the snapshot.
    /// - Parameter sections: An array of identifiers specifying the sections to add to the snapshot.
    public func appendSections(_ sections: [HashableSection]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot)
    }
    
    /// Adds the items with the specified identifiers to the specified section of the snapshot.
    /// - Parameters:
    ///   - items: An array of identifiers specifying the items to add to the snapshot.
    ///   - toSection: The section to which to add the items. If no value is provided, the items are appended to the last section of the snapshot.
    ///   - completion: The block to execute after the updates.
    public func appendItems(
        _ items: [HashableItem],
        toSection: HashableSection?,
        _ completion: (() -> Void)? = nil
    ) {
        
        items.forEach(configureItem)
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.appendItems(items, toSection: toSection)
            
            self.dataSource.apply(snapshot) {
                completion?()
            }
        }
    }
    
    /// Deletes the items at the specified index paths.
    /// - Parameters:
    ///   - indexPaths: An array of NSIndexPath objects, each of which contains a section index and item index for the item you want to delete from the table view
    ///   - completion: The block to execute after the updates.
    public func removeAt(
        _ indexPaths: [IndexPath],
        _ completion: (() -> Void)? = nil
    ) {
        
        removeItems(
            indexPaths.compactMap {
                sections[safe: $0.section]?.items[safe: $0.row]
            }
        ) {
            completion?()
        }
    }
    
    /// Deletes the items with the specified identifiers.
    /// - Parameters:
    ///   - items: The array of identifiers corresponding to the items to delete from the snapshot.
    ///   - completion: The block to execute after the updates.
    public func removeItems(
        _ items: [HashableItem],
        _ completion: (() -> Void)? = nil
    ) {
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.deleteItems(items)
            self.dataSource.apply(snapshot) {
                completion?()
            }
        }
    }
    
    /// Inserts the provided items immediately before or after the item with the specified index path.
    /// - Parameters:
    ///   - items: The array of identifiers corresponding to the items to add to the snapshot.
    ///   - position: Determines the position: before or after.
    ///   - indexPath: The index path of the item before or after which to insert the new items.
    ///   - completion: The block to execute after the updates.
    public func insertItems(
        _ items: [HashableItem],
        _ position: TablePosition,
        _ indexPath: IndexPath,
        _ completion: (() -> Void)? = nil
    ) {
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            assert(false, "MulberryDataSource: insertItems failure")
            return
        }
        
        items.forEach(configureItem)
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            switch position {
            case .before:
                snapshot.insertItems(items, beforeItem: item)
            case .after:
                snapshot.insertItems(items, afterItem: item)
            }
            self.dataSource.apply(snapshot) {
                completion?()
            }
        }
    }
    
    /// Inserts the provided items immediately before or after the item with the specified indentifier.
    /// - Parameters:
    ///   - items: The array of identifiers corresponding to the items to add to the snapshot.
    ///   - position: Determines the position: before or after.
    ///   - item: The identifier of the item before or after which to insert the new items.
    ///   - completion: The block to execute after the updates.
    public func insertItems(
        _ items: [HashableItem],
        _ position: TablePosition,
        _ item: HashableItem,
        _ completion: (() -> Void)? = nil
    ) {
        
        items.forEach(configureItem)
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            switch position {
            case .before:
                snapshot.insertItems(items, beforeItem: item)
            case .after:
                snapshot.insertItems(items, afterItem: item)
            }
            self.dataSource.apply(snapshot) {
                completion?()
            }
        }
    }
    
    /// Deletes all of the items from the snapshot.
    /// - Parameter completion: The block to execute after the updates.
    public func removeAll(_ completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.deleteAllItems()
            self.dataSource.apply(snapshot) {
                completion?()
            }
        }
    }
    
    /// Moves the item from its current position in the snapshot to the position immediately before or after the specified item.
    /// - Parameters:
    ///   - indexPath: The index path of the item to move in the snapshot.
    ///   - position: Determines the position: before or after.
    ///   - toIndexPath: The index path  of the item after which to move the specified item.
    ///   - completion: The block to execute after the updates.
    public func move(
        itemAt indexPath: IndexPath,
        _ position: TablePosition,
        itemAt toIndexPath: IndexPath,
        _ completion: (() -> Void)? = nil
    ) {
        
        guard
            let firstItem = dataSource.itemIdentifier(for: indexPath),
            let secondItem = dataSource.itemIdentifier(for: toIndexPath)
        else {
            assert(false, "MulberryDataSource: moveItem failure")
            return
        }
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            switch position {
            case .before:
                snapshot.moveItem(firstItem, beforeItem: secondItem)
            case .after:
                snapshot.moveItem(firstItem, afterItem: secondItem)
            }
            self.dataSource.apply(snapshot) {
                completion?()
            }
        }
    }
    
    /// Moves the item from its current position in the snapshot to the position immediately before or after the specified item.
    /// - Parameters:
    ///   - item: The identifier of the item to move in the snapshot.
    ///   - position: Determines the position: before or after.
    ///   - toItem: The identifier of the item after which to move the specified item.
    ///   - completion: The block to execute after the updates.
    public func move(
        _ item: HashableItem,
        _ position: TablePosition,
        _ toItem: HashableItem,
        _ completion: (() -> Void)? = nil
    ) {
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            switch position {
            case .before:
                snapshot.moveItem(item, beforeItem: toItem)
            case .after:
                snapshot.moveItem(item, afterItem: toItem)
            }
            self.dataSource.apply(snapshot) {
                completion?()
            }
        }
    }
    
    /// Reloads the data within the specified items in the snapshot.
    /// - Parameters:
    ///   - indexPaths: The array of index paths corresponding to the items to reload in the snapshot.
    ///   - completion: The block to execute after the updates.
    public func reloadItems(
        at indexPaths: [IndexPath],
        _ completion: (() -> Void)? = nil
    ) {
        
        let items = indexPaths.compactMap {
            dataSource.itemIdentifier(for: $0)
        }
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.reloadItems(items)
            self.dataSource.apply(snapshot) {
                completion?()
            }
        }
    }
    
    /// Reloads the data within the specified items in the snapshot.
    /// - Parameters:
    ///   - indexPaths: The array of identifiers corresponding to the items to reload in the snapshot.
    ///   - completion: The block to execute after the updates.
    public func reloadItems(
        _ items: [HashableItem],
        _ completion: (() -> Void)? = nil
    ) {
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.reloadItems(items)
            self.dataSource.apply(snapshot) {
                completion?()
            }
        }
    }
    
    /// Moves the section from its current position in the snapshot to the position immediately before or after the specified section.
    /// - Parameters:
    ///   - index: The index of the section to move in the snapshot.
    ///   - position: Determines the position: before or after.
    ///   - toIndex: The index of the section after which to move the specified section.
    ///   - completion: The block to execute after the updates.
    public func move(
        sectionWith index: Int,
        _ position: TablePosition,
        sectionWith toIndex: Int,
        _ completion: (() -> Void)? = nil
    ) {
        
        guard
            let firstSection = dataSource.sectionIdentifier(for: index),
            let secondSection = dataSource.sectionIdentifier(for: toIndex)
        else {
            assert(false, "MulberryDataSource: moveSection failure")
            return
        }
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            switch position {
            case .before:
                snapshot.moveSection(firstSection, beforeSection: secondSection)
            case .after:
                snapshot.moveSection(firstSection, afterSection: secondSection)
            }
            self.dataSource.apply(snapshot) {
                completion?()
            }
        }
    }
    
    /// Moves the section from its current position in the snapshot to the position immediately before or after the specified section.
    /// - Parameters:
    ///   - section: The identifier of the section to move in the snapshot.
    ///   - position: Determines the position: before or after.
    ///   - toSection: The index of the section after which to move the specified section.
    ///   - completion: The block to execute after the updates.
    public func move(
        _ section: HashableSection,
        _ position: TablePosition,
        _ toSection: HashableSection,
        _ completion: (() -> Void)? = nil
    ) {
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            switch position {
            case .before:
                snapshot.moveSection(section, beforeSection: toSection)
            case .after:
                snapshot.moveSection(section, afterSection: toSection)
            }
            self.dataSource.apply(snapshot) {
                completion?()
            }
        }
    }
    
    /// Reloads the data within the specified sections of the snapshot.
    /// - Parameters:
    ///   - indexes: The array of indexes corresponding to the sections to reload in the snapshot.
    ///   - completion: The block to execute after the updates.
    public func reloadSections(
        at indexes: [Int],
        _ completion: (() -> Void)? = nil
    ) {
        
        let sections = indexes.compactMap {
            dataSource.sectionIdentifier(for: $0)
        }
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.reloadSections(sections)
            self.dataSource.apply(snapshot) {
                completion?()
            }
        }
    }
    
    /// Reloads the data within the specified sections of the snapshot.
    /// - Parameters:
    ///   - indexes: The array of identifiers corresponding to the sections to reload in the snapshot.
    ///   - completion: The block to execute after the updates.
    public func reloadSections(
        _ sections: [HashableSection],
        _ completion: (() -> Void)? = nil
    ) {
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.reloadSections(sections)
            self.dataSource.apply(snapshot) {
                completion?()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func configureItem(_ item: HashableItem) {
        registerItem(item)
        configureMutableItem(item)
        configureDeletableItem(item)
    }
    
    private func registerItem(_ item: HashableItem) {
        guard !registeredReuseIdentifiers.contains(item.viewModel.reuseIdentifier) else { return }
        
        if let cellClass = item.viewModel.cellClass {
            tableView.register(cellClass, forCellReuseIdentifier: item.viewModel.reuseIdentifier)
        } else if Bundle.main.path(forResource: item.viewModel.reuseIdentifier, ofType: "nib") != nil {
            tableView.register(UINib(nibName: item.viewModel.reuseIdentifier, bundle: .main), forCellReuseIdentifier: item.viewModel.reuseIdentifier)
        } else {
            fatalError(
                "MulberryDataSource: nib with name \"\(item.viewModel.reuseIdentifier)\" wasn't found"
            )
        }
        
        registeredReuseIdentifiers.insert(item.viewModel.reuseIdentifier)
    }
    
    private func configureMutableItem(_ item: HashableItem) {
        guard let viewModel = item.viewModel as? ItemViewModelMutable else { return }
        
        viewModel.onChange = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.dataSource.apply(self.dataSource.snapshot())
            }
        }
    }
    
    private func configureDeletableItem(_ item: HashableItem) {
        guard let viewModel = item.viewModel as? ItemViewModelDeletable else { return }
        
        viewModel.onDelete = { [weak self] in
            self?.removeItems([item])
        }
    }
    
    private func reload() {
        sections
            .flatMap { ($0.items + [$0.header]).compactMap { $0 } }
            .forEach { configureItem($0) }
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.deleteAllItems()
            snapshot.appendSections(self.sections)
            self.sections.forEach { snapshot.appendItems($0.items, toSection: $0) }
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    private func dequeueCell(_ withIdentifier: String) -> CellConfigurable? {
        tableView.dequeueReusableCell(withIdentifier: withIdentifier) as? CellConfigurable
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapSectionHeader(_ sender: ItemTapGesture) {
        sender.viewModel?.onTap?()
    }
    
    // MARK: - UITableViewDelegate Methods
    
    public func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        if shouldDeselect {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard let item = dataSource.itemIdentifier(for: indexPath)?.viewModel as? ItemViewModelTappable else {
            return
        }
        
        item.onTap?()
    }
    
    public func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        dataSource.itemIdentifier(for: indexPath)?.viewModel.itemHeight ?? UITableView.automaticDimension
    }
    
    public func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        
        guard
            let viewModel = dataSource.sectionIdentifier(for: section)?.header?.viewModel,
            let header = dequeueCell(viewModel.reuseIdentifier)
        else {
            return UIView(frame: .zero)
        }
        
        header.configure(with: viewModel)
        
        if let tappable = viewModel as? ItemViewModelTappable {
            let tapGestureRecognizer = ItemTapGesture(
                target: self,
                action: #selector(didTapSectionHeader)
            )
            tapGestureRecognizer.viewModel = tappable
            header.contentView.addGestureRecognizer(tapGestureRecognizer)
        }
        
        return header.contentView
    }
    
    
    public func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        
        dataSource.sectionIdentifier(for: section)?.header?.viewModel.itemHeight ?? .zero
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset: CGFloat = scrollView.contentOffset.y
        let maxOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height - edgeReachCompletionOffset
        let minOffset: CGFloat = edgeReachCompletionOffset
        
        if currentOffset > maxOffset {
            didReachBottom?()
        }
        
        if currentOffset < minOffset {
            didReachTop?()
        }
    }
    
}
