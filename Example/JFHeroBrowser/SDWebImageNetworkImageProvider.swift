//
//  SDWebImageNetworkImageProvider.swift
//  JFHeroBrowser_Example
//
//  Created by 逸风 on 2022/5/1.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import JFHeroBrowser

extension SDWebImageNetworkImageProvider: NetworkImageProvider {
    func downloadImage(with imgUrl: String, complete: Complete<UIImage>?) {
        SDWebImageManager.shared.loadImage(with: URL(string: imgUrl)) { receiveSize, totalSize, url in
            guard totalSize > 0 else { return }
            let progress:CGFloat = CGFloat(CGFloat(receiveSize) / CGFloat(totalSize))
            complete?(.progress(progress))
        } completed: { image, data, error, _, isfinished, url in
            if let error = error {
                complete?(.failed(error))
            } else if let image = image {
                complete?(.success(image))
            } else {
                complete?(.failed(nil))
            }
        }
    }
}

class SDWebImageNetworkImageProvider: NSObject {
    @objc static let shared = SDWebImageNetworkImageProvider()
}
