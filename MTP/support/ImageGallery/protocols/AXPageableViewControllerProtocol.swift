// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXPageableViewControllerProtocol.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 6/4/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

protocol AXPageableViewControllerProtocol: AnyObject {

    var pageIndex: Int { get set }

    func prepareForReuse()
    //func prepareForRecycle()
}
