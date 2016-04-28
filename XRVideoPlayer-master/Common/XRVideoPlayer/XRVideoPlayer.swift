//
//  XRVideoPlayer.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/22.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

/**
 *  @brief AVFoundation封装视频播放器
 *  
 *  @by    黯丶野火
 **/

import UIKit
import Foundation
import AVFoundation

let bottomViewHeight: CGFloat = 40.0

class XRVideoPlayer: UIView {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    private var bottomView: XRVideoToolBottomView!
    private var isPlaying: Bool = false
    private var loadingView: XRActivityInditor?
    private var portraintFrame: CGRect?
    var changedOrientationClosure: ((isFull: Bool) -> ())?
    
    lazy private var keyWindow: UIWindow = {
        
        return UIApplication.sharedApplication().keyWindow!
    }()
    var videoURL: String?
    private var isFull: Bool = false
    
    deinit {
        self.player?.removeTimeObserver(self)
        self.removePlayerItemObserve(playerItem!)
        print("player is destory!")
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, videoURL: String) {
        super.init(frame: frame)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.applicationActiveStatusChanged(_:)), name: "ApplicationActiveStatusChanged", object: nil)
        self.videoURL = videoURL
        if let vURL =  self.videoURL where !vURL.isEmpty {
            if vURL.hasPrefix("http://") || vURL.hasPrefix("https://") || vURL.hasPrefix("rtsp://") {
                let httpURL = NSURL(string: vURL)
                playerItem = AVPlayerItem(URL: httpURL!)
            }else {
                let localURL = NSURL(fileURLWithPath: vURL)
                let asset = AVAsset(URL: localURL)
                playerItem = AVPlayerItem(asset: asset)
            }
            player = AVPlayer(playerItem: playerItem!)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = self.bounds
            playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
            self.layer.addSublayer(playerLayer!)
            
            self.observePlayerPlayTime()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.videoPlayToEnd), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
            self.observePlayerItemPlayStatus(playerItem!)
            
            loadingView = XRActivityInditor(frame: CGRectMake(0, 0, 60, 60))
            loadingView?.center = CGPointMake(self.bounds.width * 0.5, self.bounds.height * 0.5)
            self.addSubview(loadingView!)
            loadingView?.startAnimation()
        }
        
        bottomView = XRVideoToolBottomView(frame: CGRectMake(0, CGRectGetMaxY(self.bounds) - bottomViewHeight, CGRectGetWidth(self.frame), bottomViewHeight))
        bottomView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        self.addSubview(bottomView)
        bottomView.playButtonClickClosure = { [weak self]() -> Void in
            if let weakSelf = self {
                if let videoPlayer = weakSelf.player {
                    if videoPlayer.rate == 0.0 {
                        videoPlayer.play()
                        videoPlayer.rate = 1.0
                        weakSelf.bottomView.setPlayButtonState(true)
                        weakSelf.isPlaying = true
                    }else {
                        videoPlayer.pause()
                        videoPlayer.rate = 0.0
                        weakSelf.bottomView.setPlayButtonState(false)
                        weakSelf.isPlaying = false
                    }
                }
            }
        }
        
        bottomView.rotationOrientationClosure = {[weak self]() -> () in
            if let weakSelf = self {
                if weakSelf.isFull {
                    weakSelf.orientationPortraintScreen()
                }else {
                    weakSelf.orientationRightFullScreen()
                }
            }
        }
        
        bottomView.sliderValueChangedClosure = { [weak self](value) -> () in
            if let weakSelf = self {
                if let item = weakSelf.playerItem {
                    let secconds = CMTimeGetSeconds(item.duration) * Float64(value)
                    weakSelf.seekTimeToPlay(Int64(secconds), toPlay: true)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // destory player
    func releaseVideoPlayer() -> Void {
        
        self.pauseVideoPlay()
        self.player = nil
        self.removeFromSuperview()
    }
    
    func applicationActiveStatusChanged(notif: NSNotification?) -> Void {
        
        if let nf = notif {
            let isActive = nf.object as? Bool
            if let active = isActive {
                if active {
                    // App激活
                    print("App Active")
                    playVideo()
                }else {
                    // App挂起
                    print("App EndBackground")
                    pauseVideoPlay()
                }
            }
        }
    }
    
    func videoPlayToEnd() -> Void {
        
        print("播放完成")
        seekTimeToPlay(0, toPlay: false)
        bottomView.setPlayButtonState(false)
    }
    
    // seek to time to play...
    func seekTimeToPlay(value: Int64, toPlay: Bool = true) -> Void {
        
        if let videoPlayer = player {
            videoPlayer.seekToTime(CMTimeMake(value, 1), completionHandler: { (finished) in
                if finished {
                    if toPlay && self.isPlaying {
                        self.playVideo()
                        self.isPlaying = true
                        dispatch_async(dispatch_get_main_queue(), { 
                            self.bottomView.setPlayButtonState(true)
                        })
                    }
                }
            })
        }
    }
    
    func pauseVideoPlay() -> Void {
        if let videoPlayer = player {
            videoPlayer.pause()
            videoPlayer.rate = 0.0
        }
    }
    
    func playVideo() -> Void {
        
        if let videoPlayer = player {
            videoPlayer.play()
            videoPlayer.rate = 1.0
        }
    }
    
    func playVideoWithURL(videoURL: String) -> Void {
        
        self.videoURL = videoURL
        
        if playerItem != nil {
            self.removePlayerItemObserve(playerItem!)
        }
        
        if let vURL =  self.videoURL where !vURL.isEmpty {
            if vURL.hasPrefix("http://") || vURL.hasPrefix("https://") || vURL.hasPrefix("rtsp://") {
                let httpURL = NSURL(string: vURL)
                playerItem = AVPlayerItem(URL: httpURL!)
            }else {
                let localURL = NSURL(fileURLWithPath: vURL)
                let asset = AVAsset(URL: localURL)
                playerItem = AVPlayerItem(asset: asset)
            }
        }
        
        player?.replaceCurrentItemWithPlayerItem(playerItem)
        playVideo()
        
        self.observePlayerItemPlayStatus(playerItem!)
    }
    
    // radian to angle.
    func radianToAngle(radian: CGFloat) -> CGFloat {
        return radian / CGFloat(M_PI) * 180.0
    }
    
    // rangle to radian.
    func angleToRadian(rangle: CGFloat) -> CGFloat {
        return rangle / 180.0 * CGFloat(M_PI)
    }
    
    // 右旋转屏幕，全屏播放
    func orientationRightFullScreen() -> Void {
        
        if !isFull {
            portraintFrame = self.frame
        }

        // 最好使用旋转单个View配合旋转状态栏的方法进行屏幕旋转，比较容易控制，体验比较好，且大部分的视频播放软件都是采用的这种方式.
        /* UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation")
           这个方法虽然可以，但是在程序前后台切换时会导致横竖屏的混乱.
        */
        UIApplication.sharedApplication().setStatusBarOrientation(.LandscapeRight, animated: true)
        isFull = true
        UIView.animateWithDuration(0.3, animations: { [weak self]() -> Void in
            if let weakSelf = self {
                weakSelf.transform = CGAffineTransformMakeRotation(weakSelf.angleToRadian(90.0))
                weakSelf.frame = weakSelf.keyWindow.bounds
                weakSelf.bottomView.frame = CGRectMake(0, CGRectGetMaxY(weakSelf.bounds) - bottomViewHeight, CGRectGetHeight(weakSelf.frame), bottomViewHeight)
                print(weakSelf.bottomView.frame)
                if let closure = weakSelf.changedOrientationClosure {
                    closure(isFull: weakSelf.isFull)
                }
            }
            }) { [weak self](finish) in
                if let weakSelf = self {
//                    weakSelf.layoutIfNeeded()
                    weakSelf.isFull = true
                }
        }
    }
    
    // 竖屏模式
    func orientationPortraintScreen() -> Void {
        
        UIApplication.sharedApplication().setStatusBarOrientation(.Portrait, animated: true)
        isFull = false
        UIView.animateWithDuration(0.3, animations: { [weak self] () -> Void in
            if let weakSelf = self {
                weakSelf.transform = CGAffineTransformMakeRotation(weakSelf.angleToRadian(-0.0))
                weakSelf.frame = weakSelf.portraintFrame!
                if let closure = weakSelf.changedOrientationClosure {
                    closure(isFull: weakSelf.isFull)
                }
            }
            }) { [weak self](finish) in
                if let weakSelf = self {
                    weakSelf.layoutIfNeeded()
                    weakSelf.isFull = false
                }
        }
    }
    
    // 监听播放器的播放进度
    func observePlayerPlayTime() -> Void {
        
        if let videoPlayer = player {
            let playerItem = videoPlayer.currentItem
            if let item = playerItem {
                videoPlayer.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue: dispatch_get_main_queue(), usingBlock: { [weak self](time) in
                    if let weakSelf = self {
                        let currentTime = CMTimeGetSeconds(time)
                        let duration = CMTimeGetSeconds(item.duration)
                        weakSelf.bottomView.setStartTimeWithSecconds(Double(currentTime))
                        weakSelf.bottomView.setEndTimeWithSecconds(Double(isnan(duration) ? 0.0 : duration))
                        let prencent = isnan(duration) ? 0.0 : currentTime / duration
                        weakSelf.bottomView.setSliderProgress(prencent)
                    }
                    })
            }
        }
    }
    
    // 监听AVPlayerItem
    func observePlayerItemPlayStatus(playerItem: AVPlayerItem) -> Void {
        
        // 监听状态
        playerItem.addObserver(self, forKeyPath: "status", options: [.New, .Old], context: nil)
        // 监听网络加载状况
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.New, .Old], context: nil)
    }
    
    // 移除AVPlaerItem的监听
    func removePlayerItemObserve(playerItem: AVPlayerItem) -> Void {
        
        playerItem.removeObserver(self, forKeyPath: "status")
        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isFull {
            playerLayer?.frame = self.bounds
            bottomView.frame = CGRectMake(0, CGRectGetMaxY(self.bounds) - bottomViewHeight, CGRectGetHeight(self.frame), bottomViewHeight)
            bottomView.layoutIfNeeded()
            loadingView?.center = CGPointMake(self.bounds.height * 0.5, self.bounds.width * 0.5)
            loadingView?.layoutIfNeeded()
        }else {
            playerLayer?.frame = self.bounds
            bottomView.frame = CGRectMake(0, CGRectGetMaxY(self.bounds) - bottomViewHeight, CGRectGetWidth(self.frame), bottomViewHeight)
            bottomView.layoutIfNeeded()
            loadingView?.center = CGPointMake(self.bounds.width * 0.5, self.bounds.height * 0.5)
            loadingView?.layoutIfNeeded()
        }
    }
    
    // MARK: - KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        let playerItem = object as? AVPlayerItem
        
        if let path = keyPath {
            if path == "status" {
                // 状态
                if let changeValue = change where changeValue.count > 0 {
                    let playStatus = AVPlayerItemStatus(rawValue: changeValue["new"]!.integerValue)
                    if let status = playStatus {
                        switch status {
                        case .ReadyToPlay:
                            if let item = playerItem {
                                bottomView.setEndTimeWithSecconds(CMTimeGetSeconds(item.duration))
                            }
                            
                            loadingView?.stopAnimation()
                            if player?.rate == 1.0 {
                                loadingView?.stopAnimation()
                                bottomView.setPlayButtonState(true)
                                isPlaying = true
                            }else {
                                loadingView?.stopAnimation()
                                bottomView.setPlayButtonState(false)
                                isPlaying = false
                            }
                            bottomView.playButton.enabled = true
                        case .Failed:
                            print("error: \(player?.error?.localizedDescription)")
                            bottomView.setPlayButtonState(false)
                            isPlaying = false
                            loadingView?.stopAnimation()
                            bottomView.playButton.enabled = false
                        case .Unknown:
                            print("error: \(player?.error?.localizedDescription)")
                            bottomView.setPlayButtonState(false)
                            isPlaying = false
                            loadingView?.stopAnimation()
                            bottomView.playButton.enabled = false
                        }
                    }
                }
            }else if path == "loadedTimeRanges" {
                // 加载进度
                if let item = playerItem {
                    let timeArray = item.loadedTimeRanges
                    let timeRange = timeArray.first?.CMTimeRangeValue
                    if let tRange = timeRange {
                        let startRange = CMTimeGetSeconds(tRange.start)
                        let durationRange = CMTimeGetSeconds(tRange.duration)
                        let totalRange = startRange + durationRange
                        let precent = totalRange / CMTimeGetSeconds(item.duration)
                        bottomView.setProgress(Float(precent))
                        // 加载时的播放处理
                        if let videoPlayer = player {
                            print("rate: \(videoPlayer.rate)")
                            if videoPlayer.rate == 0.0 {
                                videoPlayer.pause() // 暂停播放
                                bottomView.setPlayButtonState(false)
                                isPlaying = false
                                if !loadingView!.isAnimating {
                                    loadingView?.startAnimation()
                                }else {
                                    videoPlayer.prerollAtRate(1.0, completionHandler: { (finish) in
                                        if finish {
                                            dispatch_async(dispatch_get_main_queue(), {
                                                self.loadingView?.stopAnimation()
                                            })
                                        }
                                    })
                                }
                            }else {
                                if isPlaying {
                                    self.playVideo()
                                    bottomView.setPlayButtonState(true)
                                }else {
                                    self.pauseVideoPlay()
                                    bottomView.setPlayButtonState(false)
                                }
                                loadingView?.stopAnimation()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}



