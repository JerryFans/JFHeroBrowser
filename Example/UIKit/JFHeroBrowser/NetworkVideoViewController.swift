//
//  NetworkVideoViewController.swift
//  JFHeroBrowser_Example
//
//  Created by 逸风 on 2022/4/30.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import JFHeroBrowser

class NetworkVideoViewController: UIViewController {
    
    lazy var list: [HeroBrowserViewModuleBaseProtocol] = {
        var list: [HeroBrowserViewModuleBaseProtocol] = []
        let vm = HeroBrowserVideoViewModule(thumbailImgUrl: "http://image.jerryfans.com/w_720_h_1280_d_41_89fd26217dc299a442363581deb75b90_iOS_0.jpg", videoUrl: "http://image.jerryfans.com/w_720_h_1280_d_41_2508b8aa06a2e30d2857f9bcbdfd1de0_iOS.mp4", provider: HeroNetworkImageProvider.shared, autoPlay: true)
        list.append(vm)
        list.append(HeroBrowserLocalImageViewModule(image: UIImage(named: "template-1")!))
        if let path = Bundle.main.path(forResource: "bf.MOV", ofType: nil) {
            let vm1 = HeroBrowserVideoViewModule(thumbailImgUrl: "http://image.jerryfans.com/bf.jpg", fileUrlPath: path, provider: HeroNetworkImageProvider.shared, autoPlay: false)
            list.append(vm1)
        }
        return list
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "NetworkVideo"
        self.view.backgroundColor = .white
        let button4 = UIButton(frame: CGRect(x: 50, y: 100, width: 150, height: 150))
        self.view.addSubview(button4)
        button4.kf.setImage(with: URL(string: "http://image.jerryfans.com/w_720_h_1280_d_41_89fd26217dc299a442363581deb75b90_iOS_0.jpg"), for: .normal)
        button4.tag = 0
        button4.imageView?.contentMode = .scaleAspectFill
        button4.addTarget(self, action: #selector(videoBtnClick(button:)), for: .touchUpInside)
        
        let button5 = UIButton(frame: CGRect(x: 210, y: 100, width: 150, height: 150))
        self.view.addSubview(button5)
        button5.setImage(UIImage(named: "template-1"), for: .normal)
        button5.tag = 1
        button5.imageView?.contentMode = .scaleAspectFill
        button5.addTarget(self, action: #selector(btnClick(button:)), for: .touchUpInside)
        
        let button6 = UIButton(frame: CGRect(x: 50, y: 260, width: 150, height: 150))
        self.view.addSubview(button6)
        button6.kf.setImage(with: URL(string: "http://image.jerryfans.com/bf.jpg"), for: .normal)
        button6.tag = 2
        button6.imageView?.contentMode = .scaleAspectFill
        button6.addTarget(self, action: #selector(videoBtnClick(button:)), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    @objc func btnClick(button: UIButton) {
        self.hero.browserMultiSoures(viewModules: self.list, initIndex: 1) {
            [
                .enableBlurEffect(false),
                .heroView(button.imageView),
                .imageDidChangeHandle({ [weak self] imageIndex in
                    guard let self = self else { return nil }
                    guard let btn = self.view.viewWithTag(imageIndex) as? UIButton else { return nil }
                    return btn.imageView
                })
            ]
        }
    }
    
    @objc func videoBtnClick(button: UIButton) {
        let vm = HeroBrowserVideoViewModule(thumbailImgUrl: "http://image.jerryfans.com/w_720_h_1280_d_41_89fd26217dc299a442363581deb75b90_iOS_0.jpg", videoUrl: "http://image.jerryfans.com/w_720_h_1280_d_41_2508b8aa06a2e30d2857f9bcbdfd1de0_iOS.mp4", provider: HeroNetworkImageProvider.shared, autoPlay: true)
        self.hero.browserVideo(viewModule: vm)
//        self.hero.browserMultiSoures(viewModules: self.list, initIndex: button.tag) {
//            [
//                .enableBlurEffect(false),
//                .heroView(button.imageView),
//                .imageDidChangeHandle({ [weak self] imageIndex in
//                    guard let self = self else { return nil }
//                    guard let btn = self.view.viewWithTag(imageIndex) as? UIButton else { return nil }
//                    return btn.imageView
//                })
//            ]
//        }
    }
}
