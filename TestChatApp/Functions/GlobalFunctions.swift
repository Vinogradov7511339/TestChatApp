//
//  GlobalFunctions.swift
//  TestChatApp
//
//  Created by Alexander Vinogradov on 26.10.2021.
//

import Foundation
import UIKit
import AVFoundation

func fileName(from path: String) -> String? {
    path.components(separatedBy: "_").last?
        .components(separatedBy: "?").first?
        .components(separatedBy: ".").first
}

func timeElapsed(_ date: Date) -> String {
    let delta = Date().timeIntervalSince(date)
    var elapsed: String = ""
    if delta < 60.0 {
        elapsed = "Just now"
    } else if delta < (60.0 * 60.0) {
        let minutes = Int(delta / 60.0)
        let text = minutes > 1 ? "mins" : "min"
        elapsed = "\(minutes) " + text
    } else if delta < (24 * 60.0 * 60.0) {
        let hours = Int(delta / 3600.0)
        let text = hours > 1 ? "hours" : "hour"
        elapsed = "\(hours) " + text
    } else {
        elapsed = date.longDate()
    }
    return elapsed
}

func videoThumbnail(pathToVideo: URL) -> UIImage {
    let asset = AVURLAsset(url: pathToVideo)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true

    let time = CMTimeMakeWithSeconds(1, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    var cgImage: CGImage?
    do {
        cgImage = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    } catch {
        assert(false, error.localizedDescription)
    }
    if let cgImage = cgImage {
        return UIImage(cgImage: cgImage)
    } else {
        return .imagePlaceholder!
    }
}
