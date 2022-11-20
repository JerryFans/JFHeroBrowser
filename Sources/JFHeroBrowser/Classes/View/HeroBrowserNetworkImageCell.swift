//
//  HeroBrowserNetworkImageCell.swift
//  Example
//
//  Created by 逸风 on 2021/8/8.
//

import UIKit

open class HeroBrowserNetworkImageCell: HeroBrowserBaseImageCell {
    
    lazy var progressView: HeroCircularProgressView = {
        let progressView = HeroCircularProgressView.hero.progressView()
        return progressView
    }()
    
    lazy var progressContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.jf.rgb(0x000000, alpha: 0.3)
        view.isHidden = true;
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func beginLoadSource() {
        guard let vm = viewModule else { return }
        vm.asyncLoadThumbailSource { [weak self] in
            guard let self = self else { return }
            switch $0 {
            case let .success(image):
                self.updateView(image: image)
                break
            case _ :
                break
            }
        }
        vm.asyncLoadRawSource { [weak self] in
            guard let self = self else { return }
            switch $0 {
            case let .success(image):
                self.updateView(image: image)
                break
            case let .progress(progress):
                self.progressView.progress = Double(progress)
                self.progressContainer.isHidden = progress >= 1 ? true : false
                break
            case _ :
                break
            }
        }
    }
    
    override func setupView() {
        super.setupView()
        self.scrollView.addSubview(self.progressContainer)
        self.progressContainer.frame = self.scrollView.frame
        self.progressContainer.addSubview(self.progressView)
        self.progressView.center = self.progressContainer.center
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
