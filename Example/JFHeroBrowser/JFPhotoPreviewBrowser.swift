//
//  JFPhotoPreviewBrowser.swift
//  JFPhotoPicker
//
//  Created by 逸风 on 2022/5/13.
//

import UIKit
import JRBaseKit
import JFHeroBrowser

extension JFPhotoPreviewBrowser: HeroBrowserDataSource {
    func viewForHeader() -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: CGSize.jf.screenSize().width, height: CGFloat.jf.navigationBarHeight()))
        v.backgroundColor = UIColor.red
        return v
    }
    
    func viewForFooter() -> UIView? {
        let height = CGFloat.jf.safeAreaBottomHeight() + 55.0
        let v = UIView(frame: CGRect(x: 0, y: CGSize.jf.screenHeight() - height, width: CGSize.jf.screenSize().width, height: height))
        v.backgroundColor = UIColor.red
        return v
    }
}

class JFPhotoPreviewBrowser: HeroBrowser {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
    }
}

public extension Hero where Base: UIViewController {
    
    func browserPreviewPhoto(viewModules: [HeroBrowserViewModule], initIndex: Int, options: (() -> [JFHeroBrowserOption])? = nil) {
        var heroImageView: UIImageView?
        var imageDidChangeHandle: HeroBrowser.ImagePageDidChangeHandle?
        var heroBrowserDidLongPressHandle: HeroBrowser.HeroBrowserDidLongPressHandle?
        var enableBlurEffect = false
        if let allOptions = options?() {
            for option in allOptions {
                switch option {
                case .heroBrowserDidLongPressHandle(let handle):
                    heroBrowserDidLongPressHandle = handle
                    break
                case .enableBlurEffect(let enable):
                    enableBlurEffect = enable
                    break
                case .heroView(let uIImageView):
                    heroImageView = uIImageView
                    break
                case .imageDidChangeHandle(let heroBrowserImageDidChange):
                    imageDidChangeHandle = heroBrowserImageDidChange
                    break
                }
            }
        }
        var config = JFHeroBrowserGlobalConfig.default
        config.enableBlurEffect = enableBlurEffect
        
        if let vm = viewModules.first as? HeroBrowserNetworkImageViewModule {
            assert(vm.imageProvider != nil, "imageProvider == nil, please setup your custom imageProvider in JFHeroBrowserGlobalConfig.default.networkImageProvider property use Kingfisher or SDWebImage or your custom imag caches to implements")
        }
        let vc = JFPhotoPreviewBrowser(viewModules: viewModules, index: initIndex, heroImageView: heroImageView, imagePageDidChangeHandle: imageDidChangeHandle, config: config)
        vc.heroBrowserDidLongPressHandle = heroBrowserDidLongPressHandle
        vc.show(with: base)
    }
}
