// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXDispatchUtils.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 6/16/18.
//

import Foundation

enum AXDispatchUtils {

    static func executeInBackground(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            DispatchQueue.global().async(execute: block)
        } else {
            block()
        }
    }
}
