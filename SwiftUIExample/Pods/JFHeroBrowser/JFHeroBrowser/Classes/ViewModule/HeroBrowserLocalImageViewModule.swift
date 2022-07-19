//
//  HeroBrowserLocalImageViewModule.swift
//  HeroBrowser
//
//  Created by 逸风 on 2021/10/29.
//

import Foundation

public class HeroBrowserLocalImageViewModule: HeroBrowserViewModule {
    
    public override func createCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> HeroBrowserCollectionCellProtocol {
        return collectionView.dequeueReusableCell(withReuseIdentifier: HeroBrowserBaseImageCell.identify(), for: indexPath) as! HeroBrowserBaseImageCell
    }
    
    public override func asyncLoadThumbailSource(with complete: HeroBrowserViewModule.Complete<UIImage>?) {
        complete?(.success(self.image))
    }
    
    public override func asyncLoadRawSource(with complete: HeroBrowserViewModule.Complete<UIImage>?) {
        complete?(.success(self.image))
    }
    
    var image: UIImage
    public init(image: UIImage) {
        self.image = image
        super.init(type: .localImage)
    }
}
