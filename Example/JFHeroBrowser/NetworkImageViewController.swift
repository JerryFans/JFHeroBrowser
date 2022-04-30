//
//  NetworkImageViewController.swift
//  JFHeroBrowser_Example
//
//  Created by 逸风 on 2022/4/30.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import JFHeroBrowser

let thumbs: [String] = {
    var temp: [String] = []
    for i in 1...20 {
        temp.append("http://image.jerryfans.com/template-\(i).jpg?imageView2/0/w/300")
    }
    return temp
}()

let origins: [String] = {
    var temp: [String] = []
    for i in 1...20 {
        temp.append("http://image.jerryfans.com/template-\(i).jpg")
    }
    return temp
}()

class NetworkImageCollectionViewCell: UICollectionViewCell {
    
    var imageUrl: String? {
        didSet {
            guard let imageUrl = imageUrl else {
                return
            }
            self.imageView.kf.setImage(with: URL(string: imageUrl))
        }
    }
    
    lazy var imageView: UIImageView = {
        let imgV = UIImageView()
        imgV.contentMode = .scaleAspectFill
        imgV.clipsToBounds = true
        return imgV
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.imageView.frame = frame
        self.addSubview(self.imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func identify() -> String {
        return "NetworkImageCollectionViewCell"
    }
}

class NetworkImageViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = (CGSize.jf.screenWidth() - 15 * 4) / 3
        layout.itemSize = CGSize(width: floor(width), height: floor(width))
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.scrollDirection = .vertical
        let v = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        v.backgroundColor = .white
        v.delegate = self
        v.dataSource = self
        v.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        v.register(NetworkImageCollectionViewCell.self, forCellWithReuseIdentifier: NetworkImageCollectionViewCell.identify())
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "NetworkImage"
        self.view.backgroundColor = .white
        self.view.addSubview(self.collectionView)
        
    }
    
    @objc func videoBtnClick(button: UIButton) {
        let brower = HeroBrowser(viewModules: [HeroBrowserVideoViewModule(thumbailImgUrl: "http://image.jerryfans.com/w_720_h_1280_d_41_89fd26217dc299a442363581deb75b90_iOS_0.jpg", videoUrl: "http://image.jerryfans.com/w_720_h_1280_d_41_2508b8aa06a2e30d2857f9bcbdfd1de0_iOS.mp4", provider: HeroNetworkImageProvider.shared)], index: button.tag, heroImageView: button.imageView)
        brower.show(with: self, animationType: .hero)
    }
    
}

extension NetworkImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return origins.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NetworkImageCollectionViewCell.identify(), for: indexPath) as! NetworkImageCollectionViewCell
        cell.imageUrl = origins[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard thumbs.count == origins.count else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? NetworkImageCollectionViewCell else { return }
        var list: [HeroBrowserViewModule] = []
        for i in 0..<thumbs.count {
            list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: thumbs[i], originImgUrl: origins[i], provider: HeroNetworkImageProvider.shared))
        }
        
        let brower = HeroBrowser(viewModules: list, index: indexPath.item, heroImageView: cell.imageView) { [weak self] imageIndex in
            guard let self = self else { return nil }
            guard let cell = self.collectionView.cellForItem(at: IndexPath(item: imageIndex, section: 0)) as? NetworkImageCollectionViewCell else { return nil }
            return cell.imageView
        }
        brower.show(with: self, animationType: .hero)
    }
    
}
