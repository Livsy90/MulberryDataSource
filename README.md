# MulberryDataSource

A universal UITableViewDiffableDataSource wrapper that allows to fill your tableView with cells in a declarative manner, manage its contents and behavior.

[![License: MIT](https://img.shields.io/badge/License-MIT-black.svg)](https://opensource.org/licenses/MIT)

## MulberryDataSourceProtocol

```swift
public protocol MulberryDataSourceProtocol {
    
    /// Sections of the table view
    var sections: [HashableSection] { get set }
    
    /// Defines the offset to the edge of the table view at which the completion should be triggered.
    var edgeReachCompletionOffset: CGFloat { get set }
    
    /// Notifies when the top of the table view with a specified offset has been reached.
    var didReachTop: (() -> Void)? { get set }
    
    /// Notifies when the bottom of the table view with a specified offset has been reached.
    var didReachBottom: (() -> Void)? { get set }
    
    /// Defines the behavior of the table view cells after a tap.
    var shouldDeselect: Bool { get set }
    
    /// The type of animation to use when inserting or deleting rows.
    var rowAnimation: UITableView.RowAnimation { get set}
    
    /// Scrolls the table view content to the top.
    /// - Parameter animated: Turns animation on or off.
    func scrollToTop(animated: Bool)
    
    /// Scrolls the table view content to the bottom.
    /// - Parameters:
    ///   - scrollPosition: The position in the table view (top, middle, bottom) to scroll a specified row to.
    ///   - animated: Turns animation on or off.
    func scrollToBottom(at scrollPosition: UITableView.ScrollPosition, animated: Bool)
    
    /// Adds the sections with the specified identifiers to the snapshot.
    /// - Parameter sections: An array of identifiers specifying the sections to add to the snapshot.
    func appendSections(_ sections: [HashableSection])
    
    /// Adds the items with the specified identifiers to the specified section of the snapshot.
    /// - Parameters:
    ///   - items: An array of identifiers specifying the items to add to the snapshot.
    ///   - toSection: The section to which to add the items. If no value is provided, the items are appended to the last section of the snapshot.
    ///   - completion: The block to execute after the updates.
    func appendItems(_ items: [HashableItem], toSection: HashableSection?, _ completion: (() -> Void)?)
    
    /// Deletes the items at the specified index paths.
    /// - Parameters:
    ///   - indexPaths: An array of NSIndexPath objects, each of which contains a section index and item index for the item you want to delete from the table view
    ///   - completion: The block to execute after the updates.
    func removeAt(_ indexPaths: [IndexPath], _ completion: (() -> Void)?)
    
    /// Deletes the items with the specified identifiers.
    /// - Parameters:
    ///   - items: The array of identifiers corresponding to the items to delete from the snapshot.
    ///   - completion: The block to execute after the updates.
    func removeItems(_ items: [HashableItem], _ completion: (() -> Void)?)
    
    /// Inserts the provided items immediately before or after the item with the specified index path.
    /// - Parameters:
    ///   - items: The array of identifiers corresponding to the items to add to the snapshot.
    ///   - position: Determines the position: before or after.
    ///   - indexPath: The index path of the item before or after which to insert the new items.
    ///   - completion: The block to execute after the updates.
    func insertItems(_ items: [HashableItem], _ position: TablePosition, _ indexPath: IndexPath, _ completion: (() -> Void)?)
    
    /// Inserts the provided items immediately before or after the item with the specified indentifier.
    /// - Parameters:
    ///   - items: The array of identifiers corresponding to the items to add to the snapshot.
    ///   - position: Determines the position: before or after.
    ///   - item: The identifier of the item before or after which to insert the new items.
    ///   - completion: The block to execute after the updates.
    func insertItems(_ items: [HashableItem], _ position: TablePosition, _ item: HashableItem, _ completion: (() -> Void)?)
    
    /// Deletes all of the items from the snapshot.
    /// - Parameter completion: The block to execute after the updates.
    func removeAll(_ completion: (() -> Void)?)
    
    /// Moves the item from its current position in the snapshot to the position immediately before or after the specified item.
    /// - Parameters:
    ///   - indexPath: The index path of the item to move in the snapshot.
    ///   - position: Determines the position: before or after.
    ///   - toIndexPath: The index path  of the item after which to move the specified item.
    ///   - completion: The block to execute after the updates.
    func move(itemAt indexPath: IndexPath, _ position: TablePosition, itemAt toIndexPath: IndexPath, _ completion: (() -> Void)?)
    
    /// Moves the item from its current position in the snapshot to the position immediately before or after the specified item.
    /// - Parameters:
    ///   - item: The identifier of the item to move in the snapshot.
    ///   - position: Determines the position: before or after.
    ///   - toItem: The identifier of the item after which to move the specified item.
    ///   - completion: The block to execute after the updates.
    func move(_ item: HashableItem, _ position: TablePosition, _ toItem: HashableItem, _ completion: (() -> Void)?)
    
    /// Moves the section from its current position in the snapshot to the position immediately before or after the specified section.
    /// - Parameters:
    ///   - index: The index of the section to move in the snapshot.
    ///   - position: Determines the position: before or after.
    ///   - toIndex: The index of the section after which to move the specified section.
    ///   - completion: The block to execute after the updates.
    func move(sectionWith index: Int, _ position: TablePosition, sectionWith toIndex: Int,_ completion: (() -> Void)?)
    
    /// Moves the section from its current position in the snapshot to the position immediately before or after the specified section.
    /// - Parameters:
    ///   - section: The identifier of the section to move in the snapshot.
    ///   - position: Determines the position: before or after.
    ///   - toSection: The index of the section after which to move the specified section.
    ///   - completion: The block to execute after the updates.
    func move(_ section: HashableSection, _ position: TablePosition, _ toSection: HashableSection, _ completion: (() -> Void)?)
    
    /// Reloads the data within the specified items in the snapshot.
    /// - Parameters:
    ///   - indexPaths: The array of index paths corresponding to the items to reload in the snapshot.
    ///   - completion: The block to execute after the updates.
    func reloadItems(at indexPaths: [IndexPath], _ completion: (() -> Void)?)
    
    /// Reloads the data within the specified items in the snapshot.
    /// - Parameters:
    ///   - indexPaths: The array of identifiers corresponding to the items to reload in the snapshot.
    ///   - completion: The block to execute after the updates.
    func reloadItems(_ items: [HashableItem], _ completion: (() -> Void)?)
    
    /// Reloads the data within the specified sections of the snapshot.
    /// - Parameters:
    ///   - indexes: The array of indexes corresponding to the sections to reload in the snapshot.
    ///   - completion: The block to execute after the updates.
    func reloadSections(at indexes: [Int], _ completion: (() -> Void)?)
    
    /// Reloads the data within the specified sections of the snapshot.
    /// - Parameters:
    ///   - indexes: The array of identifiers corresponding to the sections to reload in the snapshot.
    ///   - completion: The block to execute after the updates.
    func reloadSections(_ sections: [HashableSection], _ completion: (() -> Void)?)
    
}

```

## Example

```swift 

class ViewController: UIViewController {
    let viewModel: ViewModel = .init()
    let tableView: UITableView = .init()
    lazy var dataSource: MulberryDataSourceProtocol = MulberryDataSource(tableView: tableView)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.onGetData = { [weak self] sections in
            self?.dataSource.sections = sections
        }
    }
}

class ViewModel {
    let service: Service = .init()
    var onGetData: (([HashableSection]) -> Void)?
    
    func getData() {
        service.getData { [weak self] data in
            guard let self else { return }
            
            let items = data.map {
                self.buildItem(with: $0)
            }
            let sections = [HashableSection(items: items)]
            self.onGetData?(sections)
        }
    }
    
    func buildItem(with data: Model) -> HashableItem {
        let item = ItemViewModel(data: data)
        item.onTap = {
            print(data.title)
        }
        
        return item.hashable
    }
}

class Cell: UITableViewCell, CellConfigurable {
    func configure(with viewModel: ItemViewModelProtocol) {
        guard let viewModel = viewModel as? ItemViewModel else {
            return
        }
    }
}

class ItemViewModel: NSObject, ItemViewModelTappable {
    var cellClass: UITableViewCell.Type? { Cell.self }
    var reuseIdentifier: String { String(describing: Cell.self) }
    var onTap: (() -> Void)?
    
    let data: Model
    
    init(data: Model) {
        self.data = data
    }
}

class Service {
    func getData(_ completion: (([Model]) -> Void)?) {
        completion?([Model(title: "Title")])
    }
}

struct Model {
    var title: String
}
```

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/Livsy90/MulberryDataSource.git")
]
```

## Requirements

* iOS 15+
* Xcode 14+
