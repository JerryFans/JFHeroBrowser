//
//  HeroBrowserNetworkImageViewModule.swift
//  HeroBrowser
//
//  Created by 逸风 on 2021/10/29.
//

import Foundation
import Kingfisher

public class HeroBrowserNetworkImageViewModule: HeroBrowserViewModule, NetworkImageProvider {
    
    deinit {
        print("HeroBrowserNetworkImageViewModule deinit")
    }
    
    public override func createCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> HeroBrowserCollectionCellProtocol {
        return collectionView.dequeueReusableCell(withReuseIdentifier: HeroBrowserNetworkImageCell.identify(), for: indexPath) as! HeroBrowserNetworkImageCell
    }
    
    public override func asyncLoadThumbailSource(with complete: HeroBrowserViewModule.Complete<UIImage>?) {
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
    
    public override func asyncLoadRawSource(with complete: HeroBrowserViewModule.Complete<UIImage>?) {
        self.imageProvider?.downloadImage(with: self.originImgUrl, complete: {
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
    
    public weak var imageProvider: NetworkImageProvider?
    var thumbailImgUrl: String?
    var originImgUrl: String
    
    public init(thumbailImgUrl: String?, originImgUrl: String, provider: NetworkImageProvider? = nil) {
        self.thumbailImgUrl = thumbailImgUrl
        self.originImgUrl = originImgUrl
        self.imageProvider = provider
        super.init(type: .networkImage)
        if provider == nil {
            self.imageProvider = self
        }
    }
    
    public func downloadImage(with imgUrl: String, complete: Complete<UIImage>?) {
        KingfisherManager.shared.retrieveImage(with: URL(string: imgUrl)!, options: nil) { receiveSize, totalSize in
            guard totalSize > 0 else { return }
            let progress:CGFloat = CGFloat(CGFloat(receiveSize) / CGFloat(totalSize))
            complete?(.progress(progress))
        } downloadTaskUpdated: { task in
            
        } completionHandler: { result in
            switch result {
            case .success(let loadingImageResult):
                complete?(.success(loadingImageResult.image))
                break
            case .failure(let error):
                complete?(.failed(error))
                break
            }
        }
    }
}
