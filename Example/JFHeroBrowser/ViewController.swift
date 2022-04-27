//
//  ViewController.swift
//  JFHeroBrowser
//
//  Created by fanjiaorng919 on 04/27/2022.
//  Copyright (c) 2022 fanjiaorng919. All rights reserved.
//

import UIKit
import JFHeroBrowser
import Kingfisher
import UIKit
import Foundation
import MobileCoreServices
import Photos

let thumbs: [String] = {
    var temp: [String] = []
    for i in 1...20 {
        temp.append("http://image.jerryfans.com/template-\(i).jpg")
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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(frame: CGRect(x: 50, y: 100, width: 150, height: 150))
        
        button.kf.setImage(with: URL(string: thumbs[0])!, for: .normal)
        self.view.addSubview(button)
        button.addTarget(self, action: #selector(btnClick(button:)), for: .touchUpInside)
        button.tag = 0
        button.imageView?.contentMode = .scaleAspectFill
        
        let button1 = UIButton(frame: CGRect(x: 50, y: 260, width: 150, height: 150))
        button1.kf.setImage(with: URL(string: thumbs[1])!, for: .normal)
        self.view.addSubview(button1)
        button1.tag = 1
        button1.imageView?.contentMode = .scaleAspectFill
        button1.addTarget(self, action: #selector(btnClick(button:)), for: .touchUpInside)
        
        let button2 = UIButton(frame: CGRect(x: 50, y: 420, width: 150, height: 150))
        button2.kf.setImage(with: URL(string: thumbs[2])!, for: .normal)
        button2.imageView?.contentMode = .scaleAspectFill
        self.view.addSubview(button2)
        button2.tag = 2
        button2.addTarget(self, action: #selector(btnClick(button:)), for: .touchUpInside)
        
        let button3 = UIButton(frame: CGRect(x: 50, y: 580, width: 150, height: 150))
        button3.kf.setImage(with: URL(string: thumbs[3])!, for: .normal)
        self.view.addSubview(button3)
        button3.tag = 3
        button3.imageView?.contentMode = .scaleAspectFill
        button3.addTarget(self, action: #selector(btnClick(button:)), for: .touchUpInside)
        
        let button4 = UIButton(frame: CGRect(x: 210, y: 580, width: 150, height: 150))
        button4.kf.setImage(with: URL(string: thumbs[4])!, for: .normal)
        self.view.addSubview(button4)
        button4.tag = 4
        button4.imageView?.contentMode = .scaleAspectFill
        button4.addTarget(self, action: #selector(btnClick(button:)), for: .touchUpInside)
        
        let button5 = UIButton(frame: CGRect(x: 210, y: 420, width: 150, height: 150))
        button5.kf.setImage(with: URL(string: "http://image.jerryfans.com/w_720_h_1280_d_41_89fd26217dc299a442363581deb75b90_iOS_0.jpg")!, for: .normal)
        button5.imageView?.contentMode = .scaleAspectFill
        self.view.addSubview(button5)
        button5.tag = 5
        button5.addTarget(self, action: #selector(videoBtnClick(button:)), for: .touchUpInside)
    }
    
    @objc func videoBtnClick(button: UIButton) {
        
        let brower = HeroBrowser(viewModules: [HeroBrowserVideoViewModule(thumbailImgUrl: "http://image.jerryfans.com/w_720_h_1280_d_41_89fd26217dc299a442363581deb75b90_iOS_0.jpg", videoUrl: "http://image.jerryfans.com/w_720_h_1280_d_41_2508b8aa06a2e30d2857f9bcbdfd1de0_iOS.mp4")], index: button.tag)
        brower.originImageView = button.imageView
        brower.show(with: self, animationType: .hero)
    }
    
    @objc func btnClick(button: UIButton) {
        var list: [HeroBrowserViewModule] = []
        for i in 0...15 {
            list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: thumbs[i], originImgUrl: origins[i]))
        }
        
        let brower = HeroBrowser(viewModules: list, index: button.tag)
        brower.originImageView = button.imageView
        brower.show(with: self, animationType: .hero)
    }
}

