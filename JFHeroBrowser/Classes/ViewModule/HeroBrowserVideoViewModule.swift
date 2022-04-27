//
//  HeroBrowserVideoViewModule.swift
//  HeroBrowser
//
//  Created by 逸风 on 2022/4/24.
//

import UIKit

/// Video VM, support network video or local file path video
public class HeroBrowserVideoViewModule: HeroBrowserViewModuleProtocol {
    
    public typealias ThumbailData = UIImage
    public typealias RawData = URL
    public var type: HeroBrowserType
    
    public func asyncLoadThumbailSource(with complete: Complete<UIImage>?) {
        guard let thumbailImgUrl = self.thumbailImgUrl else {
            complete?(.failed(nil))
            return
        }
        self.imageProvider?.downloadImage(with: thumbailImgUrl, complete: {
            switch $0 {
            case let .success(image):
                complete?(.success(image))
                break
            case let .failed(error):
                complete?(.failed(error))
                break
            case let .progress(progress):
                complete?(.progress(progress))
                break
            }
        })
    }
    
    public func asyncLoadRawSource(with complete: Complete<URL>?) {
        guard let url = self.videoURL else {
            complete?(.failed(nil))
            return
        }
        complete?(.success(url))
    }
    
    public func createCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> HeroBrowserCollectionCellProtocol {
        return collectionView.dequeueReusableCell(withReuseIdentifier: HeroBrowserVideoCell.identify(), for: indexPath) as! HeroBrowserVideoCell
    }
    
    public weak var imageProvider: NetworkImageProvider?
    var thumbailImgUrl: String?
    var videoURL: URL?
    
    public init(thumbailImgUrl: String?, fileUrlPath: String, provider: NetworkImageProvider?) {
        self.thumbailImgUrl = thumbailImgUrl
        self.videoURL = URL(fileURLWithPath: fileUrlPath)
        self.imageProvider = provider
        self.type = .localVideo
    }
    
    public init(thumbailImgUrl: String?, videoUrl: String, provider: NetworkImageProvider?) {
        self.thumbailImgUrl = thumbailImgUrl
        self.videoURL = URL(string: videoUrl)
        self.imageProvider = provider
        self.type = .networkVideo
    }
}
