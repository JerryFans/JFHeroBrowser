//
//  HeroBrowserViewModule.swift
//  Example
//
//  Created by 逸风 on 2021/8/4.
//

import UIKit

public enum HeroBrowserType {
    case unknown
    case networkImage
    case localImage
    case dataImage
    case networkVideo
    case localVideo  //file path video
    case assetVideo // Album Asset Video Source
    case assetImage // Album Asset Image Source
}

public enum Result<T> {
    case success(_ data: T)
    case progress(_ progress: CGFloat)
    case failed(_ error: Error?)
}

public protocol NetworkImageProvider: AnyObject {
    typealias Complete<T> = (Result<T>) -> ()
    func downloadImage(with imgUrl: String, complete: Complete<UIImage>?)
}

public protocol HeroBrowserViewModuleBaseProtocol {
    var type: HeroBrowserType { get set }
    func createCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> HeroBrowserCollectionCellProtocol
}

public protocol HeroBrowserViewModuleProtocol: HeroBrowserViewModuleBaseProtocol {
    associatedtype ThumbailData
    associatedtype RawData
    typealias Complete<T> = (Result<T>) -> ()
    func asyncLoadThumbailSource(with complete: Complete<ThumbailData>?)
    func asyncLoadRawSource(with complete: Complete<RawData>?)
}

open class HeroBrowserViewModule: HeroBrowserViewModuleProtocol {
    public typealias ThumbailData = UIImage
    public typealias RawData = UIImage
    public var type: HeroBrowserType
    public func asyncLoadThumbailSource(with complete: Complete<UIImage>?) {
        complete?(.failed(nil))
    }
    public func asyncLoadRawSource(with complete: Complete<UIImage>?) {
        complete?(.failed(nil))
    }
    public init(type: HeroBrowserType) {
        self.type = type
    }
    public func createCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> HeroBrowserCollectionCellProtocol {
        return collectionView.dequeueReusableCell(withReuseIdentifier: HeroBrowserBaseImageCell.identify(), for: indexPath) as! HeroBrowserBaseImageCell
    }
}

extension HeroBrowserViewModule: HeroCompatible {}
extension Hero where Base: HeroBrowserViewModule {
    static func localImageVM(image: UIImage) -> HeroBrowserViewModule {
        return HeroBrowserLocalImageViewModule(image: image)
    }
}
