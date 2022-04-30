//
//  HeroBrowserDataImageViewModule.swift
//  HeroBrowser
//
//  Created by 逸风 on 2022/4/23.
//

import UIKit

public class HeroBrowserDataImageViewModule: HeroBrowserViewModule {
    public override func createCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> HeroBrowserCollectionCellProtocol {
        return collectionView.dequeueReusableCell(withReuseIdentifier: HeroBrowserBaseImageCell.identify(), for: indexPath) as! HeroBrowserBaseImageCell
    }
    
    public override func asyncLoadThumbailSource(with complete: HeroBrowserViewModule.Complete<UIImage>?) {
        DispatchQueue.global().async {
            guard let img = UIImage(data: self.imageData) else {
                DispatchQueue.main.async {
                    complete?(.failed(HeroError(errorMsg: "decode img data failed")))
                }
                return
            }
            DispatchQueue.main.async {
                complete?(.success(img))
            }
        }
    }
    
    public override func asyncLoadRawSource(with complete: HeroBrowserViewModule.Complete<UIImage>?) {
        DispatchQueue.global().async {
            guard let img = UIImage(data: self.imageData) else {
                DispatchQueue.main.async {
                    complete?(.failed(HeroError(errorMsg: "decode img data failed")))
                }
                return
            }
            DispatchQueue.main.async {
                complete?(.success(img))
            }
        }
    }
    
    var imageData: Data
    public init(data: Data) {
        self.imageData = data
        super.init(type: .dataImage)
    }
}
