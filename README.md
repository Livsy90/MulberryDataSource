# MulberryDataSource

A universal UITableViewDiffableDataSource wrapper that allows to fill your tableView with cells in a declarative manner, manage its contents and behavior.

## Example

```swift 

final class Cell: UITableViewCell, CellConfigurable {
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
    
    let data: ServerResponce
    
    init(data: ServerResponce) {
        self.data = data
    }
}

struct ServerResponce { 

}

class ApiService {
    func getData(_ completion: (([ServerResponce]) -> Void)?) {
        completion?([])
    }
}

class ViewModel {
    let apiService: ApiService = .init()
    var onGetData: (([HashableSection]) -> Void)?
    
    func getData() {
        apiService.getData { [weak self] data in
            guard let self else { return }
            
            let items = data.map {
                self.buildItem(with: $0)
            }
            let sections = [HashableSection(items: items)]
            self.onGetData?(sections)
        }
    }
    
    func buildItem(with data: ServerResponce) -> HashableItem {
        let item = ItemViewModel(data: data)
        item.onTap = {
            print("")
        }
        
        return item.hashable
    }
}

class ViewController: UIViewController {
    let viewModel: ViewModel = .init()
    let tableView = UITableView()
    lazy var dataSource = MulberryDataSource(tableView: tableView)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.onGetData = { [weak self] sections in
            self?.dataSource.sections = sections
        }
    }
}

```
