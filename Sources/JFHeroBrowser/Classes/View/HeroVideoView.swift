//
//  HeroVideoView.swift
//  HeroBrowser
//
//  Created by 逸风 on 2022/4/24.
//

import UIKit
import AVKit

public enum HeroVideoPlayerState {
    case unkonw
    case playing
    case pause
    case stop
    case buffering
    case failed
}

public protocol HeroVideoViewDelegate: NSObjectProtocol {
    func videoViewReadyToPlay(playerItem: AVPlayerItem, view: HeroVideoView)
    func videoViewPlayerPlayingProgress(currentTime: Double, totalTime: Double, view: HeroVideoView)
    func videoViewPlayerStatusDidChange(state: HeroVideoPlayerState, view: HeroVideoView)
    func videoViewPlayerDidPlayToEnd(noti: Notification, view: HeroVideoView)
}

public extension HeroVideoViewDelegate {
    func videoViewReadyToPlay(playerItem: AVPlayerItem, view: HeroVideoView) {
        
    }
    
    func videoViewPlayerPlayingProgress(currentTime: Double, totalTime: Double, view: HeroVideoView) {
        
    }
    
    func videoViewPlayerStatusDidChange(state: HeroVideoPlayerState, view: HeroVideoView) {
        
    }
    
    func videoViewPlayerDidPlayToEnd(noti: Notification, view: HeroVideoView) {
        
    }
}

public class HeroPlayerView: UIView {
    // MARK: - 重写的父类函数
    public override class var layerClass: AnyClass { AVPlayerLayer.self }
    public var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

public class HeroVideoView: HeroPlayerView {
    
    var seekTime: CMTime? = nil
    var isFadeToDisplay: Bool = false
    
    var player: AVPlayer? { playerLayer.player }
    
    var playerItem: AVPlayerItem? {
        willSet {
            guard let oldItem = playerItem else { return }
            if let newItem = newValue, newItem == oldItem { return }
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: oldItem)
            oldItem.removeObserver(self, forKeyPath: "status")
            oldItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
            oldItem.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            oldItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        }
        didSet {
            guard let newItem = playerItem else { return }
            if let oldItem = oldValue, newItem == oldItem { return }
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEnd(noti:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: newItem)
            newItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            newItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
            newItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            newItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        }
    }
    
    var playbackTimeObserver: NSObject?
    public var videoURL: URL?
    //兼容直接从相册拉取PlayerItem播放视频
    public var originPlayerItem: AVPlayerItem?
    public var state: HeroVideoPlayerState = .unkonw {
        didSet {
            self.deletgate?.videoViewPlayerStatusDidChange(state: state, view: self)
        }
    }
    public weak var deletgate: HeroVideoViewDelegate?
    var isPauseByUser: Bool = true
    var totalTime: Double = 0
    var currentTime: Double = 0
    var repeatCount: Int = 0 //重复播放次数
    
    var didEnterBackground = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name:UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterPlayGround), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.playerLayer.videoGravity = .resizeAspectFill //resizeAspect
        self.playerLayer.addObserver(self, forKeyPath: "readyForDisplay", options: .new, context: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        self.player?.currentItem?.cancelPendingSeeks()
        self.player?.currentItem?.asset.cancelLoading()
        self.player?.pause()
        
        if let playbackObserver = self.playbackTimeObserver {
            self.player?.removeTimeObserver(playbackObserver)
            self.playbackTimeObserver = nil
        }
        
        //解决旧系统 不走willSet 导致kvo 没移除崩溃
        if self.playerItem != nil {
            self.playerItem?.removeObserver(self, forKeyPath: "status")
            self.playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
            self.playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            self.playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        }
        
        self.playerLayer.removeObserver(self, forKeyPath: "readyForDisplay")
        
        print("video view dealloc")
    }
    
    func setUpPlayer() {
        guard self.videoURL != nil || self.originPlayerItem != nil else {
            return
        }
        if let url = self.videoURL {
            let asset = AVURLAsset(url: url)
            self.playerItem = AVPlayerItem(asset: asset)
        } else if let item = self.originPlayerItem {
            self.playerItem = item
        }
        
        let player = AVPlayer(playerItem: self.playerItem!)
        player.automaticallyWaitsToMinimizeStalling = false
        playerLayer.player = player
        
        self.monitoringPlayback(playerItem: self.playerItem)
        self.isPauseByUser = false
    }
    
    func monitoringPlayback(playerItem: AVPlayerItem?) {
        if playerItem != nil, let player = self.player {
            self.playbackTimeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: nil) { [weak self] (time) in
                guard let sself = self, let item = sself.playerItem else {
                    return
                }
                guard item.duration.timescale != 0 else {
                    return
                }
                guard item.currentTime().timescale != 0 else {
                    return
                }
                sself.totalTime = Double(item.duration.value / Int64(item.duration.timescale))
                sself.currentTime = Double(time.value / Int64(time.timescale))
                if sself.deletgate != nil {
                    sself.deletgate?.videoViewPlayerPlayingProgress(currentTime: sself.currentTime, totalTime: sself.totalTime, view: sself)
                }
            } as? NSObject
        }
    }
    
    public func resetPlayer() {
        self.didEnterBackground = false
        if self.playbackTimeObserver != nil {
            self.player?.removeTimeObserver(self.playbackTimeObserver!)
            self.playbackTimeObserver = nil
        }
        NotificationCenter.default.removeObserver(self)
        self.pauseVideo()
        self.player?.currentItem?.cancelPendingSeeks()
        self.player?.currentItem?.asset.cancelLoading()
        self.player?.replaceCurrentItem(with: nil)
        self.playerItem = nil
        self.state = .stop
    }
    
    public func playVideo() {
        self.state = .playing
        if self.player == nil {
            self.setUpPlayer()
        }
        self.pauseBackgroundSound()
        self.player?.play()
        print("play url : \(self.videoURL?.absoluteString ?? "url is null")")
    }
    
    public func pauseVideo() {
        self.player?.pause()
        self.state = .pause
    }
    
    public func seekToTime(dragSeconds: Float) {
        let seconds: Int = Int(Double(dragSeconds) * self.totalTime)
        self.player?.seek(to: CMTime(value: CMTimeValue(seconds), timescale: 1), toleranceBefore: CMTime(value: 1, timescale: 1), toleranceAfter: CMTime(value: 1, timescale: 1), completionHandler: { (finished) in
            
        })
    }
    
    @objc func playerItemDidPlayToEnd(noti: Notification) {
        self.repeatCount += 1
        self.resumeBackgroundSound()
        let time = CMTime(value: CMTimeValue(0.2), timescale: 1)
        self.player?.seek(to: time)
        self.pauseVideo()
        self.deletgate?.videoViewPlayerDidPlayToEnd(noti: noti, view: self)
    }
    
    func resumeBackgroundSound() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            
        }
    }
    
    func pauseBackgroundSound() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.soloAmbient)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            
        }
    }
}

