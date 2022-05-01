//
//  Hero+UIViewContoller.swift
//  JFHeroBrowser
//
//  Created by 逸风 on 2022/5/1.
//

import Foundation

extension UIViewController: HeroCompatible {}

public extension Hero where Base: UIViewController {
    func browser(viewModules: [HeroBrowserViewModule], initIndex: Int, options: (() -> [JFHeroBrowserOption])? = nil) {
        var heroImageView: UIImageView?
        var imageDidChangeHandle: HeroBrowser.ImagePageDidChangeHandle?
        var enableBlurEffect = false
        if let allOptions = options?() {
            for option in allOptions {
                switch option {
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
        let vc = HeroBrowser(viewModules: viewModules, index: initIndex, heroImageView: heroImageView, imagePageDidChangeHandle: imageDidChangeHandle)
        if enableBlurEffect {
            vc.enableBlurEffet()
        }
        vc.show(with: base)
    }
}
