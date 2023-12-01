//
//  UITableView+Scroll.swift
//
//
//  Created by Livsy on 01.12.2023.
//

import UIKit

extension UITableView {
    func scrollToBottom(at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection: self.numberOfSections - 1) - 1,
                section: self.numberOfSections - 1
            )
            
            guard self.hasRowAt(indexPath: indexPath) else {
                return
            }
            
            self.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
        }
    }
    
    fileprivate func hasRowAt(indexPath: IndexPath) -> Bool {
        indexPath.section < numberOfSections && indexPath.row < numberOfRows(inSection: indexPath.section)
    }
}