// MARK: 播放状态监听 observer
public extension HeroVideoView {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let key = keyPath else { return }
        guard let player = self.player else { return }
        guard let playerItem = self.playerItem else { return }
        
        switch key {
        
        case "status":
            switch playerItem.status {
            case .readyToPlay:
                print("AVPlayerStatusReadyToPlay")
                
                if frame.size == .zero {
                    setNeedsLayout()
                    layoutIfNeeded()
                }
                
                // 跳到xx秒播放视频
                if let seekTime = self.seekTime {
                    self.seekTime = nil
                    player.seek(to: seekTime)
                }
                
                deletgate?.videoViewReadyToPlay(playerItem: playerItem, view: self)
                
            case .failed:
                fallthrough
            case .unknown:
                self.pauseVideo()
                self.state = .failed
                
            default:
                break
            }
            
            
        case "loadedTimeRanges": // TODO 缓冲
//            print("loadedTimeRanges")
            break
            
            
        case "playbackBufferEmpty":
            // 当缓冲是空的时候
            print("playbackBufferEmpty 缓冲中")
            if playerItem.isPlaybackBufferEmpty {
                state = .buffering
            }
            
            
        case "playbackLikelyToKeepUp":
            // 当缓冲好的时候
            print("playbackLikelyToKeepUp")
            if (playerItem.isPlaybackBufferFull || playerItem.isPlaybackLikelyToKeepUp), state == .buffering {
                playVideo()
            }
            
            
        case "readyForDisplay":
            guard playerLayer.isReadyForDisplay, self.alpha == 0 else { return }
            if isFadeToDisplay {
                UIView.animate(withDuration: 0.22) { self.alpha = 1 }
            } else {
                self.alpha = 1
            }
            
            
        default:
            break
        }
    }
    
    @objc func appDidEnterBackground() {
//        self.player?.replaceCurrentItem(with: nil)
        switch self.state {
        case .playing:
            self.pauseVideo()
            self.isPauseByUser = false
            break
        case .buffering:
            self.isPauseByUser = true
            break
        default:
            self.isPauseByUser = true
        }
        self.didEnterBackground = true
    }
    
    @objc func appDidEnterPlayGround()  {
//        self.player?.replaceCurrentItem(with: self.playerItem)
        if self.isPauseByUser == false {
            self.playVideo()
        }
        self.didEnterBackground = false
    }
    
}

extension HeroVideoView {
    func replaceVideoURL(_ videoURL: URL?, seekTime: CMTime? = nil) {
        self.pauseVideo()
        self.isPauseByUser = false
        self.totalTime = 0
        self.currentTime = 0
        self.repeatCount = 0
        
        self.videoURL = nil
        self.playerItem = nil
        if let observer = self.playbackTimeObserver {
            self.player?.removeTimeObserver(observer)
            self.playbackTimeObserver = nil
        }
        
        self.player?.currentItem?.cancelPendingSeeks()
        self.player?.currentItem?.asset.cancelLoading()
        
        guard let obURL = videoURL else {
            self.state = .stop
            self.seekTime = nil
            self.player?.replaceCurrentItem(with: nil)
            return
        }
        
        self.seekTime = seekTime
        
        let player = self.player ?? {
            let player = AVPlayer()
            player.automaticallyWaitsToMinimizeStalling = false
            playerLayer.player = player
            return player
        }()
        
        let asset = AVURLAsset(url: obURL)
        let playerItem = AVPlayerItem(asset: asset)
        
        self.videoURL = videoURL
        self.playerItem = playerItem
        self.monitoringPlayback(playerItem: playerItem)
        
        player.replaceCurrentItem(with: playerItem)
    }
}
