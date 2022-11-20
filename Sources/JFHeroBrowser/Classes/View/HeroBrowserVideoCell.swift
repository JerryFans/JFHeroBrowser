//
//  HeroBrowserAssetVideoCell.swift
//  HeroBrowser
//
//  Created by 逸风 on 2022/4/24.
//

import UIKit
import AVKit

extension HeroBrowserVideoCell: HeroVideoViewDelegate {
    func videoViewReadyToPlay(playerItem: AVPlayerItem, view: HeroVideoView) {
        self.loadingImageV.isHidden = true
    }
    
    func videoViewPlayerPlayingProgress(currentTime: Double, totalTime: Double, view: HeroVideoView) {
        if currentTime > 0 {
            self.container.isHidden = true
            self.videoView.isHidden = false
            self.playButton.isHidden = false
        }
    }
    
    func videoViewPlayerDidPlayToEnd(noti: Notification, view: HeroVideoView) {
        self.videoView.playVideo()
    }
    
    func videoViewPlayerStatusDidChange(state: HeroVideoPlayerState, view: HeroVideoView) {
        switch state {
        case .failed:
            self.loadingImageV.isHidden = true
            self.playButton.isSelected = false
            self.container.isHidden = false
            break
        case .playing:
            self.loadingImageV.isHidden = true
            self.playButton.isSelected = true
            break
        case .buffering:
            self.playButton.isSelected = true
            self.addRotationAnimation()
            self.loadingImageV.isHidden = false
            break
        case .pause:
            self.playButton.isSelected = false
            self.loadingImageV.isHidden = true
            break
        case .stop:
            self.loadingImageV.isHidden = true
            self.playButton.isSelected = false
            self.container.isHidden = false
            break
        default:
            break
        }
    }
}

class HeroBrowserVideoCell: HeroBrowserBaseImageCell {
    
    lazy var videoView: HeroVideoView = {
        let view = HeroVideoView(frame: .zero)
        view.deletgate = self
        return view
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(HeroBundleTool.getBundleImage(with: "icon_play"), for: .normal)
        button.setImage(UIImage(customColor: .clear), for: .selected)
        button.addTarget(self, action: #selector(playBtnClick(button:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy var loadingImageV: UIImageView = {
        let imageView = UIImageView(image: HeroBundleTool.getBundleImage(with: "icon_video_loading"))
        imageView.isHidden = true
        return imageView
    }()
    
    override func beginLoadSource() {
        guard let vm = videoViewModule else { return }
        vm.asyncLoadThumbailSource { result in
            switch result {
            case let .success(image):
                self.updateView(image: image)
                break
            case _ :
                break
            }
        }
        vm.asyncLoadRawSource { result in
            switch result {
            case let .success(playerItem):
                self.updateVideoView(with: playerItem)
                break
            case _ :
                break
            }
        }
    }
    
    func updateVideoView(with playerItem: AVPlayerItem) {
        guard let vm = self.videoViewModule else { return }
        self.videoView.originPlayerItem = playerItem
        if vm.isAutoPlay {
            self.videoView.playVideo()
        } else {
            self.playButton.isHidden = false
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.playButton.translatesAutoresizingMaskIntoConstraints = false
        self.videoView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingImageV.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.isScrollEnabled = false
        self.scrollView.maximumZoomScale = 1.0
        self.scrollView.insertSubview(self.videoView, belowSubview: self.container)
        
        self.scrollView.addConstraints(
            [
                NSLayoutConstraint(item: self.videoView, attribute: .left, relatedBy: .equal, toItem: self.container, attribute: .left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self.videoView, attribute: .right, relatedBy: .equal, toItem: self.container, attribute: .right, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self.videoView, attribute: .top, relatedBy: .equal, toItem: self.container, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self.videoView, attribute: .bottom, relatedBy: .equal, toItem: self.container, attribute: .bottom, multiplier: 1, constant: 0),
          ]
        )
        
        self.scrollView.addSubview(self.loadingImageV)
        
        self.scrollView.addConstraints(
            [
                NSLayoutConstraint(item: self.loadingImageV, attribute: .centerX, relatedBy: .equal, toItem: self.container, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self.loadingImageV, attribute: .centerY, relatedBy: .equal, toItem: self.container, attribute: .centerY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self.loadingImageV, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 35),
                NSLayoutConstraint(item: self.loadingImageV, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 35),
          ]
        )
        
        self.scrollView.addSubview(self.playButton)
        
        self.scrollView.addConstraints(
            [
                NSLayoutConstraint(item: self.playButton, attribute: .left, relatedBy: .equal, toItem: self.container, attribute: .left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self.playButton, attribute: .right, relatedBy: .equal, toItem: self.container, attribute: .right, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self.playButton, attribute: .top, relatedBy: .equal, toItem: self.container, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self.playButton, attribute: .bottom, relatedBy: .equal, toItem: self.container, attribute: .bottom, multiplier: 1, constant: 0),
          ]
        )
        
        self.videoView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func playBtnClick(button: UIButton) {
        if button.isSelected {
            self.videoView.pauseVideo()
        } else {
            self.videoView.playVideo()
        }
    }
    
    func addRotationAnimation() {
        if self.loadingImageV.layer.animationKeys() == nil {
            let baseAni = CABasicAnimation(keyPath: "transform.rotation.z")
            let toValue: CGFloat = .pi * 2.0
            baseAni.toValue = toValue
            baseAni.duration = 1.0
            baseAni.isCumulative = true
            baseAni.repeatCount = MAXFLOAT
            baseAni.isRemovedOnCompletion = false
            self.loadingImageV.layer.add(baseAni, forKey: "rotationAnimation")
        }
    }
    
    override func beginDragHandle() {
        self.videoView.pauseVideo()
    }
    
    override func endDragHandle() {
        self.videoView.playVideo()
    }
    
}
