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
    
    public typealias InsertHandler = (
        _ at: IndexPath,
        _ items: [HashableItem],
        _ completion: @escaping () -> Void
    ) -> Void
    
    public typealias DeleteHandler = (
        _ at: [IndexPath],
        _ completion: @escaping () -> Void
    ) -> Void
    
    private typealias TableDataSource = UITableViewDiffableDataSource<HashableSection, HashableItem>
    
    private final class ItemTapGesture: UITapGestureRecognizer {
        var viewModel: ItemViewModelTappable?
    }
    
    // MARK: - Public Properties
    
    public var didReachTop: (() -> Void)?
    public var didReachBottom: (() -> Void)?
    public var sections: [HashableSection] = [] {
        didSet {
            reload()
        }
    }
    
    // MARK: - Private Properties
    
    private let rowAnimation: UITableView.RowAnimation
    private let edgeReachCompletionOffset: CGFloat
    private let shouldDeselectRowAfterTap: Bool
    private var registeredReuseIdentifiers: Set<String> = .init()
    private var tableView: UITableView {
        didSet {
            registeredReuseIdentifiers.removeAll()
        }
    }
    private lazy var dataSource: TableDataSource = {
        let datasource = TableDataSource(
            tableView: tableView,
            cellProvider: { [weak self] _, _, item -> UITableViewCell? in
                if let cell = self?.dequeueCell(item.viewModel.reuseIdentifier) {
                    cell.configure(item.viewModel)
                    return cell
                }
                return .init()
            })
        datasource.defaultRowAnimation = rowAnimation
        
        return datasource
    }()
    
    // MARK: - Init
    
    public init(
        tableView: UITableView,
        rowAnimation: UITableView.RowAnimation = .fade,
        shouldDeselectRowAfterTap: Bool = true,
        edgeReachCompletionOffset: CGFloat = 60
    ) {
        
        self.tableView = tableView
        self.rowAnimation = rowAnimation
        self.shouldDeselectRowAfterTap = shouldDeselectRowAfterTap
        self.edgeReachCompletionOffset = edgeReachCompletionOffset
        
        super.init()
        
        self.tableView.delegate = self
        self.tableView.allowsSelection = true
    }
    
    // MARK: - Public Methods
    
    public func scrollToTop(animated: Bool) {
        DispatchQueue.main.async {
            self.tableView.setContentOffset(.zero, animated: animated)
        }
    }
    
    public func scrollToBottom(animated: Bool) {
        let section: Int = sections.count - 1
        let lastItemIndex: Int = sections[safe: section]?.items.count ?? 0
        let row: Int = lastItemIndex - 1
        
        guard row >= 0 else {
            return
        }
        
        DispatchQueue.main.async {
            let indexPath: IndexPath = .init(row: row, section: section)
            self.tableView.scrollToRow(
                at: indexPath,
                at: .bottom,
                animated: animated
            )
        }
    }
    
    public func appendSections(_ sections: [HashableSection]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot)
    }
    
    public func appendItems(
        _ items: [HashableItem],
        toSection: HashableSection,
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
    
    public func insertItems(
        _ items: [HashableItem],
        afterItemAt indexPath: IndexPath,
        _ completion: (() -> Void)? = nil
    ) {
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            assert(false, "MulberryDataSource: insertItems failure")
            return
        }
        
        items.forEach(configureItem)
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.insertItems(items, afterItem: item)
            self.dataSource.apply(snapshot) {
                completion?()
            }
        }
    }
    
    public func insertItems(
        _ items: [HashableItem],
        beforeItemAt indexPath: IndexPath,
        _ completion: (() -> Void)? = nil
    ) {
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            assert(false, "MulberryDataSource: insertItems failure")
            return
        }

        items.forEach(configureItem)
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.insertItems(items, beforeItem: item)
            self.dataSource.apply(snapshot) {
                completion?()
            }
        }
    }
    
    public func insertAfterItem(
        _ item: HashableItem,
        items: [HashableItem],
        _ completion: (() -> Void)? = nil
    ) {
        
        items.forEach(configureItem)
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.insertItems(items, afterItem: item)
            self.dataSource.apply(snapshot) {
                completion?()
            }
        }
    }
    
    public func insertBeforeItem(
        _ item: HashableItem,
        items: [HashableItem],
        _ completion: (() -> Void)?
    ) {
        
        items.forEach(configureItem)
        
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.insertItems(items, beforeItem: item)
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
        }
        else {
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
        
        if shouldDeselectRowAfterTap {
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
        
        header.configure(viewModel)
        
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
