//
//  NetworkImageViewController.swift
//  JFHeroBrowser_Example
//
//  Created by 逸风 on 2022/4/30.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import JFHeroBrowser
import JFPopup

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
    
    var isUseSDWebImage = false
    
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
        self.title = "NetworkImage" + (isUseSDWebImage ? "(SDWebImage)" : "(KingFisher)")
        self.view.backgroundColor = .white
        self.view.addSubview(self.collectionView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = self.view.bounds
    }
    
}

extension NetworkImageViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (CGSize.jf.screenWidth() - 15 * 4) / 3
        return CGSize(width: floor(width), height: floor(width))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NetworkImageCollectionViewCell.identify(), for: indexPath) as! NetworkImageCollectionViewCell
        let imageUrl = thumbs[indexPath.item]
        if isUseSDWebImage {
            cell.imageView.sd_setImage(with: URL(string: imageUrl))
        } else {
            cell.imageView.kf.setImage(with: URL(string: imageUrl))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard thumbs.count == origins.count else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? NetworkImageCollectionViewCell else { return }
        var list: [HeroBrowserViewModule] = []
        for i in 0..<origins.count {
            if isUseSDWebImage {
                //你也可以不使用全局参数缓存，每次调用 动态配置provider
                list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: thumbs[i], originImgUrl: origins[i], provider: SDWebImageNetworkImageProvider.shared))
            } else {
                //我们不内置图片缓存， 必须设置一个全局缓存 不然程序会crash Kingfisher or SDWebImage or 你自定义图片缓存 都可以。 只需实现NetworkImageProvider协议
                //这里无需再设置provider ，appdelegate 已初始化 JFHeroBrowserGlobalConfig.default.networkImageProvider = HeroNetworkImageProvider.shared (Kingfisher)
                list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: thumbs[i], originImgUrl: origins[i]))
            }
        }
        // quickly hero mode in swift
        self.hero.browserPhoto(viewModules: list, initIndex: indexPath.item) {
            [
                .pageControlType(.pageControl),
                .heroView(cell.imageView),
                .heroBrowserDidLongPressHandle({ [weak self] heroBrowser,vm  in
                    self?.longPressHandle(vm: vm)
                }),
                .imageDidChangeHandle({ [weak self] imageIndex in
                    guard let self = self else { return nil }
                    guard let cell = self.collectionView.cellForItem(at: IndexPath(item: imageIndex, section: 0)) as? NetworkImageCollectionViewCell else { return nil }
                    let rect = cell.convert(cell.imageView.frame, to: self.view)
                    if self.view.frame.contains(rect) {
                        return cell.imageView
                    }
                    return nil
                })
            ]
        }
    }
    
    func longPressHandle(vm: HeroBrowserViewModuleBaseProtocol) {
        //保存图片 actionSheet 使用我另一个库 JFPopup 实现，有兴趣欢迎star.
        JFPopupView.popup.actionSheet {
            [
                JFPopupAction(with: "保存", subTitle: nil) {
                    if let imgVM = vm as? HeroBrowserViewModule {
                        imgVM.asyncLoadRawSource { result in
                            switch result {
                            case let .success(image):
                                print(image)
                                //还需请求权限，这里就不演示了
                                //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                JFPopupView.popup.toast(hit: "保存图片成功（只做演示无功能）")
                                break
                            case _ :
                                break
                            }
                        }
                    }
                },
                JFPopupAction(with: "分享", subTitle: nil, clickActionCallBack: {
                    JFPopupView.popup.toast(hit: "分享成功（只做演示无功能）")
                }),
            ]
        }
    }
    
}
