//
//  Hero+UIViewContoller.swift
//  JFHeroBrowser
//
//  Created by 逸风 on 2022/5/1.
//

import Foundation

extension UIViewController: HeroCompatible {}

public extension Hero where Base: UIViewController {
    
    ///browser single video if you want to browser multi video please see (func browserMultiSoures)
    func browserVideo(viewModule: HeroBrowserVideoViewModule, options: (() -> [JFHeroBrowserOption])? = nil) {
        var heroImageView: UIImageView?
        var imageDidChangeHandle: HeroBrowser.ImagePageDidChangeHandle?
        var heroBrowserDidLongPressHandle: HeroBrowser.HeroBrowserDidLongPressHandle?
        
        var config = JFHeroBrowserGlobalConfig.default
        config.enableBlurEffect = false
        if let allOptions = options?() {
            for option in allOptions {
                switch option {
                case .heroBrowserDidLongPressHandle(let handle):
                    heroBrowserDidLongPressHandle = handle
                    break
                case .enableBlurEffect(let enable):
                    config.enableBlurEffect = enable
                    break
                case .heroView(let uIImageView):
                    heroImageView = uIImageView
                    break
                case .imageDidChangeHandle(let heroBrowserImageDidChange):
                    imageDidChangeHandle = heroBrowserImageDidChange
                    break
                case .pageControlType(let pageControlerType):
                    config.pageControlType = pageControlerType
                    break
                }
            }
        }
        
        let vc = HeroBrowser(viewModules: [viewModule], index: 0, heroImageView: heroImageView, imagePageDidChangeHandle: imageDidChangeHandle, config: config)
        vc.heroBrowserDidLongPressHandle = heroBrowserDidLongPressHandle
        vc.show(with: base)
    }
    
    ///browser photos
    func browserPhoto(viewModules: [HeroBrowserViewModule], initIndex: Int, options: (() -> [JFHeroBrowserOption])? = nil) {
        var heroImageView: UIImageView?
        var imageDidChangeHandle: HeroBrowser.ImagePageDidChangeHandle?
        var heroBrowserDidLongPressHandle: HeroBrowser.HeroBrowserDidLongPressHandle?
        var config = JFHeroBrowserGlobalConfig.default
        config.enableBlurEffect = JFHeroBrowserGlobalConfig.default.enableBlurEffect
        if let allOptions = options?() {
            for option in allOptions {
                switch option {
                case .heroBrowserDidLongPressHandle(let handle):
                    heroBrowserDidLongPressHandle = handle
                    break
                case .enableBlurEffect(let enable):
                    config.enableBlurEffect = enable
                    break
                case .heroView(let uIImageView):
                    heroImageView = uIImageView
                    break
                case .imageDidChangeHandle(let heroBrowserImageDidChange):
                    imageDidChangeHandle = heroBrowserImageDidChange
                    break
                case .pageControlType(let pageControlType):
                    config.pageControlType = pageControlType
                    break
                }
            }
        }
        
        if let vm = viewModules.first as? HeroBrowserNetworkImageViewModule {
            assert(vm.imageProvider != nil, "imageProvider == nil, please setup your custom imageProvider in JFHeroBrowserGlobalConfig.default.networkImageProvider property use Kingfisher or SDWebImage or your custom imag caches to implements")
        }
        let vc = HeroBrowser(viewModules: viewModules, index: initIndex, heroImageView: heroImageView, imagePageDidChangeHandle: imageDidChangeHandle, config: config)
        vc.heroBrowserDidLongPressHandle = heroBrowserDidLongPressHandle
        vc.show(with: base)
    }
    
    ///multi video + photo
    func browserMultiSoures(viewModules: [HeroBrowserViewModuleBaseProtocol], initIndex: Int, options: (() -> [JFHeroBrowserOption])? = nil) {
        var heroImageView: UIImageView?
        var imageDidChangeHandle: HeroBrowser.ImagePageDidChangeHandle?
        var heroBrowserDidLongPressHandle: HeroBrowser.HeroBrowserDidLongPressHandle?
        
        var config = JFHeroBrowserGlobalConfig.multiSource
        if let allOptions = options?() {
            for option in allOptions {
                switch option {
                case .heroBrowserDidLongPressHandle(let handle):
                    heroBrowserDidLongPressHandle = handle
                    break
                case .enableBlurEffect(let enable):
                    config.enableBlurEffect = enable
                    break
                case .heroView(let uIImageView):
                    heroImageView = uIImageView
                    break
                case .imageDidChangeHandle(let heroBrowserImageDidChange):
                    imageDidChangeHandle = heroBrowserImageDidChange
                    break
                case .pageControlType(let pageControlType):
                    config.pageControlType = pageControlType
                    break
                }
            }
        }
        
        if let vm = viewModules.first as? HeroBrowserNetworkImageViewModule {
            assert(vm.imageProvider != nil, "imageProvider == nil, please setup your custom imageProvider in JFHeroBrowserGlobalConfig.default.networkImageProvider property use Kingfisher or SDWebImage or your custom imag caches to implements")
        }
        let vc = HeroBrowser(viewModules: viewModules, index: initIndex, heroImageView: heroImageView, imagePageDidChangeHandle: imageDidChangeHandle, config: config)
        vc.heroBrowserDidLongPressHandle = heroBrowserDidLongPressHandle
        vc.show(with: base)
    }
}
