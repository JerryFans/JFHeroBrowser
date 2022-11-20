//
//  LocalImageViewController.swift
//  JFHeroBrowser_Example
//
//  Created by 逸风 on 2022/4/30.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import JFHeroBrowser

class LocalImageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "LocalImage"
        self.view.backgroundColor = .white
        let button = UIButton(frame: CGRect(x: 50, y: 100, width: 150, height: 150))
        self.view.addSubview(button)
        button.addTarget(self, action: #selector(btnClick(button:)), for: .touchUpInside)
        button.tag = 1
        button.imageView?.contentMode = .scaleAspectFill

        let button1 = UIButton(frame: CGRect(x: 50, y: 260, width: 150, height: 150))
        button1.kf.setImage(with: URL(string: thumbs[1])!, for: .normal)
        self.view.addSubview(button1)
        button1.tag = 2
        button1.imageView?.contentMode = .scaleAspectFill
        button1.addTarget(self, action: #selector(btnClick(button:)), for: .touchUpInside)

        let button2 = UIButton(frame: CGRect(x: 50, y: 420, width: 150, height: 150))
        button2.imageView?.contentMode = .scaleAspectFill
        self.view.addSubview(button2)
        button2.tag = 3
        button2.addTarget(self, action: #selector(btnClick(button:)), for: .touchUpInside)

        let button3 = UIButton(frame: CGRect(x: 50, y: 580, width: 150, height: 150))
        self.view.addSubview(button3)
        button3.tag = 4
        button3.imageView?.contentMode = .scaleAspectFill
        button3.addTarget(self, action: #selector(btnClick(button:)), for: .touchUpInside)

        let button4 = UIButton(frame: CGRect(x: 210, y: 580, width: 150, height: 150))
        self.view.addSubview(button4)
        button4.tag = 5
        button4.imageView?.contentMode = .scaleAspectFill
        button4.addTarget(self, action: #selector(btnClick(button:)), for: .touchUpInside)
        loadImage()
    }
    
    func loadImage() {
        for i in 0...4 {
            let img = UIImage(named: "template-\(i+1)")
            DispatchQueue.main.async {
                let button = self.view.viewWithTag(i+1) as? UIButton
                button?.setImage(img, for: .normal)
            }
        }
    }
    
    
    @objc func btnClick(button: UIButton) {
        var list: [HeroBrowserViewModule] = []
        for i in 0...4 {
            guard let button = self.view.viewWithTag(i+1) as? UIButton, let img = button.imageView?.image else { continue }
            list.append(HeroBrowserLocalImageViewModule(image: img))
        }
        
        let brower = HeroBrowser(viewModules: list, index: button.tag - 1, heroImageView: button.imageView) { [weak self] imageIndex in
            guard let self = self else { return nil }
            guard let btn = self.view.viewWithTag(imageIndex + 1) as? UIButton else { return nil }
            return btn.imageView
        }
        brower.show(with: self, animationType: .hero)
    }
    
}
