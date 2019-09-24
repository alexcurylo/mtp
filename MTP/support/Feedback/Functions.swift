// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import AVFoundation
import MobileCoreServices
import UIKit

func getMediaFromImagePickerInfo(_ info: [String: Any]) -> Media? {
    let imageType = kUTTypeImage as String
    let movieType = kUTTypeMovie as String

    switch info[convertFromUIImagePickerControllerInfoKey(.mediaType)] as? String {
    case imageType?:
        guard let image = info[convertFromUIImagePickerControllerInfoKey(.originalImage)] as? UIImage
            else { return .none }
        return .image(image)
    case movieType?:
        guard let url = info[convertFromUIImagePickerControllerInfoKey(.mediaURL)] as? URL else { return .none }
        return getMediaFromURL(url)
    default:
        return .none
    }
}

func getMediaFromURL(_ url: URL) -> Media? {
    let asset = AVURLAsset(url: url)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    let time = CMTimeMake(value: 1, timescale: 1)
    guard let cgImage = try? generator.copyCGImage(at: time, actualTime: .none)
        else { return .none }
    return .video(UIImage(cgImage: cgImage), url)
}

func push<Item>(_ item: Item?) -> (((Item) -> Void) -> Void)? {
    guard let item = item else { return .none }
    return { closure in closure(item) }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
