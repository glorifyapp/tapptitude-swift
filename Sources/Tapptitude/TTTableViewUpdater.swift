//
//  TTTableViewUpdater.swift
//  Tapptitude
//
//  Created by Ion Toderasco on 11/11/2018.
//  Copyright © 2018 Tapptitude. All rights reserved.
//

import UIKit

public struct TTRowAnimationConfig {
    public var itemsReload: UITableView.RowAnimation
    public var itemsDelete: UITableView.RowAnimation
    public var itemsInsert: UITableView.RowAnimation
    public var sectionsReload: UITableView.RowAnimation
    public var sectionsDelete: UITableView.RowAnimation
    public var sectionsInsert: UITableView.RowAnimation
    
    public init(itemsReload: UITableView.RowAnimation = .automatic,
                itemsDelete: UITableView.RowAnimation = .automatic,
                itemsInsert: UITableView.RowAnimation = .automatic,
                sectionsReload: UITableView.RowAnimation = .automatic,
                sectionsDelete: UITableView.RowAnimation = .automatic,
                sectionsInsert: UITableView.RowAnimation = .automatic) {
        
        self.itemsReload = itemsReload
        self.itemsDelete = itemsDelete
        self.itemsInsert = itemsInsert
        self.sectionsReload = sectionsReload
        self.sectionsDelete = sectionsDelete
        self.sectionsInsert = sectionsInsert
    }
}

protocol TTTableViewUpdater {    
    func tableViewWillChangeContent(_ tableView: UITableView)
    func tableViewDidChangeContent(_ tableView: UITableView, animationCompletion: (() -> Void)?)
    
    
    func tableView(_ tableView: UITableView, didUpdateItemsAt indexPaths: [IndexPath])
    func tableView(_ tableView: UITableView, didDeleteItemsAt indexPaths: [IndexPath])
    func tableView(_ tableView: UITableView, didInsertItemsAt indexPaths: [IndexPath])
    
    func tableView(_ tableView: UITableView, didMoveItemsFrom fromIndexPaths: [IndexPath], to toIndexPaths: [IndexPath])
    
    func tableView(_ tableView: UITableView, didInsertSections sections: IndexSet)
    func tableView(_ tableView: UITableView, didDeleteSections sections: IndexSet)
    func tableView(_ tableView: UITableView, didUpdateSections sections: IndexSet)
}

class TableViewUpdater: TTTableViewUpdater {
        
    fileprivate var shouldReloadCollectionView = false
    fileprivate var batchOperation: [() -> Void]?
    
    var animatesUpdates: Bool = true
    var animationConfig: TTRowAnimationConfig
    
    init(animatesUpdates: Bool, animationConfig: TTRowAnimationConfig = TTRowAnimationConfig()) {
        self.animatesUpdates = animatesUpdates
        self.animationConfig = animationConfig
    }
    
    func tableViewWillChangeContent(_ tableView: UITableView) {
        shouldReloadCollectionView = false
        assert(batchOperation == nil, "Updating block operation should be nil");
        batchOperation = []
    }
    
    func tableViewDidChangeContent(_ tableView: UITableView, animationCompletion: (() -> Void)?) {
        defer {
            self.batchOperation = nil
        }
        
        // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
        let noChanges = (batchOperation == nil || batchOperation?.isEmpty == true)
        
        if (shouldReloadCollectionView || noChanges) {
            tableView.reloadData()
            animationCompletion?()
        } else {
            if animatesUpdates {
                if #available(iOS 11.0, *) {
                    tableView.performBatchUpdates({
                        self.batchOperation?.forEach{ $0() }
                    }, completion: { finished in
                        animationCompletion?()
                    })
                } else {
                    tableView.beginUpdates()
                    self.batchOperation?.forEach{ $0() }
                    tableView.endUpdates()
                    animationCompletion?()
                }
            } else {
                UIView.performWithoutAnimation {
                    self.batchOperation?.forEach{ $0() }
                    animationCompletion?()
                }
            }
        }
    }
    
    
    // MARK: - items operation
    func tableView(_ tableView: UITableView, didUpdateItemsAt indexPaths: [IndexPath]) {
        let config = self.animationConfig
        batchOperation?.append({
            tableView.reloadRows(at: indexPaths, with: config.itemsReload)
        })
    }
    
    func tableView(_ tableView: UITableView, didDeleteItemsAt indexPaths: [IndexPath]) {
        guard let indexPath = indexPaths.last else {
            return
        }
        
        if tableView.numberOfRows(inSection: indexPath.section) == 1 {
            shouldReloadCollectionView = true
        } else {
            let config = self.animationConfig
            batchOperation?.append({
                tableView.deleteRows(at: indexPaths, with: config.itemsDelete)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didInsertItemsAt indexPaths: [IndexPath]) {
        if tableView.numberOfSections > 0 {
            let config = self.animationConfig
            batchOperation?.append({
                tableView.insertRows(at: indexPaths, with: config.itemsInsert)
            })
        } else {
            shouldReloadCollectionView = true
        }
    }
    
    func tableView(_ tableView: UITableView, didMoveItemsFrom fromIndexPaths: [IndexPath], to toIndexPaths: [IndexPath]) {
        batchOperation?.append({
            fromIndexPaths.enumerated().forEach({ (index, indexPath) in
                let toIndexPath = toIndexPaths[index]
                tableView.moveRow(at: indexPath, to: toIndexPath)
            })
        })
    }
    
    func tableView(_ tableView: UITableView, didInsertSections sections: IndexSet) {
        let config = self.animationConfig
        batchOperation?.append({
            tableView.insertSections(sections, with: config.sectionsInsert)
        })
    }
    
    func tableView(_ tableView: UITableView, didDeleteSections sections: IndexSet) {
        let config = self.animationConfig
        batchOperation?.append({
            tableView.deleteSections(sections, with: config.sectionsDelete)
        })
    }
    
    func tableView(_ tableView: UITableView, didUpdateSections sections: IndexSet) {
        let config = self.animationConfig
        batchOperation?.append({
            tableView.reloadSections(sections, with: config.sectionsReload)
        })
    }
}
