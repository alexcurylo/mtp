// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXPageableViewControllerProtocol.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 6/4/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

/// AXPageableViewControllerProtocol
protocol AXPageableViewControllerProtocol: AnyObject {

    /// Page index
    var pageIndex: Int { get set }

    /// Prepare for reuse
    func prepareForReuse()
}
