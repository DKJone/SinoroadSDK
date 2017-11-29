//
//  UITableViewExt.swift
//  CommonUtil
//
//  Created by 朱德坤 on 2017/11/29.
//  Copyright © 2017年 sinoroad. All rights reserved.
//

import UIKit

// related article: http://alisoftware.github.io/swift/generics/2016/01/06/generic-tableviewcells/
// another implementation: https://github.com/AliSoftware/Reusable

/// You can register or dequeue `UITableViewCell` and `UICollectionViewCell` easier by conform to this protocol.
public protocol Reusable: class {
    /// The reuse identifier to use when registering and later dequeuing a reusable cell.
    static var reuseIdentifier: String { get }

    /// The nib file to use to load a new instance of the View designed in a XIB.
    static var nib: UINib? { get }
}

extension Reusable {
    // By default, use the name of the class as String for its reuseIdentifier.
    public static var reuseIdentifier: String { return String(describing: self) }
    // By default, return nil.
    public static var nib: UINib? { return nil }
}

// MARK: - UITableView
extension UITableView {

    /// Registers a class for use in creating new table cells.
    ///
    /// - Parameter cellClass: The class of a cell that you want to use in the table.
    public func registerReusableCell<T: UITableViewCell>(_ cellClass: T.Type) where T: Reusable {
        if let nib = cellClass.nib {
            register(nib, forCellReuseIdentifier: cellClass.reuseIdentifier)
        } else {
            register(cellClass, forCellReuseIdentifier: cellClass.reuseIdentifier)
        }
    }

    /// Returns a reusable table-view cell object for the specified Reusable type and adds it to the table.
    ///
    /// - Parameter indexPath: The index path specifying the location of the cell.
    /// - Returns: A valid UITableViewCell object.
    public func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: Reusable {
        return dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T // swiftlint:disable:this force_cast
    }

    /// Registers a class for use in creating new table header or footer views.
    ///
    /// - Parameter viewClass: The class of a header or footer view that you want to use in the table.
    public func registerReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) where T: Reusable {
        if let nib = viewClass.nib {
            register(nib, forHeaderFooterViewReuseIdentifier: viewClass.reuseIdentifier)
        } else {
            register(viewClass, forHeaderFooterViewReuseIdentifier: viewClass.reuseIdentifier)
        }
    }

    /// Returns a reusable header or footer view located by its Reusable type.
    ///
    /// - Returns: A valid UITableViewHeaderFooterView object or nil if no such object exists in the reusable view queue.
    public func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T? where T: Reusable {
        return dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! T? // swiftlint:disable:this force_cast
    }
}

// MARK: - UICollectionView
extension UICollectionView {

    /// Register UICollectionViewCell using class name.
    ///
    /// - Parameter cellClass: The class of a cell that you want to use in the collection view.
    public func registerReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type) where T: Reusable {
        if let nib = cellClass.nib {
            register(nib, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
        } else {
            register(cellClass, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
        }
    }

    /// Dequeue reusable UICollectionViewCell using class name.
    ///
    /// - Parameter indexPath: The index path specifying the location of the cell.
    /// - Returns: A valid UICollectionReusableView object.
    public func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: Reusable {
        return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T // swiftlint:disable:this force_cast
    }

    /// Register UICollectionReusableView using class name.
    ///
    /// - Parameters:
    ///   - viewClass: The class to use for the supplementary view.
    ///   - elementKind: The kind of supplementary view to create. This value is defined by the layout object.
    public func register<T: Reusable>(_ viewClass: T.Type, forSupplementaryViewOfKind elementKind: String) {
        if let nib = viewClass.nib {
            register(nib, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: viewClass.reuseIdentifier)
        } else {
            register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: viewClass.reuseIdentifier)
        }
    }

    /// Deque reusable UICollectionReusableView using class name.
    ///
    /// - Parameters:
    ///   - elementKind: The kind of supplementary view to retrieve. This value is defined by the layout object.
    ///   - indexPath: The index path specifying the location of the supplementary view in the collection view.
    /// - Returns: A valid UICollectionReusableView object.
    public func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind elementKind: String, for indexPath: IndexPath) -> T where T: Reusable {
        return dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T // swiftlint:disable:this force_cast
    }
}
