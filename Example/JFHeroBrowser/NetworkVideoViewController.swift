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
    
//    lazy var videoView: HeroVideoView = {
//        let videoView = HeroVideoView(frame: .zero)
//        videoView.videoURL = URL(string: "http://image.jerryfans.com/w_720_h_1280_d_41_2508b8aa06a2e30d2857f9bcbdfd1de0_iOS.mp4")
//        return videoView
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "NetworkVideo"
        self.view.backgroundColor = .white
        let button4 = UIButton(frame: CGRect(x: 50, y: 100, width: 150, height: 150))
        self.view.addSubview(button4)
        button4.kf.setImage(with: URL(string: "http://image.jerryfans.com/w_720_h_1280_d_41_89fd26217dc299a442363581deb75b90_iOS_0.jpg"), for: .normal)
        button4.tag = 5
        button4.imageView?.contentMode = .scaleAspectFill
        button4.addTarget(self, action: #selector(videoBtnClick(button:)), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    @objc func videoBtnClick(button: UIButton) {
        let vm = HeroBrowserVideoViewModule(thumbailImgUrl: "http://image.jerryfans.com/w_720_h_1280_d_41_89fd26217dc299a442363581deb75b90_iOS_0.jpg", videoUrl: "http://image.jerryfans.com/w_720_h_1280_d_41_2508b8aa06a2e30d2857f9bcbdfd1de0_iOS.mp4", provider: HeroNetworkImageProvider.shared)
        self.hero.browserVideo(viewModule: vm) {
            [
                .enableBlurEffect(false),
                .heroView(button.imageView)
            ]
        }
//        let brower = HeroBrowser(viewModules: [HeroBrowserVideoViewModule(thumbailImgUrl: "http://image.jerryfans.com/w_720_h_1280_d_41_89fd26217dc299a442363581deb75b90_iOS_0.jpg", videoUrl: "http://image.jerryfans.com/w_720_h_1280_d_41_2508b8aa06a2e30d2857f9bcbdfd1de0_iOS.mp4", provider: HeroNetworkImageProvider.shared)], index: button.tag, heroImageView: button.imageView)
//        brower.show(with: self, animationType: .hero)
    }
}
